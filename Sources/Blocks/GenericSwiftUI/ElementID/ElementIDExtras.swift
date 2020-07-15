//
//  ElementIDExtras.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2020 ZeeZide GmbH. All rights reserved.
//

extension ElementID {

  @inlinable
  static func ==(lhs: ElementID, rhs: [ String ]) -> Bool {
    guard lhs.components.count == rhs.count else { return false }
    for i in 0..<rhs.count {
      guard lhs.components[i].webID == rhs[i] else { return false }
    }
    return true
  }
  
  @inlinable
  static func ==<T>(lhs: ElementID, rhs: T) -> Bool
           where T: RandomAccessCollection, T.Element == String
  {
    guard lhs.components.count == rhs.count else { return false }
    for ( i, webComponentID ) in rhs.enumerated() {
      guard lhs.components[i].webID == webComponentID else { return false }
    }
    return true
  }

  @inlinable
  func isContainedInWebID(_ webID: [ String ]) -> Bool {
    // Note: IDs always grow down the tree ... (not in WO, but in our case we
    //       rely on this, aka custom-IDs are not allowed to avoid having to
    //       traverse the whole thing).
    guard webID.count >= components.count else { return false }
    for i in 0..<components.count {
      guard components[i].webID == webID[i] else { return false }
    }
    return true
  }
}
