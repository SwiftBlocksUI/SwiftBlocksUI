//
//  IDModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.CallbackID

/**
 * IDs are used to identify blocks.
 *
 * Not to be confused w/ tags, which are used to identify content, specifically
 * for selections.
 */
@usableFromInline @frozen
internal struct IDModifier<B: Blocks, ID: Hashable>: Blocks {
  
  public typealias Body = Never
  
  @usableFromInline let id      : ID
  @usableFromInline let content : B
  
  @inlinable
  init(id: ID, content: B) {
    self.id      = id
    self.content = content
  }
}

public extension Blocks {
  
  @inlinable
  func id<ID: Hashable>(_ id: ID) -> some Blocks {
    return IDModifier(id: id, content: self)
  }
}

import enum SlackBlocksModel.Block

public enum BlockIDStyle: Hashable {
  
  case globalID(Block.BlockID)
  case rootRelativeID(String)
  case elementID
  case auto
}

extension BlockIDStyle: ExpressibleByStringLiteral {

  public init(stringLiteral rootRelativeID: String) {
    self = .rootRelativeID(rootRelativeID)
  }
}

public enum ActionIDStyle: Hashable {
  
  case globalID(Block.ActionID)
  case rootRelativeID(String)
  case elementID
  case auto
}

extension Block.BlockID {
  
  init(_ elementID: ElementID) {
    self.init(elementID.webID)
  }
}
extension Block.ActionID {
  
  init(_ elementID: ElementID) {
    self.init(elementID.webID)
  }
}
