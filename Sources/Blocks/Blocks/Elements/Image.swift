//
//  Image.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block

/**
 * Show a remote image.
 *
 * This can be a top level block element OR an element within a `Context` block
 * or `Section` accessory.
 *
 * Example:
 *
 *     Image("A cute kitten",
 *           url: URL("http://placekitten.com/500/500")!)
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#image
 */
public struct Image: Blocks, TopLevelPrimitiveBlock {
  
  public            var blockID : BlockIDStyle = .auto
  @usableFromInline let title   : String
  @usableFromInline let url     : URL
  @usableFromInline let label   : String?
  
  @inlinable public init(_ title: String, url: URL, label: String? = nil) {
    self.title = title
    self.url   = url
    self.label = label
  }
}

public extension Image {
  
  /**
   * If the image is used in a block context, this will assign a (relative) id
   * to the image block.
   */
  @inlinable
  func id(_ relativeID: String) -> Image {
    var me = self
    me.blockID = .rootRelativeID(relativeID)
    return me
  }
}

extension Image {
  
  /**
   * When used within Text contexts, let's generate a link to the image.
   */
  var slackMarkdownString: String {
    // TBD: escaping
    var ms = "<\(url.absoluteString)"
    if !title.isEmpty                 { ms += "|\(title)" }
    else if let l = label, !l.isEmpty { ms += "\(l)" }
    ms += ">"
    return ms
  }
}
