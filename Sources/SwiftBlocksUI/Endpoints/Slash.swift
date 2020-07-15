//
//  Slash.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class    MacroApp.ServerResponse
import protocol MacroApp.Endpoints
import protocol MacroApp.RouteKeeper
import struct   SlackBlocksModel.SlashRequest
import struct   SlackBlocksModel.MessageResponse
import protocol Blocks.Blocks
import struct   Blocks.BlocksBuilder

/**
 * Hooks up to a Slash command.
 */
public struct Slash<Content: Blocks>: Endpoints {

  public typealias Handler = ( SlashRequest, ServerResponse ) throws -> Void

  public let id      : String?
  public let command : String?
  public let handler : Handler
  
  public let content : (( ) -> Content)?
  public let scope   : MessageResponse.ResponseType?

  @inlinable
  public func attachToRouter(_ router: RouteKeeper) throws {
    router.slash(id: id, command, handler)
    
    if let content = content?() { // to handle events coming back to this!
      router.use(interactiveBlocks { content })
    }
  }
}

extension Slash {

  /**
   * A Slash endpoint backed by blocks.
   *
   * This will send the blocks as a result to the Slash commands,
   * and it will process block actions coming back to interactive
   * elements within the block.
   *
   * Example:
   *
   *     Slash("/vaca") {
   *       Text(cows.vaca())
   *       Button("Click me") {
   *         console.log("button clicked!")
   *       }
   *     }
   *
   * - Parameter id: ID of the route in the middleware stack (debugging).
   * - Parameter command:
   *     The name of the slash command as registered in the Slack admin panel.
   * - Parameter scope:
   *     The scope of the message sent (.userOnly or .inConversation).
   * - Parameter handleBlockActions:
   *     Whether the blocks should also be registered for handling block actions
   *     (defaults to true).
   * - Parameter content: The blocks to be built.
   */
  public init(id                 : String? = nil,
              _ command          : String? = nil,
              scope              : MessageResponse.ResponseType = .userOnly,
              handleBlockActions : Bool = true,
              @BlocksBuilder content: @escaping () -> Content)
  {
    self.id      = id
    self.command = command
    self.scope   = scope
    self.content = handleBlockActions ? content : nil
    self.handler = { req, res in
      res.sendMessage(scope: scope) {
        content()
          .slashEnvironment(req)
      }
    }
  }
}

extension Slash where Content == Never {
  
  /**
   * A Slash endpoint backed by a simple `SlashRequest` / `ServerResponse`
   * closure.
   *
   * Example:
   *
   *     Slash("/vaca") { req, res in
   *       res.sendMessage(scope: scope) {
   *         Text(cows.vaca())
   *       }
   *     }
   *
   * - Parameter id: ID of the route in the middleware stack (debugging).
   * - Parameter command:
   *     The name of the slash command as registered in the Slack admin panel.
   * - Parameter execute: The handler to call when the command is triggered.
   */
  @inlinable
  public init(id        : String? = nil,
              _ command : String? = nil,
              execute   : @escaping Handler)
  {
    self.id      = id
    self.command = command
    self.handler = execute
    self.scope   = nil
    self.content = nil
  }
}
