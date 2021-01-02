//
//  Event.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import typealias MacroExpress.Middleware
import class     MacroApp.ServerResponse
import protocol  MacroApp.Endpoints
import protocol  MacroApp.RouteKeeper
import class     SlackBlocksModel.SlackEvent

/**
 * Hooking into Slack Events.
 */
public struct Event: Endpoints {
  
  // TODO: improve the handler, pass in the event?
  //       but we have the usual issue that we'd also like the original request?
  
  public typealias Handler = Middleware
  
  public let id      : String?
  public let type    : SlackEvent.EventType?
  public let handler : Handler
  
  @inlinable
  public func attachToRouter(_ router: RouteKeeper) throws {
    router.slackEvent(id: id, type: type, execute: handler)
  }
}

extension Event {

  /**
   * A Slack Event endpoint.
   *
   * Example:
   *
   *     Event(.app_rate_limited) { req, res, next in
   *         res.log.warning("our app got rate limited!")
   *         return res.sendStatus(200)
   *     }
   *
   * - Parameter id: ID of the route in the middleware stack (debugging).
   * - Parameter type:
   *     The event type to list for (or nil to catch all events).
   */
  public init(id : String? = nil, _ type : SlackEvent.EventType? = nil,
              _ execute: @escaping Middleware)
  {
    self.id      = id
    self.type    = type
    self.handler = execute
  }
}
