//
//  Divider.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A vertical divider block (draws a separator line)
 *
 * Example:
 *
 *     Section {
 *       "Hello World"
 *     }
 *
 *     Divider
 *
 *     Section {
 *       "Does it work?"
 *     }
 *
 */
public struct Divider: Blocks, TopLevelPrimitiveBlock {
  
  public typealias Body = Never
  
  @inlinable public init() {}
  
  @inlinable
  public var blockID : BlockIDStyle {
    set {
      globalBlocksLog.warning("attempt to set id \(newValue) on Divider block")
    }
    get { .auto }
  }
}
