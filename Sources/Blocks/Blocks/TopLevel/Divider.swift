//
//  Divider.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A vertical divider block (draws a separator line)
 */
public struct Divider: Blocks, TopLevelPrimitiveBlock {
  
  public typealias Body = Never
  
  public var blockID : BlockIDStyle {
    set {
      globalBlocksLog.warning(
        "attempt to set id \(newValue) on Divider block")
    }
    get { .auto }
  }
}
