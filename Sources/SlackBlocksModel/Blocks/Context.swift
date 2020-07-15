//
//  Context.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  struct Context: Encodable {
    
    /**
     * Context's can contain just text (w/ or w/o markdown) and images.
     */
    public enum Element: Encodable {
      case text (Text)
      case image(ImageElement)

      public func encode(to encoder: Encoder) throws {
        switch self {
          case .text (let element): try element.encode(to: encoder)
          case .image(let element): try element.encode(to: encoder)
        }
      }
    }

    public static let validInSurfaces : [ BlockSurfaceSet ]
                                      = [ .modals, .messages, .homeTabs ]

    public var id       : BlockID
    public var elements : [ Element ]
    
    public init(id: BlockID, elements: [ Element ]) {
      self.id       = id
      self.elements = elements
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case id = "block_id"
      case type, elements
    }
      
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("context", forKey: .type)
      try container.encode(id,        forKey: .id)
      try container.encode(elements,  forKey: .elements)
    }
  }
}

public extension Block.Context {
  
  @inlinable
  var blocksMarkdownString : String {
    var ms = ""
    for element in elements {
      switch element {
        case .text(let text):
          ms += text.blocksMarkdownString
          ms += "\n"
        case .image(let image):
          ms += "![\(image.alt)](image.url.absoluteString)\n"
      }
    }
    return ms
  }
}
