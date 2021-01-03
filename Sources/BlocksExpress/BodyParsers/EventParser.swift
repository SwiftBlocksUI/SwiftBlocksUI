//
//  EventParser.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct    Foundation.Date
import struct    Foundation.TimeInterval
import typealias MacroExpress.Middleware
import typealias MacroExpress.Next
import class     MacroExpress.IncomingMessage
import class     MacroExpress.ServerResponse
import enum      MacroExpress.bodyParser
import class     MacroExpress.Route
import func      MacroExpress.typeIs
import class     SlackBlocksModel.SlackEvent
import protocol  MacroCore.EnvironmentKey


public extension bodyParser {

  /**
   * Middleware which parses `SlackEvent` objects into the respective
   * `slackEvent` field.
   *
   * SlackEvent properties on `IncomingMessage` (either will be set):
   * - slackEvent
   * - slackEventError
   *
   * Example:
   *
   *     app.post(bodyParser.slackEvent())
   *     app.post { req, res, next in
   *       console.log("slackEvent:", req.slackEvent)
   *     }
   *
   */
  @inlinable
  static func slackEvent() -> Middleware {
    return Route(id: nil, pattern: nil, method: .POST, middleware: [
      bodyParser.json(), // make sure this has run
      
      { req, res, next in
        guard req.slackEvent == nil && req.slackEventError == nil else {
          return next() // parsed already
        }
        
        guard typeIs(req, [ "json" ]) != nil,
              let json  = req.body.json as? [ String : Any ],
              let type  = json["type"]  as? String,
              let token = json["token"] as? String else
        {
          req.slackEventError = SlackEventError.notASlackEvent
          return next()
        }
        
        // MARK: - Handle URL verification event in here
        
        if type == "url_verification" {
          req.log.info("handling URL verification for token: \(token)")
          return res.send(req.body[string: "challenge"])
        }
        
        guard let event = SlackEvent(json: json) else {
          req.log.warning("could not parse Slack event of type \(type)")
          req.slackEventError = SlackEventError.couldNotParseEvent
          return next()
        }

        req.log.debug("successfully parsed Slack event")
        req.slackEvent = event
        next()
      }
    ])
    .middleware
  }
  
  @usableFromInline
  internal enum SlackEventError: Swift.Error {
    case notASlackEvent
    case couldNotParseEvent
  }
}


enum SlackEventKey: EnvironmentKey {
  static let defaultValue : SlackEvent? = nil
  static let loggingKey   = "slack-event"
}
enum SlackEventErrorKey: EnvironmentKey {
  static let defaultValue : Swift.Error? = nil
  static let loggingKey   = "slack-event-error"
}

public extension IncomingMessage {
  
  var slackEvent: SlackEvent? {
    set { environment[SlackEventKey.self] = newValue }
    get { return environment[SlackEventKey.self]     }
  }
  
  var slackEventError: Swift.Error? {
    set { environment[SlackEventErrorKey.self] = newValue }
    get { return environment[SlackEventErrorKey.self]     }
  }
}
