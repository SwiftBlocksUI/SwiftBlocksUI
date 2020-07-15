//
//  AnyBlocks.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public struct AnyBlocks: Blocks, BlocksPrimitive {
  
  public typealias Body = Never
  
  private let erasedRender : ( BlocksContext ) throws -> Void
  
  public init<B: Blocks>(_ blocks: B) {
    self.erasedRender = { context in
      try context.render(blocks)
    }
  }
  public init<B: Blocks & BlocksPrimitive>(_ blocks: B) {
    self.erasedRender = { context in
      try blocks.render(in: context)
    }
  }

  public func render(in context: BlocksContext) throws {
    try erasedRender(context)
  }
}
