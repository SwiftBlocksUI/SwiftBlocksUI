//
//  MessageAction.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import typealias MacroApp.Next
import class     MacroApp.ServerResponse
import protocol  MacroApp.Endpoints
import protocol  MacroApp.RouteKeeper
import enum      SlackBlocksModel.InteractiveRequest
import struct    SlackBlocksModel.CallbackID
import BlocksExpress

/**
 * A message shortcut endpoint, those are configured (the name etc) in the
 * Slack admin panel and appear in the message context menu in the client
 * (within the "More Actions" button).
 *
 * This does get the message content and associated meta data upon action.
 *
 * There is also `Shortcut`, which is a global shortcut accessible using the
 * "Lightning" button left of the message input field.
 *
 * This information is available using either the request, or respective
 * Environment keys within Blocks:
 * - team
 * - user
 * - conversation
 * - message
 *
 * For example to access the content of the message being worked on:
 *
 *     struct MessageHandler: Blocks {
 *
 *       @State(\.messageText) var messageText
 *
 *       var body: some View {
 *         Text(verbatim: messageText)
 *       }
 *     }
 *
 * Docs: https://api.slack.com/interactivity/shortcuts/using
 */
public struct MessageAction<Content: Blocks>: Endpoints {
  
  public typealias Handler =
    ( InteractiveRequest.MessageAction, ServerResponse ) throws -> Void
  
  public let id         : String?
  public let callbackID : CallbackID?
  public let handler    : Handler
  public let content    : (( ) -> Content)?
  public let scope      : MessageResponse.ResponseType?

  @inlinable
  public func attachToRouter(_ router: RouteKeeper) throws {
    router.messageAction(id: id, callbackID, handler)
    
    if let content = content?() { // to handle events coming back to this!
      router.use(interactiveBlocks { content })
    }
  }
}

extension MessageAction where Content == Never {
  
  /**
   * A message shortcut endpoint backed by a simple handler.
   *
   * Example:
   *
   *     MessageAction("clipit") { req, res in
   *       ...
   *     }
   *
   * - Parameter id: ID of the route in the middleware stack (debugging).
   * - Parameter callbackID:
   *     The callback ID for this Shortcut as registered in the Slack admin
   *     panel.
   * - Parameter execute: The handler to call if a shortcut matches.
   */
  @inlinable
  public init(id           : String?     = nil,
              _ callbackID : CallbackID? = nil,
              _    execute : @escaping Handler)
  {
    self.id         = id
    self.callbackID = callbackID
    self.handler    = execute
    self.content    = nil
    self.scope      = nil
  }
}

public extension MessageAction {
  
  /**
   * Respond to a Message Action w/ Blocks.
   *
   * If the Blocks contain a View, the View will be opened.
   * Otherwise a message will be sent.
   */
  @inlinable
  init(id                     : String? = nil,
       _           callbackID : CallbackID? = nil,
       scope                  : MessageResponse.ResponseType = .userOnly,
       handleBlockActions     : Bool                         = true,
       @BlocksBuilder content : @escaping () -> Content)
  {
    self.id         = id
    self.callbackID = callbackID
    self.scope      = scope
    self.content    = handleBlockActions ? content : nil
    
    self.handler = { action, res in
      let blocks = content().messageActionEnvironment(action)

      let response = BlocksEndpointResponse(
        requestContainer: action.container, responseURL: action.responseURL,
        triggerID: action.triggerID, userID: action.user.id,
        accessToken: res.request?.slackAccessToken ?? "", // FIXME
        response: res, blocks: blocks
      )
      response.push(blocks)
    }
  }
}
