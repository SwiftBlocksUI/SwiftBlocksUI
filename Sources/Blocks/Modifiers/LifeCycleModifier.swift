//
//  LifeCycleModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

public struct LifeCycleModifier<Content: Blocks>: Blocks {

  public typealias Body = Never
  
  public typealias Handler = () throws -> Void
  
  public let precondition : ( BlocksContext ) -> Bool
  public let enter        : Handler?
  public let leave        : Handler?
  public let content      : Content
  
  @inlinable
  public init(enter        : Handler? = nil,
              leave        : Handler? = nil,
              content      : Content,
              precondition : @escaping ( BlocksContext ) -> Bool)
  {
    self.precondition = precondition
    self.enter        = enter
    self.leave        = leave
    self.content      = content
  }
}

public extension Blocks {
  
  /**
   * Execute a closure before the final rendering pass starts.
   *
   * Only ever called once per BlocksContext.
   */
  @inlinable
  func onRender(execute: @escaping () throws -> Void) -> LifeCycleModifier<Self>
  {
    return LifeCycleModifier(enter: execute, content: self) { context in
      guard case .render = context.mode else { return false }
      return true
    }
  }
  
  /**
   * Execute a closure before the Blocks are being used, either for request
   * processing or response generation.
   *
   * Allows the Blocks to setup context from within a body.
   *
   * Only ever called once per BlocksContext.
   */
  @inlinable
  func onAwake(execute: @escaping () throws -> Void) -> LifeCycleModifier<Self>
  {
    return LifeCycleModifier(enter: execute, content: self) { context in
      guard context.state[context.currentElementID] == nil else { return false }
      context.state[context.currentElementID] = "onAwakeDidRun"
      return true
    }
  }
}

extension LifeCycleModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    assert(enter != nil || leave != nil)
    
    let hits = precondition(context)
    if hits { try enter?() }
    
    do {
      // We use the element ID storage to store state crossing tree runs.
      context.currentElementID.appendContentElementIDComponent()
      defer { context.currentElementID.deleteLastElementIDComponent() }
      
      try context.render(content)
    }
    catch {
      if hits { try? leave?() }
      throw error
    }
    if hits { try leave?() }
  }
}
