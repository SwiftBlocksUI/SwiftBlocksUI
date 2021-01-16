//
//  SocketModeReceiver.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import struct Logging.Logger
import class  Macro.IncomingMessage
import class  Macro.ServerResponse

#if canImport(Network)
import enum   MacroCore.EventListenerSet
import enum   Macro.process
import func   Macro.nextTick
import struct SlackBlocksModel.ApplicationID

private let debugReconnects =
              process.getenvflag("blocks.socketmode.debug.reconnects")

/**
 * A receiver for the Slack Socket Mode API.
 *
 * This implementation is for development purposes only and requires macOS
 * 10.5 (i.e. the WebSocket support in the Network framework).
 *
 * Socket Mode allows development of Slack applications w/o a public HTTP
 * endpoint. Events, shortcuts, slash commands are sent over WebSockets
 * which are initiated by the machine of the developers (i.e. are outgoing).
 *
 * Initialize an Express instance w/ a SocketModeReceiver attached.
 *
 *     let socketModeReceiver = SocketModeReceiver(
 *       token: process.env["SLACK_APP_TOKEN"] ?? ""
 *     )
 *
 *     let app = express(
 *       receiver: socketModeReceiver
 *     )
 *
 *     app.use { req, res, next in
 *       ...
 *     }
 *
 *     app.start()
 *
 * Socket Mode is activated in the configuration section of your application.
 * Remember that an application is using EITHER Socket Mode OR HTTP endpoints.
 */
@available(macOS 10.15, *)
public final class SocketModeReceiver {
  // Note: This may have threading issues. It's just for development, so let's
  //       not overdesign this thing.
  
  static  let openURL =
                URL(string: "https://slack.com/api/apps.connections.open")!
  
  enum SocketModeError: Swift.Error {
    case transport(Swift.Error)
    case missingContent
    case invalidJSON(Swift.Error)
    case unexpectedJSON(Any)
  }
  
  struct Hello {
    let appID      : ApplicationID
    let date       : Date
    let serverDate : String?
    let duration   : TimeInterval? // e.g. 3600s
  }

  enum State {
    case disconnected
    case openSocketURL   (URLSessionDataTask)
    case openFailed      (SocketModeError, Date)
    case connectWebSocket(URLSessionWebSocketTask)
    case connectFailed   (SocketModeError, Date)
    case connected       (URLSessionWebSocketTask, Date)
  }
  
  private var state       = State.disconnected
  private var log         : Logger
  private let session     : URLSession
  private var wsURL       : URL?
  private let openRequest : URLRequest
  private let delegate    = Delegate()
  private var hello       : Hello?
  
  private var _requestListeners =
    EventListenerSet<( IncomingMessage, ServerResponse )>()

  public
  init(token: String, apiEndpointURL: URL? = nil,
       sessionConfiguration : URLSessionConfiguration = .default,
       log: Logger = .init(label: "μ.blocks.socket"))
  {
    self.log     = log
    self.hello   = nil
    self.session = URLSession(configuration : sessionConfiguration,
                              delegate      : delegate,
                              delegateQueue : nil)
    
    self.openRequest = {
      var req = URLRequest(url: apiEndpointURL ?? SocketModeReceiver.openURL)
      req.httpMethod = "POST"
      req.addValue("0", forHTTPHeaderField: "Content-Length")
      req.addValue("application/x-www-form-urlencoded",
                   forHTTPHeaderField: "Content-type")
      req.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
      req.httpBody = Data()
      return req
    }()
    
    delegate.owner = self
  }
  deinit {
    delegate.owner = nil
  }
  
  @discardableResult
  public func onRequest(execute:
                @escaping ( IncomingMessage, ServerResponse ) -> Void) -> Self
  {
    _requestListeners.add(execute)
    return self
  }

  // MARK: - Lifecycle
  
  public func resume() {
    log.trace("resuming ...")
    connect()
  }
  
  public func suspend() {
    log.trace("suspending ...")
    disconnect()
  }
  
  
  // MARK: - Connecting
  
  func transition(to state: State) { // Q: any
    // TBD: thread
    log.trace("transition to state:", state, "from:", self.state)
    self.state = state
  }
  
  func disconnect() {
    if case .disconnected = state { return }
    
    pingTimer?.cancel(); pingTimer = nil
    
    hello = nil
    self.log[metadataKey: "appID"] = "-"
    
    if case .connected(let task, _) = state {
      task.cancel(with: .normalClosure, reason: nil)
    }
    
    transition(to: .disconnected)
  }
  
  func connect() {
    disconnect()
    
    let task = session.dataTask(with: openRequest) { data, res, error in
      // Q: any
      let now = Date()
      
      if let error = error {
        return self.transition(to: .openFailed(.transport(error), now))
      }
      guard let data = data else {
        return self.transition(to: .openFailed(.missingContent, now))
      }
      
      do {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = json as? [ String : Any ],
              let urlString = dict["url"] as? String,
              let url = URL(string: urlString) else
        {
          return self.transition(to: .openFailed(.unexpectedJSON(json), now))
        }
        
        self.connectToWebSocket(url)
      }
      catch {
        return self.transition(to: .openFailed(.invalidJSON(error), now))
      }
    }
    
    self.transition(to: .openSocketURL(task))
    task.resume()
  }
  
