//
//  SocketModeIncomingMessage.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

#if canImport(Network)

import class  Foundation.JSONSerialization
import struct Logging.Logger
import struct NIOHTTP1.HTTPHeaders
import struct NIOHTTP1.HTTPRequestHead
import struct Macro.Buffer
import class  Macro.IncomingMessage
import enum   MacroExpress.querystring

extension IncomingMessage {
  
  /**
   * Reconstruct an HTTP version of an incoming socket mode request.
   */
  convenience init?(slackType : String, payload : [ String : Any ],
                    path      : String,
                    log       : Logger = .init(label: "μ.http"))
  {
    // It feels a little stupid, but does the job :-) We don't have to touch
    // anything else this way. Do not use in production!
    var headers = HTTPHeaders()
    let body    : Buffer?
    
    switch slackType {
    
      case "slash_commands":
        headers.add(name: "Content-Type",
                    value: "application/x-www-form-urlencoded")
        let s = querystring.stringify(payload)
        body = Buffer(s)
        
      case "interactive":
        headers.add(name: "Content-Type",
                    value: "application/x-www-form-urlencoded")
        do {
          let payloadData = try JSONSerialization
                        .data(withJSONObject: payload, options: [])
          let payloadString = String(data: payloadData, encoding: .utf8) ?? ""
          let s = querystring.stringify([ "payload": payloadString ])
          body = Buffer(s)
        }
        catch {
          log.error("Failed to serialize JSON:", payload)
          return nil
        }
        
      default:
        log.error("Unsupported Slack socket event type:", slackType)
        return nil
    }
    
    let head = HTTPRequestHead(
      version : .init(major: 1, minor: 1),
      method  : .POST,
      uri     : path,
      headers : headers
    )
    
    self.init(head, socket: nil, log: log)
    
    if let buffer = body {
      push(buffer)
    }
    push(nil)
  }
}

#endif // canImport(Network)
