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
   *
   * This will log the blocks data in combination with those two environment
   * variables:
   * - `blocks.log.blocks`      (generated API blocks structure)
   * - `blocks.log.blocks.json` (raw JSON)
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

    logBlocks(apiBlocks)
    
    // TODO: Also render blocks as markdown. Quite possible!
    let message = MessageResponse(responseType : scope,
                                  blocks       : apiBlocks)
    
    logJSON(message)
    send(message)
  }
}


// MARK: - Logging

import enum Macro.process

private let doLogBlocks = process.getenvflag("blocks.log.blocks")

extension ServerResponse {
  
  internal func logBlocks(_ apiBlocks: [ Block ]) {
    guard doLogBlocks else { return }
    
    let s = apiBlocks.map({ "  " + $0.description })
                     .joined(separator: "\n")
    log.log("Blocks:\n\(s)")
  }
}


import class Foundation.JSONEncoder

private let doLogBlocksJSON = process.getenvflag("blocks.log.blocks.json")

extension ServerResponse {
  
  internal func logJSON<E: Encodable>(_ object: E) {
    guard doLogBlocksJSON else { return }
    
    do {
      let data = try JSONEncoder().encode(object)
      if let s = String(data: data, encoding: .utf8) {
        log.log("\n-----JSON-----\n\(s)\n------JSON------")
      }
      else if data.isEmpty {
        log.warn("JSON: empty body")
      }
      else {
        log.error("Could not grab JSON data as String?", data)
      }
    }
    catch {
      log.error("Could not render object as JSON:", object, error)
      assertionFailure("invalid JSON blocks: \(error)")
    }
  }
}