  func connectToWebSocket(_ url: URL) { // Q: any
    let connectURL : URL = {
      if !debugReconnects { return url }
      return url.urlByAddingQueryParameters([ .init(name: "debug_reconnects",
                                                    value: "true")])
          ?? url
    }()
    
    let socketTask = session.webSocketTask(with: connectURL)
    self.transition(to: .connectWebSocket(socketTask))
    
    socketTask.resume()
    readNextMessage(in: socketTask)
    schedulePing()
  }
  
  private func readNextMessage(in socketTask: URLSessionWebSocketTask) {
    // Cycle, make sure to break it on errors!
    socketTask.receive { result in
      switch result {
        case .failure(let error):
          self.handleReceiveError(error)
          
        case .success(let message):
          switch message {
            case .data(let data):
              self.handleMessage(data)
            case .string(let string): // this is used
              self.handleMessage(Data(string.utf8))
            @unknown default:
              self.log.error("Unexpected WebSocket message:", message)
          }
          self.readNextMessage(in: socketTask)
      }
    }
  }
    
  private func handleMessage(_ data: Data) {
    let json : Any
    do {
      json = try JSONSerialization.jsonObject(with: data)
    }
    catch {
      return log.error("Could not parse JSON in WebSocket message:", error)
    }
    
    guard let dict = json         as? [ String : Any ],
          let type = dict["type"] as? String else
    {
      return log.error("Unexpected JSON:", json)
    }
    
    switch type {
      case "hello"      : return handleHello(dict)
      case "disconnect" : return handleDisconnect(dict)
      default           : break
    }
    
    let acceptsResponse = (dict["accepts_response_payload"] as? Bool) ?? false
    guard let envelopeID = dict["envelope_id"] as? String else {
      return log.error("Missing envelope-id in JSON:", json)
    }
    guard let payload = dict["payload"] as? [ String : Any ] else {
      return log.error("Missing payload in JSON:", json)
    }
    
    log.log("Event:", envelopeID, acceptsResponse ? "accepts response" : "")
    
    
    // make sure we are on a proper EventLoop thread! Else havoc happens :-)
    nextTick {
      guard let req = IncomingMessage(slackType: type, payload: payload,
                                      path: "/") else
      {
        return self.log.error("Could not create request from JSON:", json)
      }
      
      let res = ServerResponse(unsafeChannel: nil, log: req.log)
      res.cork()
      res.request = req
      
      req.log[metadataKey: "envelope-id"] = .init(stringLiteral: envelopeID)
      res.log[metadataKey: "envelope-id"] = .init(stringLiteral: envelopeID)

      // The transaction ends when the response is done, not when the
      // request was read completely!
      var didFinish = false
      
      res.onceFinish {
        // convert res to gateway Response and call callback
        guard !didFinish else {
          return self.log.error("TX already finished!")
        }
        didFinish = true
        
        self.sendResponse(res, envelopeID: envelopeID,
                          sendBody: acceptsResponse)
      }
      
      res.onError { error in
        guard !didFinish else {
          return self.log.error("Follow up error: \(error)")
        }
        didFinish = true
        self.log.error("response error:", error)
      }
    
      self._requestListeners.emit( ( req, res ) )
    }
  }
  
  private func sendResponse(_ res: ServerResponse, envelopeID: String,
                            sendBody: Bool)
  {
    guard case .connected(let task, _) = state else {
      log.error("Cannot send response for \(envelopeID),",
                "not connected anymore:", res)
      return
    }
    
    guard res.status == .ok else {
      return log.error("Not going to reply w/ non-OK response:", res)
    }
    
    var json = [ String : Any ]()
    json["envelope_id"] = envelopeID

    if sendBody {
      if let buffer = res.writableBuffer, !buffer.isEmpty {
        let contentType = (res.headers["Content-Type"].first ?? "").lowercased()
        
        if contentType.hasPrefix("application/json") {
          do {
            let payload = try JSONSerialization.jsonObject(with: buffer.data)
            json["payload"] = payload
          }
          catch {
            return log.error("Could not parse JSON in response:", res)
          }
        }
        else {
          log.error("Unsupported response body type:", contentType,
                    try? buffer.toString(),
                    res.headers)
        }
      }
    }
    else {
      if let buffer = res.writableBuffer, !buffer.isEmpty {
        log.warn("Not sending body of response, no payload accepted:", res)
      }
    }
    
    guard !json.isEmpty else { return }
    
    let data : Data
    do {
      data = try JSONSerialization.data(withJSONObject: json)
    }
    catch {
      return log.error("failed to encode response as JSON:", error, res)
    }
    guard let s = String(data: data, encoding: .utf8) else {
      return log.error("failed to encode JSON response:", res, json)
    }

    task.send(.string(s)) { error in
      if let error = error {
        self.handleSendError(error)
      }
      else {
        self.log.log("sent response to envelope:", envelopeID)
      }
    }
  }
  
