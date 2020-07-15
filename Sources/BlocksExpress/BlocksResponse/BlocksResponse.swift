//
//  BlocksResponse.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class    http.ServerResponse
import protocol Blocks.Blocks
import class    Blocks.BlocksContext
import struct   Blocks.BlocksBuilder
import struct   SlackBlocksModel.MessageResponse
import enum     SlackBlocksModel.Block

public extension ServerResponse {
  
  /**
   * Builds the given Blocks and sends them as a message.
   *
   * Can be used w/ slash commands, but NOT w/ Shortcuts. They need to send
   * messages using the SlackClient APIs.
   */
  func sendMessage<B: Blocks>(scope: MessageResponse.ResponseType = .userOnly,
                              @BlocksBuilder blocks: () -> B)
  {
    let blocks    = blocks()
    let apiBlocks : [ Block ]
    do {
      let ctx = BlocksContext()
      try ctx.render(blocks)
      apiBlocks = ctx.blocks
    }
    catch {
      log.error("Failed to render blocks: \(blocks)\n  error: \(error)")
      return sendStatus(500)
    }
    
    // TODO: Also render blocks as markdown. Quite possible!
    let message = MessageResponse(responseType : scope,
                                  blocks       : apiBlocks)
    send(message)
  }
}
