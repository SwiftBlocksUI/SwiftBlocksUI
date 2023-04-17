//
//  State.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020-2023 ZeeZide GmbH. All rights reserved.
//

import Logging

/**
 * Persist Blocks values in the context.
 *
 * Note: Unlike in SwiftUI (or SwiftWebUI), those States are only survive
 *       the struct reinstantiations within ONE request/response loop!
 *
 * As a special hack we support initialization from the environment!
 */
@propertyWrapper
public struct State<Value>: BindingConvertible, DynamicBlockProperty {
  
  @usableFromInline
  enum DefaultValue {
    case constant(Value)
    case environmentValue(KeyPath<EnvironmentValues, Value>)
  }
  
  @usableFromInline var      defaultValue : DefaultValue
  @usableFromInline var      elementID    : ElementID?
  @usableFromInline weak var context      : BlocksContext? // FIXME: avoid weak
    // the weak is probably not even necessary?
  
  public init(wrappedValue: Value) {
    self.defaultValue = .constant(wrappedValue)
  }
  
  
  // MARK: - Environment Support
  
  @inlinable
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    self.defaultValue = .environmentValue(keyPath)
  }
  
  
  // MARK: - Value Access
  
  @inlinable
  public var wrappedValue: Value {
    
    nonmutating set {
      guard let context = context, let eid = elementID else {
        globalBlocksLog
          .critical("cannot access @State outside of `body` \(self)")
        assert(self.context != nil && self.elementID != nil,
               "cannot access @State outside of `body`")
        return
      }
      context.state[eid] = newValue
    }
    
    get {
      guard let context = context, let eid = elementID else {
        globalBlocksLog
          .critical("cannot access @State outside of `body` \(self)")
        assert(self.context != nil && self.elementID != nil,
               "cannot access @State outside of `body`")
        switch defaultValue {
          case .constant(let value):
            return value
          case .environmentValue:
            fatalError("cannot access environment outside of `body`")
        }
      }
      
      guard let value = context.state[eid] else {
        switch defaultValue {
          case .constant(let value):
            return value
          case .environmentValue(let keyPath):
            return context.environment[keyPath: keyPath]
        }
      }
      
      guard let typedValue = value as? Value else {
        globalBlocksLog.critical(
          "@State storage contains incorrect value type \(self) \(value)")
        assert(value is Value,
               "@State storage contains incorrect value type! \(value)")
        switch defaultValue {
          case .constant(let value):
            return value
          case .environmentValue(let keyPath):
            return context.environment[keyPath: keyPath]
        }
      }
      
      return typedValue
    }
  }

  @inlinable
  public var projectedValue: Binding<Value> {
    // This exposes the "$state" property as a `Binding<Value>` instead of
    // `State<Value>`.
    return binding
  }
  
  public var binding: Binding<Value> {
    return Binding(getValue: { return self.wrappedValue },
                   setValue: { newValue in self.wrappedValue = newValue })
  }
  
  @inlinable
  public mutating func update(in context: BlocksContext) {
    assert(!context.currentElementID.isEmpty)
    self.elementID = context.currentElementID
    self.context   = context
  }
}

public extension State where Value : ExpressibleByNilLiteral {
  
  @inlinable
  init() { self.init(wrappedValue: nil) }
}
