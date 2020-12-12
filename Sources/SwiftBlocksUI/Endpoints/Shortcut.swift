//
//  Shortcut.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class    MacroApp.ServerResponse
import protocol MacroApp.Endpoints
import protocol MacroApp.RouteKeeper
import enum     SlackBlocksModel.Block
import enum     SlackBlocksModel.InteractiveRequest
import struct   SlackBlocksModel.CallbackID
import struct   SlackBlocksModel.MessageResponse

/**
 * A _global_ shortcut endpoint, those are configured (the name etc) in the
 * Slack admin panel and appear in the global shortcuts menu in the client
 * (the "lightning" button left of the message field).
 *
 * It is similar to a slash command, but can't have arguments,
 * and DOES NOT have access to the active conversation.
 *
 * There is also `MessageAction`, which is a shortcut being used in a message
 * context (i.e. appears in the context menu for a message).
 *
 * Global shortcuts have little context and need to resort to API calls to
 * create messages or modals (the latter is recommended).
 *
 * Docs: https://api.slack.com/interactivity/shortcuts/using
 */
public struct Shortcut<Content: Blocks>: Endpoints {
  
  public typealias Handler =
    ( InteractiveRequest.Shortcut, ServerResponse ) throws -> Void
  
  public let id         : String?
  public let callbackID : CallbackID?
  public let handler    : Handler
  public let content    : (( ) -> Content)?
  public let scope      : MessageResponse.ResponseType?

  @inlinable
  public func attachToRouter(_ router: RouteKeeper) throws {
    router.shortcut(id: id, callbackID, handler)

    if let content = content?() { // to handle events coming back to this!
      router.use(interactiveBlocks { content })
    }
  }
}

extension Shortcut {

  /**
   * A Shortcut endpoint backed by Blocks.
   *
   * This will send the blocks as a result to the Shortcut,
   * and it will process block actions coming back to interactive
   * elements within the block.
   *
   * Example:
   *
   *     Shortcut("vaca-shortcut") {
   *       Text(cows.vaca())
   *       Button("Click me") {
   *         console.log("button clicked!")
   *       }
   *     }
   *
   * - Parameter id: ID of the route in the middleware stack (debugging).
   * - Parameter callbackID:
   *     The callback ID for this Shortcut as registered in the Slack admin
   *     panel.
   * - Parameter scope:
   *     The scope of the message sent (.userOnly or .inConversation).
   * - Parameter handleBlockActions:
   *     Whether the blocks should also be registered for handling block actions
   *     (defaults to true).
   * - Parameter content: The blocks to be built.
   */
  public init(id                 : String?                      = nil,
              _ callbackID       : CallbackID?                  = nil,
              scope              : MessageResponse.ResponseType = .userOnly,
              handleBlockActions : Bool                         = true,
              @BlocksBuilder content: @escaping () -> Content)
  {
    self.id         = id
    self.callbackID = callbackID
    self.scope      = scope
    self.content    = handleBlockActions ? content : nil
    
    self.handler = { req, res in
      
      let blocks = content().shortcutEnvironment(req)
      
      let response = BlocksEndpointResponse(
        requestContainer: nil, responseURL: nil,
        triggerID: req.triggerID, userID: req.user.id,
        accessToken: res.request?.slackAccessToken ?? "", // FIXME
        response: res, blocks: blocks
      )
      
      response.push(blocks)
    }
  }
}

extension Shortcut where Content == Never {
  
  /**
   * A Shortcut endpoint backed by a simple handler.
   *
   * Example:
   *
   *     Shortcut("vaca-shortcut") { req, res in
   *       ...
   *     }
   *
   * - Parameter id: ID of the route in the middleware stack (debugging).
   * - Parameter callbackID:
   *     The callback ID for this Shortcut as registered in the Slack admin
   *     panel.
   * - Parameter execute: The handler to call if a Shortcut matches.
   */
  @inlinable
  public init(id           : String? = nil,
              _ callbackID : CallbackID? = nil,
              execute      : @escaping Handler)
  {
    self.id         = id
    self.callbackID = callbackID
    self.handler    = execute
    self.content    = nil
    self.scope      = nil
  }
}
