//
//  HeaderPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension Header: BlocksPrimitive {

  typealias APIBlock = Block.Header
  
  public func render(in context: BlocksContext) throws {
    context.startBlock(.header(.init(id: context.blockID(for: self),
                                     text: .init(""))))
    defer { context.closeBlock() }
    
    try context.render(content)
  }
}
