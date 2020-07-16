//
//  ElementID.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2020 ZeeZide GmbH. All rights reserved.
//

@usableFromInline let rootElementIDComponent    = "/"
@usableFromInline let contentElementIDComponent = "_"
fileprivate let noElementIDComponent = NoElementID()

fileprivate struct NoElementID: Hashable {}

public struct ElementID: Hashable {
  // By keeping them as `Hashable`, we can preserve the identity of keys in
  // ForEach.
  // It makes rendering them to the web clumsy though (though this could be
  // worked around using some map $web-id-slot => real-id).
  
  @usableFromInline
  var components : [ AnyHashable ]
  
  @inlinable var count   : Int  { return components.count   }
  @inlinable var isEmpty : Bool { return components.isEmpty }

  @usableFromInline
  static let rootElementID = ElementID(components: [ rootElementIDComponent ])
  @usableFromInline
  static let noElementID   = ElementID(components: [ noElementIDComponent   ])

  // MARK: - Modifying the ElementID
  
  @inlinable
  mutating func deleteLastElementIDComponent() {
    components.removeLast()
  }
  
  @inlinable
  mutating func appendContentElementIDComponent() {
    components.append(contentElementIDComponent)
  }
  
  
  // MARK: - actual IDs

  @inlinable
  mutating func appendElementIDComponent
                  <T: Hashable & WebRepresentableIdentifier>(_ id: T)
  {
    components.append(AnyHashable(id))
  }

  #if false
  @inlinable
  mutating func appendElementIDComponent<T: Hashable>(_ id: T) {
    components.append(AnyHashable(id))
  }
  @inlinable
  mutating func appendElementIDComponent(_ id: AnyHashable) {
    components.append(id)
  }
  #endif
  
  
  // MARK: - number based IDs

  @inlinable
  mutating func appendZeroElementIDComponent() {
    components.append(0)
  }
  
  @inlinable
  mutating func incrementLastElementIDComponent() {
    assert(!components.isEmpty,
           "attempt to increment empty elementID \(self)")
    guard !components.isEmpty else { return }
    
    let lastIndex = components.count - 1
    assert(components[lastIndex] is Int)
    guard let lastValue = components[components.count - 1].base as? Int else {
      assertionFailure("attempt to increment non-int ID")
      return
    }
    
    components[lastIndex] = lastValue + 1
  }

  
  #if false // unused
  @inlinable
  func appendingElementIDComponent<T: Hashable>(_ id: T) -> ElementID {
    var eid = self
    eid.appendElementIDComponent(id)
    return eid
  }
  @inlinable
  func appendingElementIDComponent(_ id: AnyHashable) -> ElementID {
    var eid = self
    eid.appendElementIDComponent(id)
    return eid
  }
  #endif

  
  // MARK: - Matching
  
  @inlinable
  func hasPrefix(_ other: ElementID) -> Bool {
    guard other.components.count <= self.components.count else { return false }
    for i in 0..<other.components.count {
      guard other.components[i] == components[i] else { return false }
    }
    return true
  }
}
