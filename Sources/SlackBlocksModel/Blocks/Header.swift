//
//  Header.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  struct Header: Encodable {
    
    public static let validInSurfaces : [ BlockSurfaceSet ]
                                      = [ .modals, .messages, .homeTabs ]

    public var id   : BlockID
    public var text : Text
    
    public init(id: BlockID, text: Text) {
      self.id   = id
      self.text = text
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case id = "block_id"
      case type, text
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("header", forKey: .type)
      try container.encode(id,       forKey: .id)
      try container.encode(text,     forKey: .text)
    }
  }
}


// MARK: - Markdown

public extension Block.Header {
  
  @inlinable
  var blocksMarkdownString : String {
    return "#\(text.blocksMarkdownString)\n"
  }
}


// MARK: - Markdown

extension Block.Header: CustomStringConvertible {
  
  @inlinable
  public var description : String {
    var ms = "<Header[\(id.id)]:"
    if text.isEmpty { ms += " EMPTY"   }
    else            { ms += " \(text)" }
    ms += ">"
    return ms
  }
}
