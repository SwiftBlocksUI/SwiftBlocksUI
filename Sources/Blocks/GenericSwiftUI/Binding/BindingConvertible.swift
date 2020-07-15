//
//  BindingConvertible.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2020 ZeeZide GmbH. All rights reserved.
//

@dynamicMemberLookup public protocol BindingConvertible {
  // Kinda like objects being able to vend a WOAssociation
  // `State` is a BindingConvertible.
  
  associatedtype Value
  
  var binding : Binding<Self.Value> { get }
  
  subscript<Subject>(dynamicMember path: WritableKeyPath<Self.Value, Subject>)
                     -> Binding<Subject> { get }
}

public extension BindingConvertible {

  @inlinable
  subscript<Subject>(dynamicMember path: WritableKeyPath<Self.Value, Subject>)
                     -> Binding<Subject>
  {
    return Binding(
      getValue: { return self.binding.wrappedValue[keyPath: path] },
      setValue: { self.binding.wrappedValue[keyPath: path] = $0 }
    )
  }
}

public extension BindingConvertible {
  
  @inlinable
  func zip<T: BindingConvertible>(with rhs: T)
       -> Binding< ( Self.Value, T.Value ) >
  {
    return Binding(
      getValue: { return ( self.binding.wrappedValue, rhs.binding.wrappedValue ) },
      setValue: { ( newLHS, newRHS ) in
        self.binding.wrappedValue = newLHS
        rhs.binding.wrappedValue  = newRHS
      }
    )
  }
}

extension Binding : BindingConvertible {

  @inlinable
  public var binding : Self { return self }
}
