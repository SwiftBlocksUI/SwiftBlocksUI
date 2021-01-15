//
//  EventParser.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct    Logging.Logger
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
import protocol  SlackBlocksModel.StringID
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
        
        guard req.is("json"),
              let json  = req.body.json as? [ String : Any ],
              let type  = json["type"]  as? String,
              let token = json["token"] as? String else
        {
          req.slackEventError = SlackEventError.notASlackEvent
          return next()
        }
        req.log[metadataKey: "slack-event-type"] = .string(type)

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

        event.addInfoToLogger(&req.log)
        event.addInfoToLogger(&res.log)
        req.log.debug("successfully parsed Slack event")
        req.slackEvent = event
        next()
      }
    ])
    .middleware
  }
  
  @usableFromInline
  internal enum SlackEventError: Swift.Error, CustomStringConvertible {
    
    case notASlackEvent
    case couldNotParseEvent
    
    @inlinable
    public var description: String {
      switch self {
        case .notASlackEvent     : return "<Error: notASlackEvent>"
        case .couldNotParseEvent : return "<Error: couldNotParseEvent>"
      }
    }
  }
}

extension SlackEvent {
  
  @usableFromInline
  func addInfoToLogger(_ logger: inout Logger) {
    func add<V: StringID>(_ key: String, _ value: V?) {
      guard let value = value else { return }
      logger[metadataKey: key] = .string(value.id)
    }
    
    add("slack-user-id" , userID)
    add("slack-team-id" , teamID)
    add("slack-app-id"  , applicationID)
    logger[metadataKey: "slack-event-type"] = .string(type.rawValue)
    logger[metadataKey: "slack-event-id"]   = .string(eventID)
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
