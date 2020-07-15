//
//  BlocksPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public protocol BlocksPrimitive {
  
  func render(in context: BlocksContext) throws
}

extension BlocksBuilder.Empty: BlocksPrimitive {
  public func render(in context: BlocksContext) throws {}
}

extension BlocksBuilder.IfElse: BlocksPrimitive {
  
  public func render(in context: BlocksContext) throws {
    context.enterConditional(true)
    defer { context.leaveConditional() }
    
    switch content {
      case .first (let blocks): try context.render(blocks)
      case .second(let blocks): try context.render(blocks)
    }
  }
}

extension Optional: BlocksPrimitive where Wrapped: Blocks {
  
  public func render(in context: BlocksContext) throws {
    switch self {
      case .some(let blocks): try context.render(blocks)
      case .none: return
    }
  }
}

extension Group: BlocksPrimitive where Content: BlocksPrimitive{
  public func render(in context: BlocksContext) throws {
    try content.render(in: context)
  }
}


// Lots of boilerplate :-) Should be generated, but well, we only really do
// this once.

extension Tuple2: BlocksPrimitive where T1: Blocks, T2: Blocks {
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 2); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
  }
}

extension Tuple3: BlocksPrimitive where T1: Blocks, T2: Blocks, T3: Blocks {
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 3); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
    try context.render(value3); context.processedTupleElement(at: 2)
  }
}

extension Tuple4: BlocksPrimitive where T1: Blocks, T2: Blocks, T3: Blocks,
                                        T4: Blocks
{
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 4); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
    try context.render(value3); context.processedTupleElement(at: 2)
    try context.render(value4); context.processedTupleElement(at: 3)
  }
}

extension Tuple5: BlocksPrimitive where T1: Blocks, T2: Blocks, T3: Blocks,
                                        T4: Blocks, T5: Blocks
{
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 5); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
    try context.render(value3); context.processedTupleElement(at: 2)
    try context.render(value4); context.processedTupleElement(at: 3)
    try context.render(value5); context.processedTupleElement(at: 4)
  }
}

extension Tuple6: BlocksPrimitive where T1: Blocks, T2: Blocks, T3: Blocks,
                                        T4: Blocks, T5: Blocks, T6: Blocks
{
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 6); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
    try context.render(value3); context.processedTupleElement(at: 2)
    try context.render(value4); context.processedTupleElement(at: 3)
    try context.render(value5); context.processedTupleElement(at: 4)
    try context.render(value6); context.processedTupleElement(at: 5)
  }
}

extension Tuple7: BlocksPrimitive where T1: Blocks, T2: Blocks, T3: Blocks,
                                        T4: Blocks, T5: Blocks, T6: Blocks,
                                        T7: Blocks
{
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 7); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
    try context.render(value3); context.processedTupleElement(at: 2)
    try context.render(value4); context.processedTupleElement(at: 3)
    try context.render(value5); context.processedTupleElement(at: 4)
    try context.render(value6); context.processedTupleElement(at: 5)
    try context.render(value7); context.processedTupleElement(at: 6)
  }
}

extension Tuple8: BlocksPrimitive where T1: Blocks, T2: Blocks, T3: Blocks,
                                        T4: Blocks, T5: Blocks, T6: Blocks,
                                        T7: Blocks, T8: Blocks
{
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 8); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
    try context.render(value3); context.processedTupleElement(at: 2)
    try context.render(value4); context.processedTupleElement(at: 3)
    try context.render(value5); context.processedTupleElement(at: 4)
    try context.render(value6); context.processedTupleElement(at: 5)
    try context.render(value7); context.processedTupleElement(at: 6)
    try context.render(value8); context.processedTupleElement(at: 7)
  }
}

extension Tuple9: BlocksPrimitive where T1: Blocks, T2: Blocks, T3: Blocks,
                                        T4: Blocks, T5: Blocks, T6: Blocks,
                                        T7: Blocks, T8: Blocks, T9: Blocks
{
  public func render(in context: BlocksContext) throws {
    context.enterTuple(count: 9); defer { context.leaveTuple() }
    try context.render(value1); context.processedTupleElement(at: 0)
    try context.render(value2); context.processedTupleElement(at: 1)
    try context.render(value3); context.processedTupleElement(at: 2)
    try context.render(value4); context.processedTupleElement(at: 3)
    try context.render(value5); context.processedTupleElement(at: 4)
    try context.render(value6); context.processedTupleElement(at: 5)
    try context.render(value7); context.processedTupleElement(at: 6)
    try context.render(value8); context.processedTupleElement(at: 7)
    try context.render(value9); context.processedTupleElement(at: 8)
  }
}
