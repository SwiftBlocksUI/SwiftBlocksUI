//
//  EnvironmentValues.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2020 ZeeZide GmbH. All rights reserved.
//

@frozen public struct EnvironmentValues {
  
  @usableFromInline
  static let empty = EnvironmentValues()
  
  @usableFromInline
  var values = [ ObjectIdentifier : Any ]()
    // TBD: can we avoid the any? Own AnyEntry protocol doesn't give much?
  
  // a hack to support type erased values
  mutating func _setAny<T>(_ key: Any.Type, _ newValue: T) {
    values[ObjectIdentifier(key)] = newValue
  }
  
  @usableFromInline
  mutating func _removeAny(_ key: Any.Type) {
    values.removeValue(forKey: ObjectIdentifier(key))
  }

  @inlinable
  public subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
    set {
      values[ObjectIdentifier(key)] = newValue
    }
    get {
      guard let value = values[ObjectIdentifier(key)] else {
        return K.defaultValue
      }
      guard let typedValue = value as? K.Value else {
        assertionFailure("unexpected typed value: \(value)")
        return K.defaultValue
      }
      return typedValue
    }
  }
}
