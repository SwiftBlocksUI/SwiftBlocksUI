//
//  ImageBlock.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {
  
  /**
   * A top level image block.
   *
   * Careful: Do not mixup w/ the ImageElement (valid within `Context` blocks
   * and `Section` accessories).
   *
   * Docs: https://api.slack.com/reference/block-kit/blocks#image
   */
  struct ImageBlock: Encodable {
    public static let validInSurfaces : [ BlockSurfaceSet ]
                                      = [ .modals, .messages, .homeTabs ]
    
    public var id    : BlockID
    public var url   : URL
    public var alt   : String  // max 2k characters
    public var title : String? // mac 2k characters

    public init(id: BlockID, url: URL, alt: String, title: String? = nil) {
      self.id    = id
      self.url   = url
      self.alt   = alt
      self.title = title
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case id  = "block_id"
      case url = "image_url"
      case alt = "alt_text"
      case type, title
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("image", forKey: .type)
      try container.encode(id,      forKey: .id)
      try container.encode(url,     forKey: .url)
      try container.encode(alt,     forKey: .alt)
      if let v = title { try container.encode(Text(v), forKey: .title) }
    }
  }
}

public extension Block.ImageBlock {
  
  @inlinable
  var blocksMarkdownString : String {
    return "![\(alt)](url.absoluteString)\n"
  }
}
