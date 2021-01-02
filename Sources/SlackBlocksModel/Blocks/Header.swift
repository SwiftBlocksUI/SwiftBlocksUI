//
//  Header.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * A header is a simple HTML `H1` tag like block. It can only contain
   * text.
   *
   * The `Header` block only supports a plaintext value!
   */
  struct Header: Encodable {
    
    public static let validInSurfaces : [ BlockSurfaceSet ]
                                      = [ .modals, .messages, .homeTabs ]

    public var id          : BlockID
    public var text        : String
    public var encodeEmoji : Bool
    
    public init(id: BlockID, text: String, encodeEmoji: Bool = true) {
      self.id   = id
      self.text = text
      self.encodeEmoji = encodeEmoji
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case id = "block_id"
      case type, text
    }
    
    public func encode(to encoder: Encoder) throws {
      let text = Block.Text(self.text, type: .plain(encodeEmoji: encodeEmoji))
      
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
  var blocksMarkdownString : String { return "# \(text)\n" }
}


// MARK: - Markdown

extension Block.Header: CustomStringConvertible {
  
  @inlinable
  public var description : String {
    var ms = "<Header[\(id.id)]:"
    if text.isEmpty { ms += " EMPTY"    }
    else            { ms += " \(text)"  }
    if !encodeEmoji { ms += " no-emoji" }
    ms += ">"
    return ms
  }
}
