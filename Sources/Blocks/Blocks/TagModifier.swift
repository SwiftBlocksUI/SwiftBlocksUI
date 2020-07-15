//
//  TagModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.CallbackID

/**
 * Tags are used to identify content, specifically for selections.
 *
 * Not to be confused with IDs, which are used to identify blocks.
 */
/**
 * Tags are used to match up selections.
 */
@usableFromInline @frozen
internal struct TagModifier<B: Blocks, Tag: Hashable>: Blocks {
  
  public typealias Body = Never
  
  @usableFromInline let tag     : Tag
  @usableFromInline let content : B
  
  @inlinable
  init(tag: Tag, content: B) {
    self.tag     = tag
    self.content = content
  }
}

public extension Blocks {
  
  @inlinable
  func tag<Tag: Hashable>(_ tag: Tag) -> some Blocks {
    return TagModifier(tag: tag, content: self)
  }
}
