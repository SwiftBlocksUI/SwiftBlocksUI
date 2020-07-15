//
//  SectionPrimitives.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension Section: BlocksPrimitive {

  typealias APIBlock = Block.Section

  public func render(in context: BlocksContext) throws {
    context.startBlock(.section(.init(id   : context.blockID(for: self),
                                      text : Block.Text(""))))
    defer { context.closeBlock() }
    
    try context.render(content)
  }
}

extension Field: BlocksPrimitive {
  
  public func render(in context: BlocksContext) throws {
    if let block = context.currentBlock {
      if case .section(var section) = block {
        context.startLevelTwo(.field); defer { context.endLevelTwo() }
        context.currentBlock = nil // CoW ARC
        section.fields.append(Block.Text(""))
        context.currentBlock = .section(section)
        
        try context.render(content)
      }
      else { // auto-open Section
        try context.render(Section(content: { return self }))
      }
    }
    else if case .section = context.blocks.last {
      // was the last a section, if so, add to it
      context.log.warning(
        "Adding Field to last Section block, please fix the nesting!")
      assert(context.currentBlock == nil)
      _ = context.reopenLastBlock()
      try render(in: context)
    }
    else { // auto-open new Section
      try context.render(Section(content: { return self }))
    }
  }
}
