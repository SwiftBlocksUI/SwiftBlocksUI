//
//  DynamicBlockProperty.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * When writing own property wrappers, you can declare them as
 * `DynamicBlockProperty`.
 * By doing so, Blocks's will call their `update(in:)` method before entering
 * the `body` of a Blocks.
 *
 * The included `Environment` property wrapper is an example.
 */
public protocol DynamicBlockProperty : _DynamicBlockPropertyType {
  /**
   * Update a property with new values from the context.
   *
   * Called before body() is executed.
   *
   * Differences to SwiftUI:
   * - takes a context parameter, this way we can avoid a thread local
   */
  mutating func update(in context: BlocksContext)
}

/**
 * A helper protocol to update dynamic properties before `body` is called.
 */
public protocol _DynamicBlockPropertyType {
  
  static func _updateInstance(at location : UnsafeMutableRawPointer,
                              context     : BlocksContext)
}

public extension DynamicBlockProperty {
  
  /**
   * Helper method which calls the actual `update` method.
   */
  static func _updateInstance(at location : UnsafeMutableRawPointer,
                              context     : BlocksContext)
  {
    let typedPtr = location.assumingMemoryBound(to: Self.self)
    typedPtr.pointee.update(in: context)
  }
}
