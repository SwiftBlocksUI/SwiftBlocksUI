//
//  ImageElement.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {

  struct ImageElement: BlockElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .context ]
    
    public let url : URL
    public var alt : String
    
    public init(url: URL, alt: String) {
      self.url = url
      self.alt = alt
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type
      case url = "image_url"
      case alt = "alt_text"
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("image", forKey: .type)
      try container.encode(url,     forKey: .url)
      try container.encode(alt,     forKey: .alt)
    }
  }  
}


// MARK: - Markdown

public extension Block.ImageElement {
  
  @inlinable
  var blocksMarkdownString : String {
    return "![\(alt)](url.absoluteString)"
  }
}

public extension Block.ImageElement {
  
  @inlinable
  var description : String {
    var ms = "<ImageElement: "
    ms += url.absoluteString
    if !alt.isEmpty { ms += " \"\(alt)\"" }
    ms += ">"
    return ms
  }
}
