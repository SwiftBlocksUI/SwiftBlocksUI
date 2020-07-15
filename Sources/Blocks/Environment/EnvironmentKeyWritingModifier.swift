//
//  EnvironmentKeyWritingModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public // not really public, while we support Swift 5
struct EnvironmentKeyWritingModifier<Content: Blocks, Value>: Blocks {
  
  public typealias Body = Never
  
  private let keyPath : WritableKeyPath<EnvironmentValues, Value>
  private let value   : Value
  private let content : Content

  init(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, _ value: Value,
       content: Content)
  {
    self.keyPath = keyPath
    self.value   = value
    self.content = content
  }
}


extension EnvironmentKeyWritingModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    try context.environments.setValue(value, in: keyPath) {
      try context.render(content)
    }
  }
}

public extension Blocks {
  
  func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>,
                      _ value: V)
       -> EnvironmentKeyWritingModifier<Self, V>
  {
    return EnvironmentKeyWritingModifier(keyPath, value, content: self)
  }
}
