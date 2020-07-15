//
//  MetaData.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Logging.Logger
import class  Foundation.JSONEncoder
import class  Foundation.JSONDecoder
import struct Foundation.Data

/**
 * Property Wrapper to access View meta data (if available).
 *
 * Similar to Environment keys, there can be multiple MetaData keys. Unlike
 * environment keys, they do not "stack".
 *
 * There is a `\.global` `[String:String]` default key. Which can be used as is.
 * Otherwise own keys can be defined:
 *
 *     enum OrderIDKey: MetaDataKey {
 *       static var defaultValue : String? { nil }
 *       static var externalKey  : String  { "order-id" }
 *     }
 *     extension MetaDataValues {
 *       var orderID : String? {
 *                  set { self[OrderIDKey.self] = newValue }
 *         mutating get { return self[OrderIDKey.self]     }
 *       }
 *     }
 *
 * Their external ID needs to be unique of course.
 *
 * The maximum encoded size of the meta data payload is 3000 characters.
 * MetaData values should be very small as a consequence!
 */
@propertyWrapper @frozen
public struct MetaData<Value: Codable>: DynamicBlockProperty {
  
  @usableFromInline
  let keyPath : WritableKeyPath<MetaDataValues, Value>
  @usableFromInline
  weak var context : BlocksContext? // FIXME: avoid weak (not necessary?)
  
  @inlinable
  public init(_ keyPath: WritableKeyPath<MetaDataValues, Value>) {
    self.keyPath = keyPath
  }
  
  // MARK: - Value Access
  
  @inlinable
  public var wrappedValue: Value {
    
    nonmutating set {
      guard let context = context else {
        globalBlocksLog
          .critical("cannot access @MetaData outside of `body` \(self)")
        assert(self.context != nil, "cannot access @MetaData outside of `body`")
        return
      }
      context.metaData[keyPath: keyPath] = newValue
    }
    
    get {
      guard let context = context else {
        globalBlocksLog
          .critical("cannot access @MetaData outside of `body` \(self)")
        assert(self.context != nil, "cannot access @MetaData outside of `body`")
        return MetaDataValues()[keyPath: keyPath]
      }
      
      // FIXME: this feels wrong?
      return context.metaData[keyPath: keyPath]
    }
  }

  @inlinable
  public var projectedValue: Binding<Value> {
    // This exposes the property as a `Binding<Value>` instead of
    // `MetaData<Value>`.
    return binding
  }
  
  public var binding: Binding<Value> {
    return Binding(getValue: { return self.wrappedValue },
                   setValue: { newValue in self.wrappedValue = newValue })
  }
  
  @inlinable
  public mutating func update(in context: BlocksContext) {
    self.context = context
  }
}

public protocol MetaDataKey {
  
  associatedtype Value    : Codable
  
  /// The value which is used when there is no value for this key
  static var defaultValue : Self.Value { get }
  
  /// The key which is used when the value is persisted
  static var externalKey  : String     { get }
}
public extension MetaDataKey {
  static var externalKey : String { String(describing: self) }
}

public enum GlobalMetaDataKey: MetaDataKey {
  public static var defaultValue : [ String : String ] { [:] }
  public static var externalKey  : String { "$$global" }
}


// MARK: - EnvironmentKey Value Access

public extension MetaDataValues {
  
  @inlinable var global : [ String : String ] {
             set { self[GlobalMetaDataKey.self] = newValue }
    mutating get { return self[GlobalMetaDataKey.self]     }
  }
}

@frozen public struct MetaDataValues {
  
  @usableFromInline
  enum ValueState {
    case external(String)
    case value(EncodableValueHolder)
  }
  
  @usableFromInline
  var values = [ String : ValueState ]()
  
  @usableFromInline init() {}
  
  // MARK: - Double encoded JSON
  // TODO: be more sensible :->
  
  public init(metaDataString: String?) throws {
    if let data = metaDataString?.data(using: .utf8), !data.isEmpty {
      let outer = try JSONDecoder().decode([ String : String ].self, from: data)
      for ( key, value ) in outer {
        values[key] = .external(value)
      }
    }
  }
  public func encodeMetaDataString() throws -> String {
    guard !values.isEmpty else { return "" }
    
    var outer = [ String : String ]()
    outer.reserveCapacity(values.count)
    
    for ( key, value ) in values {
      switch value {
        case .external(let value):
          outer[key] = value
          
        case .value(let holder):
          let data = try JSONEncoder().encode(holder)
          outer[key] = String(data: data, encoding: .utf8)
      }
    }
    
    let outerData = try JSONEncoder().encode(outer)
    return String(data: outerData, encoding: .utf8) ?? ""
  }
  
  // MARK: - Value Access

  @inlinable
  public subscript<K: MetaDataKey>(key: K.Type) -> K.Value {
    set {
      values[key.externalKey] = .value(.init(newValue))
    }
    get {
      guard let stateValue = values[key.externalKey] else {
        return K.defaultValue
      }
      
      // decode on demand
      switch stateValue {
      
        case .external(let string):
          let data = string.data(using: .utf8) ?? Data()
          do {
            let value = try JSONDecoder().decode(K.Value.self, from: data)
            #if ENABLE_MUTATING_METADATA_GET
              values[key.externalKey] = .value(.init(value))
            #endif
            return value
          }
          catch {
            globalBlocksLog.error(
              "failed to JSON-decode MetaData value!\n  \(error)\n\(string)")
            assertionFailure("failed to JSON-decode MetaData: \(string)")
            #if ENABLE_MUTATING_METADATA_GET
              values[key.externalKey] = .value(.init(K.defaultValue))
            #endif
            return K.defaultValue
          }
          
        case .value(let holder):
          guard let typedValue = holder.value as? K.Value else {
            globalBlocksLog.error("unexpected MetaData value!")
            assertionFailure("unexpected typed value: \(holder.value)")
            #if ENABLE_MUTATING_METADATA_GET
              values[key.externalKey] = .value(.init(K.defaultValue))
            #endif
            return K.defaultValue
          }
          return typedValue
      }
    }
  }
}

@usableFromInline
struct EncodableValueHolder: Encodable {
  
  @usableFromInline
  let value        : Any
  @usableFromInline
  let erasedEncode : ( Encoder ) throws -> Void
  
  @usableFromInline
  init<C: Encodable>(_ value: C) {
    self.value  = value
    self.erasedEncode = { encoder in try value.encode(to: encoder) }
  }
  
  @usableFromInline
  func encode(to encoder: Encoder) throws {
    try erasedEncode(encoder)
  }
}
