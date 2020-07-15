//
//  SelectionManager.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * The selection manager abstracts away the thing that holds a selection,
 * which is either a Set of tags or an optional tag, or sometimes just the tag
 * itself.
 */
public protocol SelectionManager {
  // TBD: This is not quite what I want for selection. I'd prefer to get
  //      actual model objects in the selection, not their ID.

  associatedtype SelectionValue : Hashable
  
  mutating func select  (_ value: SelectionValue)
  mutating func deselect(_ value: SelectionValue)
  mutating func deselectAll()
  
  func isSelected(_ value: SelectionValue) -> Bool
  
  var selection : Set<SelectionValue> { get }
  
  static var allowsMultipleSelection: Bool { get }
}

public extension SelectionManager {
  @inlinable
  static var allowsMultipleSelection: Bool { return true }
  
  mutating func deselectAll() {
    for value in selection { deselect(value) }
  }
}

public extension SelectionManager {
  
  @inlinable
  mutating func toggle(_ value: SelectionValue) {
    if isSelected(value) { deselect(value) }
    else                 { select  (value) }
  }
}

extension Set: SelectionManager {
  public typealias SelectionValue = Element
  @inlinable public mutating func select  (_ value: Element) { insert(value) }
  @inlinable public mutating func deselect(_ value: Element) { remove(value) }
  @inlinable public mutating func deselectAll() { removeAll() }
  @inlinable
  public func isSelected(_ value: Element) -> Bool { contains(value) }

  @inlinable public var selection : Set<SelectionValue> { self }
}

extension Never: SelectionManager {
  @inlinable public mutating func select     (_ value: Never) {}
  @inlinable public mutating func deselect   (_ value: Never) {}
  @inlinable public mutating func deselectAll() {}
  @inlinable public          func isSelected (_ value: Never) -> Bool {}
  @inlinable public var selection : Set<Never> { return [] }
}

extension Optional: SelectionManager where Wrapped : Hashable {
  // TBD: Is this the proper implementation?
  
  public typealias SelectionValue = Wrapped
  
  @inlinable
  public mutating func select  (_ value: Wrapped) { self = .some(value) }
  @inlinable
  public mutating func deselect(_ value: Wrapped) { self = .none }
  @inlinable
  public mutating func deselectAll() { self = .none }

  @inlinable
  public func isSelected(_ value: Wrapped) -> Bool {
    switch self {
      case .none:             return false
      case .some(let stored): return stored == value
    }
  }

  @inlinable
  public var selection : Set<Wrapped> {
    switch self {
      case .none:             return []
      case .some(let stored): return [ stored ]
    }
  }

  @inlinable
  static public var allowsMultipleSelection: Bool { return false }
}
