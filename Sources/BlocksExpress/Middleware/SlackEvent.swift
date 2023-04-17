//
//  SlackEvent.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020-2023 ZeeZide GmbH. All rights reserved.
//

import enum      MacroExpress.bodyParser
import protocol  MacroExpress.RouteKeeper
import typealias MacroExpress.Middleware
import class     SlackBlocksModel.SlackEvent
import NIOHTTP1

public extension RouteKeeper {
  
  /**
   * Registers a middleware to execute for Slack events, specific ones
   * can be requested using the `type` parameter.
   *
   * Note that events must be confirmed w/ a 200 response as quickly as
   * possible.
   *
   * Example:
   *
   *     app.slackEvent(type: .message) { req, res, next in
   *       console.log("got a message:", req.slackEvent?.payload)
   *       res.sendStatus(200)
   *     }
   *
   * The middleware also handles token verification (by default using the
   * `verifyToken` function, which checks the `SLACK_VERIFICATION_TOKEN`
   * environment variable).
   */
  @inlinable
  @discardableResult
  func slackEvent(id        : String? = nil,
                  _ pattern : String? = nil,
                  type requiredType: SlackEvent.EventType? = nil,
                  verify    : @escaping ( String ) -> Bool
                            = verifyToken(allowUnsetInDebug: true),
                  execute : @escaping Middleware)
       -> Self
  {
    add(route: .init(id: id, pattern: pattern, method: .POST, middleware: [
      bodyParser.slackEvent(), // make sure the parser has run
      
      { req, res, next in
        
        guard let event = req.slackEvent else { return next() }
        
        if let requiredType = requiredType {
          guard event.type == requiredType else { return next() }
        }
        
        guard verify(event.token.value) else {
          let msg = "event token verification failed: "
                  + "\(event.token.value) \(event.applicationID.id)"
          req.log.error(msg)
          return res.sendStatus(404) // TBD
        }
        
        try execute(req, res, next)
      }
    ]))
    return self
  }
}
