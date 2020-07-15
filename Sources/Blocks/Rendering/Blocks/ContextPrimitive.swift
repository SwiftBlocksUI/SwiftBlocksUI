//
//  ContextPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension Context: BlocksPrimitive {

  typealias APIBlock = Block.Context

  public func render(in context: BlocksContext) throws {
    context.startBlock(.context(.init(id: context.blockID(for: self),
                                      elements: [])))
    defer { context.closeBlock() }
    
    try context.render(content)
  }
}
