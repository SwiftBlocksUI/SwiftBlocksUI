//
//  Environment.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * Property Wrapper to access environment variables.
 *
 * Its value is updated right before the `body` of a `View` is entered.
 */
@propertyWrapper @frozen
public struct Environment<Value>: DynamicBlockProperty {
  
  @usableFromInline
  let keyPath : KeyPath<EnvironmentValues, Value>
  
  @inlinable
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    self.keyPath = keyPath
  }

  private var _value: Value?

  public var wrappedValue: Value {
    guard let value = _value else {
      fatalError("you cannot access @Environment outside of `body`")
    }
    return value
  }
  
  public mutating func update(in context: BlocksContext) {
    _value = context.environment[keyPath: keyPath]
  }
}
