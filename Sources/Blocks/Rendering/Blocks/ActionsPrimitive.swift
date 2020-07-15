//
//  ActionsPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension Actions: BlocksPrimitive {

  typealias APIBlock = Block.Actions

  public func render(in context: BlocksContext) throws {
    context.startBlock(.actions(.init(id: context.blockID(for: self),
                                      elements: [])))
    defer {
      if case .actions(let actions) = context.currentBlock,
         actions.elements.isEmpty
      {
        context.currentBlock = nil
        context.log.notice("dropping empty Actions block ...")
      }
      else {
        context.closeBlock()
      }
    }
    
    try context.render(content)
  }
}
