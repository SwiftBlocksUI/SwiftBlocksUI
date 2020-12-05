//
//  Interactive.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import typealias MacroExpress.Middleware
import typealias MacroExpress.Next
import class     MacroExpress.IncomingMessage
import class     MacroExpress.ServerResponse
import protocol  MacroExpress.RouteKeeper
import class     MacroExpress.Route
import enum      MacroExpress.bodyParser
import func      MacroExpress.typeIs
import enum      SlackBlocksModel.InteractiveRequest
import struct    SlackBlocksModel.CallbackID

public extension RouteKeeper {
  
  typealias ViewSubmission = InteractiveRequest.ViewSubmission
  typealias Shortcut       = InteractiveRequest.Shortcut
  typealias MessageAction  = InteractiveRequest.MessageAction

  // TBD: The results of those are more specific? (i.e. should they work on the
  //      ServerResponse, or return the valid results in a typed way?).
  
  /**
   * A middleware which can process Slack "view submissions", i.e. when the
   * submit action of a Slack view (aka modal) is performed.
   *
   * Note that view submissions do have an associated "Callback ID", but it
   * isn't statically registered in the app configuration. It's just an
   * arbitrary ID the app itself can choose and set for later dispatch.
   *
   * Calls `next` if the request does not contain a Slack view submission.
   *
   * The handler receives an `ViewSubmission` object (a struct containing all
   * the associated data).
   *
   * Note: The SwiftBlocksUI endpoint block is `ViewSubmission` (rarely
   *       necessary).
   *
   * - Parameters:
   *   - id         : An ID to assign to the route, for debugging purposes (nil)
   *   - execute    : The request handler
   */
  @inlinable
  @discardableResult
  func viewSubmission(id        : String? = nil,
                      _ execute : @escaping
                        ( ViewSubmission, ServerResponse ) throws -> Void)
       -> Self
  {
    interactiveRequest(id: id) { req, res, next in
      guard case .viewSubmission(let ctx) = req else { return next() }
      try execute(ctx, res)
    }
  }
  
  /**
   * A middleware which can process Slack "global shortcuts" (the things which
   * appear in the lightning button on the left side of the message compose
   * textfield).
   *
   * Shortcuts (including their "Callback ID") are registered globally in the
   * Slack app configuration.
   *
   * Calls `next` if the request does not contain a Slack shortcut action.
   *
   * The handler receives an `Shortcut` object (a struct containing all
   * the associated data).
   *
   * Note: Global shortcuts do *not* receive the active channel (as the name
   *       says, they are global, even though the UI suggests differently, and
   *       contains channel specific actions (e.g. slash commands) as well).
   *
   * Note: The SwiftBlocksUI endpoint block is `Shortcut`.
   *
   * See also: https://api.slack.com/interactivity/shortcuts/using
   *
   * - Parameters:
   *   - id         : An ID to assign to the route, for debugging purposes (nil)
   *   - callbackID : If available, only call the handler if the the ID matches,
   *                  otherwise invoke `next`.
   *   - execute    : The request handler
   */
  @inlinable
  @discardableResult
  func shortcut(id           : String? = nil,
                _ callbackID : CallbackID? = nil,
                _ execute    : @escaping
                               ( Shortcut, ServerResponse ) throws -> Void)
       -> Self
  {
    interactiveRequest(id: id) { req, res, next in
      guard case .shortcut(let ctx) = req else { return next() }
      try execute(ctx, res)
    }
  }
  
  /**
   * A middleware which can process Slack "message actions". Also called
   * "message shortcuts".
   *
   * Message actions (including their "Callback ID") are registered globally in
   * the Slack app configuration.
   *
   * Calls `next` if the request does not contain a Slack message action.
   *
   * The handler receives an `MessageAction` object (a struct containing all
   * the associated data).
   *
   * Note: The SwiftBlocksUI endpoint block is `MessageAction`.
   *
   * See also: https://api.slack.com/interactivity/shortcuts/using
   *
   * - Parameters:
   *   - id         : An ID to assign to the route, for debugging purposes (nil)
   *   - callbackID : If available, only call the handler if the the ID matches,
   *                  otherwise invoke `next`.
   *   - execute    : The request handler
   */
  @inlinable
  @discardableResult
  func messageAction(id           : String?     = nil,
                     _ callbackID : CallbackID? = nil,
                     _    execute : @escaping
                       ( MessageAction, ServerResponse ) throws -> Void)
       -> Self
  {
    interactiveRequest(id: id, callbackID) { req, res, next in
      guard case .messageAction(let ctx) = req else { return next() }
      try execute(ctx, res)
    }
  }
  
  /**
   * A middleware which can process all kinds of Slack "interactive requests":
   * shortcuts, view events, block actions.
   *
   * Calls `next` if the request does not contain a Slack interactive request.
   *
   * The handler receives an `InteractiveRequest` object (an enum with the
   * various options, from shortcuts to view-close).
   *
   * Note: The SwiftBlocksUI pair is `interactiveBlocks`.
   *
   * - Parameters:
   *   - id         : An ID to assign to the route, for debugging purposes (nil)
   *   - callbackID : If available, only call the handler if the the IDs match
   *                  (Note that not all interactive requests have explicit
   *                   callback IDs! E.g. block actions don't, shortcuts do)
   *   - execute    : The request handler
   */
  @inlinable
  @discardableResult
  func interactiveRequest(id           : String?     = nil,
                          _ callbackID : CallbackID? = nil,
                          _ execute    : @escaping
                          ( InteractiveRequest, ServerResponse,
                            Next ) throws -> Void)
       -> Self
  {
    // TBD: cache parsed request?
    add(route: Route(id: id, pattern: nil, method: .POST, middleware: [
      bodyParser.interactiveRequest(), // make sure this parser has run
      
      { req, res, next in
        guard let request = req.interactiveRequest else { return next() }
        
        // Note: Not all interactive requests have explicit callback IDs!
        if let callbackID = callbackID, callbackID != request.callbackID {
          return next()
        }
        
        try execute(request, res, next)
      }
    ]))
    return self
  }
}
