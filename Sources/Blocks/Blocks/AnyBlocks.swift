//
//  AnyBlocks.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A type eraser for Blocks.
 *
 * Can be used to mix & match Blocks of different static types.
 *
 * Example:
 *
 *     var activeBlocks : AnyBlocks {
 *       switch status {
 *         case "order" : return AnyBlocks(OrderStatus())
 *         case "home"  : return AnyBlocks(HomePage())
 *       }
 *     }
 *     var body: some View {
 *       Section {
 *         activeBlocks
 *       }
 *     }
 */
public struct AnyBlocks: Blocks {
  
  public typealias Body = Never
  
  fileprivate let erasedRender : ( BlocksContext ) throws -> Void
  
  public init<B: Blocks>(_ blocks: B) {
    self.erasedRender = { context in
      try context.render(blocks)
    }
  }
  
  public init<B: Blocks>(@BlocksBuilder content: () -> B) {
    let blocks = content()
    self.erasedRender = { context in
      try context.render(blocks)
    }
  }
  
  public init<B: Blocks & BlocksPrimitive>(_ blocks: B) {
    self.erasedRender = { context in
      try blocks.render(in: context)
    }
  }
}

extension AnyBlocks: BlocksPrimitive {
  
  public func render(in context: BlocksContext) throws {
    try erasedRender(context)
  }
}
