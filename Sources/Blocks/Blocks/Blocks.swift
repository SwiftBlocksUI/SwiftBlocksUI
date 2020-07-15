//
//  Blocks.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

/**
 * Something which can generate BlockKit blocks.
 *
 * Note the use of plural (i.e. `some Blocks`). This is because we always
 * generate a set of Blocks.
 *
 * This is similar to a `View` in SwiftUI.
 *
 * Do not mixup w/ `Block`, which is the low level model object representing
 * a block in JSON.
 */
public protocol Blocks {
  
  typealias BlockID = Block.BlockID
  
  associatedtype Body : Blocks

  #if swift(>=5.3)
    @BlocksBuilder var body : Self.Body { get }
  #else
                   var body : Self.Body { get }
  #endif
}

public protocol TopLevelPrimitiveBlock {

  var blockID : BlockIDStyle { set get }
}

public extension TopLevelPrimitiveBlock {
  
  func id(_ relativeID: String) -> Self {
    var mod = self
    mod.blockID = .rootRelativeID(relativeID)
    return mod
  }
}
