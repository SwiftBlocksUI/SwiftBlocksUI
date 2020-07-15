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

  // TODO: the results of those are more specific?
  
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
      bodyParser.interactiveRequest(), // make sure this has run
      { req, res, next in
        guard let request = req.interactiveRequest else { return next() }
        if let callbackID = callbackID, callbackID != request.callbackID {
          return next()
        }
        try execute(request, res, next)
      }
    ]))
    return self
  }
}
