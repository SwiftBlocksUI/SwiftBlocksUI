//
//  ParseInteractiveRequest.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct    Logging.Logger
import typealias MacroExpress.Middleware
import typealias MacroExpress.Next
import class     MacroExpress.IncomingMessage
import class     MacroExpress.ServerResponse
import enum      MacroExpress.bodyParser
import class     MacroExpress.Route
import func      MacroExpress.typeIs
import enum      SlackBlocksModel.InteractiveRequest
import protocol  SlackBlocksModel.StringID
import protocol  MacroCore.EnvironmentKey

public extension bodyParser {

  /**
   * Middleware which parses `InteractiveRequest` objects into the
   * respective `IncomingRequest` field (and an error in an error property):
   *
   * IncomingMessage properties:
   * - interactiveRequest
   * - interactiveRequestError
   *
   * Example:
   *
   *     app.post(bodyParser.interactiveRequest())
   *     app.post { req, res, next in
   *       console.log("interactive request:", req.interactiveRequest)
   *     }
   *
   */
  @inlinable
  static func interactiveRequest() -> Middleware {
    return Route(id: nil, pattern: nil, method: .POST, middleware: [
      bodyParser.urlencoded(), // make sure this has run
      { req, res, next in
        try parseInteractiveRequest(req: req, res: res)
        next()
      }
    ])
    .middleware
  }

  @inlinable
  static func parseInteractiveRequest(req  : IncomingMessage,
                                      res  : ServerResponse) throws
  {
    guard req.interactiveRequest      == nil
       && req.interactiveRequestError == nil else { return } // parsed
    
    guard req.is("application/x-www-form-urlencoded") else {
      return
    }
    
    // Skip Slash commands
    guard req.body[string: "command"].isEmpty else { return }
    
    // But we need a payload
    // TBD: further validate payload by pre-parsing the JSON? Depends
    //       whether we have further endpoints I guess.
    let payload = req.body[string: "payload"]
    guard !payload.isEmpty else { return }
    
    let request : InteractiveRequest
    do {
      request = try InteractiveRequest.from(json: payload)
      request.addInfoToLogger(&req.log)
      req.interactiveRequest = request
    }
    catch {
      req.interactiveRequestError = error
      req.log.error(
        "failed to parse payload: \(req.body[string: "payload"]) \(error)")
      throw error
    }
  }
}

extension InteractiveRequest {
  
  @usableFromInline
  func addInfoToLogger(_ logger: inout Logger) {
    func add<V: StringID>(_ key: String, _ value: V?) {
      guard let value = value else { return }
      logger[metadataKey: key] = .string(value.id)
    }
    
    add("slack-user-id"    , userID)
    add("slack-team-id"    , teamID)
    add("slack-app-id"     , applicationID)
    add("slack-cb-id"      , callbackID)
    add("slack-trigger-id" , triggerID)
    add("slack-view-id"    , viewInfo?.id)
    
    switch container {
      case .none, .some(.view): break
      case .some(.message(let mid, let cid, let isEphemeral)):
        add("slack-channel-id", cid)
        logger[metadataKey: "slack-container"] =
          .string("\(mid.id)\(isEphemeral ? "E" : "")")
      case .some(.contextMessage(let mid, let cid, let isEphemeral)):
        add("slack-channel-id", cid)
        logger[metadataKey: "slack-container"] =
          .string("ctx=\(mid.id)\(isEphemeral ? "E" : "")")
    }
  }
}

enum SlackInteractiveRequestKey: EnvironmentKey {
  static let defaultValue : InteractiveRequest? = nil
  static let loggingKey   = "slack-ir"
}
enum SlackInteractiveRequestErrorKey: EnvironmentKey {
  static let defaultValue : Swift.Error? = nil
  static let loggingKey   = "slack-ir-error"
}

public extension IncomingMessage {

  var interactiveRequestError: Swift.Error? {
    set { environment[SlackInteractiveRequestErrorKey.self] = newValue }
    get { return environment[SlackInteractiveRequestErrorKey.self]     }
  }
}

public extension IncomingMessage {
  
  var interactiveRequest: InteractiveRequest? {
    set { environment[SlackInteractiveRequestKey.self] = newValue }
    get { return environment[SlackInteractiveRequestKey.self]     }
  }
}