  private func handleDisconnect(_ json: [ String : Any ]) {
    enum DisconnectReasons: String {
      case socketModeDisabled = "socket_mode_disabled"
      case refreshRequested   = "refresh_requested"
      case warning // e.g. with the debugging on
    }
    
    let reasonString = (json["reason"] as? String) ?? "no reason given"
    log.log("Received disconnect:", json)
    
    disconnect()
    
    switch DisconnectReasons(rawValue: reasonString) {
      case .socketModeDisabled:
        log.log("not reconnecting, socket mode was disabled.")
      case .refreshRequested:
        connect()
      case .warning:
        connect()
      default:
        log.log("reconnecting after unknown reason:", reasonString)
        connect()
    }
  }
  
  private func handleHello(_ json: [ String : Any ]) {
    assert(self.hello == nil)
    
    guard let conInfo = json["connection_info"] as? [ String : Any ] else {
      return log.error("found no connection info in hello JSON:", json)
    }
    guard let appIDString = conInfo["app_id"] as? String else {
      return log.error("found no app-id in hello JSON:", json)
    }
    let debugInfo = json["debug_info"] as? [ String : Any ]
    let started   = debugInfo?["started"] as? String // not always there
    let validity  = (debugInfo?["approximate_connection_time"] as? Int)
                    .flatMap { TimeInterval($0) }
    
    hello = Hello(appID: ApplicationID(appIDString),
                  date: Date(),
                  serverDate: started,
                  duration: validity)
    log.log("Hello:", hello)
    
    guard case .connected(let task, _) = state else {
      log.error("Got 'hello', but not connected:", self)
      return
    }
    
    log[metadataKey: "appID"] = .init(stringLiteral: appIDString)
    
    // Acknowledge. They write we should, but not how :-) And the 'hello'
    // doesn't have an envelope.
    let helloACK =
    """
    { "type": "hello",
      "debug_info": {
        "framework" : "SwiftBlocksUI",
        "language"  : "Swift",
        "timestamp" : \(Int(Date().timeIntervalSince1970)),
        "answer"    : 42
      }
    }
    """
    task.send(.string(helloACK)) { error in
      if let error = error {
        self.log.error("failed to respond w/ hello:", error)
        self.handleSendError(error)
      }
      else {
        self.log.debug("Successfully ACKed 'hello'")
      }
    }
  }
  
  // FIXME: threading
  private var pingTimer    : DispatchWorkItem?
  private let pingInterval : TimeInterval = 10
  
  private func schedulePing() {
    pingTimer?.cancel(); pingTimer = nil
    let wi = DispatchWorkItem {
      guard case .connected(let task, _) = self.state else {
        self.log.log("stop pinging, not connected.")
        return
      }
      
      self.log.trace("ping ...")
      task.sendPing { error in
        if let error = error {
          self.log.error("ping failed:", error)
          self.handleSendError(error)
        }
        else {
          self.log.trace("pong.")
          self.schedulePing()
        }
      }
    }
    self.pingTimer = wi
    DispatchQueue.main
      .asyncAfter(deadline: .now() + .milliseconds(Int(pingInterval * 1000)),
                  execute: wi)
  }
  
  private func handleSendError(_ error: Error) { // Q: Any
    // TBD: reconnect?
  }
  
  private func handleReceiveError(_ error: Error) { // Q: Any
    let nsError = error as NSError
    
    switch ( nsError.domain, nsError.code ) {
      case ( NSURLErrorDomain, NSURLErrorCancelled ): return
      default:
        log.error("Receive failed:", error)
    }
    
    disconnect()
    connect()
  }
  
  // TBD: an own delegate?
  
  fileprivate final class Delegate: NSObject, URLSessionWebSocketDelegate {
    
    weak var owner : SocketModeReceiver?
    
    override init() {
      owner = nil
      super.init()
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?)
    {
      owner?.transition(to: .connected(webSocketTask, Date()))
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?)
    {
      let reason = reason.flatMap { String(data: $0, encoding: .utf8) }
      owner?.log.log("did close:", closeCode, reason)
      owner?.disconnect()
    }
  }
}

extension SocketModeReceiver.Hello: CustomStringConvertible {
  var description: String {
    var ms = "<Hello[\(appID.id)]: age="
    ms += String(describing: Int(-date.timeIntervalSinceNow))
    if let v = serverDate { ms += " server-date=\(v)" }
    if let v = duration   { ms += " livetime=\(Int(v))s" }
    ms += ">"
    return ms
  }
}

#else // !canImport(Network)

public final class SocketModeReceiver {
  
  let log : Logger

  init(token: String, apiEndpointURL: URL? = nil,
       sessionConfiguration : URLSessionConfiguration = .default,
       log: Logger = .init(label: "μ.blocks.socket"))
  {
    self.log = log
  }
  
  @discardableResult
  public func onRequest(execute:
                @escaping ( IncomingMessage, ServerResponse ) -> Void) -> Self
  {
    return self
  }
  
  func resume() {
    log.error("Attempt to use SocketMode on unsupported platform")
    assertionFailure("Attempt to use SocketMode on unsupported platform")
  }
  func suspend() {}
}

#endif // !canImport(Network)
