//
//  Binding.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2020 ZeeZide GmbH. All rights reserved.
//

@propertyWrapper
public struct Binding<Value> {
  
  public var wrappedValue : Value {
    nonmutating set { setter(newValue) }
    get             { return getter()  }
  }
  
  @usableFromInline var getter : () -> Value
  @usableFromInline var setter : ( Value ) -> Void
  
  @inlinable
  public init(getValue: @escaping ()        -> Value,
              setValue: @escaping ( Value ) -> Void)
  {
    self.getter = getValue
    self.setter = setValue
  }
  
  /// Creates a binding with an immutable `value`.
  @inlinable
  public static func constant(_ value: Value) -> Binding<Value> {
    return Binding<Value>(getValue: { return value }) { _ in
      assertionFailure("cannot set constant binding \(self)")
    }
  }
  
  @usableFromInline
  internal static func readOnly(_ getValue: @escaping () -> Value)
                       -> Binding<Value>
  {
    return Binding<Value>(getValue: getValue) { _ in
      assertionFailure("cannot set r/o value \(self)")
    }
  }
}

public extension Binding {
  
  // TBD: What about the Hashable wrapper, why is that necessary?
  
  // Binding<Int> => Binding<Int?>
  @inlinable
  init<BaseValue>(_ base: Binding<BaseValue>) where Value == BaseValue? {
    // TBD: Is this thinking right?
    var isOptional = false // captured and shared by closures
    self.init(
      getValue: { return isOptional ? nil : base.wrappedValue },
      setValue: { newValue in
         if let value = newValue { isOptional = false; base.setter(value) }
         else { isOptional = true }
      }
    )
  }
  
  @inlinable
  init?(_ base: Binding<Value?>) {
    // TBD: does this actually make sense?
    guard var value = base.wrappedValue else { return nil }
    self.init(
      getValue: { return value },
      setValue: { newValue in value = newValue }
    )
  }
}

// MARK: - Support specific bound types

extension Binding where Value: SetAlgebra, Value.Element: Hashable {
  @inlinable
  public func contains(_ element: Value.Element) -> Binding<Bool> {
    return Binding<Bool>.readOnly { self.wrappedValue.contains(element) }
  }
}

extension Binding where Value: RawRepresentable {
  @inlinable
  public var rawValue: Binding<Value.RawValue> {
    return Binding<Value.RawValue>.readOnly { self.wrappedValue.rawValue }
  }
}

extension Binding where Value: CaseIterable, Value: Equatable {
  @inlinable
  public var caseIndex: Binding<Value.AllCases.Index> {
    return Binding<Value.AllCases.Index>.readOnly {
      return Value.allCases.firstIndex(of: self.wrappedValue)!
    }
  }
}

extension Binding: Sequence
            where Value: MutableCollection, Value.Index: Hashable
{
  public typealias Element     = Binding<Value.Element>
  public typealias Iterator    = IndexingIterator<Binding<Value>>
  public typealias SubSequence = Slice<Binding<Value>>
}

extension Binding: Collection
            where Value: MutableCollection, Value.Index: Hashable
{
  public typealias Index   = Value.Index
  public typealias Indices = Value.Indices
  
  public var startIndex : Value.Index   { return wrappedValue.startIndex }
  public var endIndex   : Value.Index   { return wrappedValue.endIndex   }
  public var indices    : Value.Indices { return wrappedValue.indices    }

  @inlinable
  public func index(after i: Value.Index) -> Value.Index {
    return wrappedValue.index(after: i)
  }
  @inlinable
  public func formIndex(after i: inout Value.Index) {
    return wrappedValue.formIndex(after: &i)
  }
  
  @inlinable
  public subscript(position: Value.Index) -> Binding<Value.Element> {
    return .readOnly { self.wrappedValue[position] }
  }
}

extension Binding: BidirectionalCollection
            where Value: BidirectionalCollection,
                  Value: MutableCollection,
                  Value.Index: Hashable
{
  @inlinable
  public func index(before i: Value.Index) -> Value.Index {
    return wrappedValue.index(before: i)
  }
  @inlinable
  public func formIndex(before i: inout Value.Index) {
    return wrappedValue.formIndex(before: &i)
  }
}
