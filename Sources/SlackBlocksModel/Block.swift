//
//  Block.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Foundation

/**
 * https://api.slack.com/reference/messaging/blocks
 */
public enum Block: Encodable {
  
  public struct BlockID : StringID, CustomStringConvertible {
    public let id : String
    public init(_ id: String) { self.id = id }
    public var description : String { return "<BlockID \(id)>" }
  }
  public struct ActionID : StringID, CustomStringConvertible {
    public let id : String
    public init(_ id: String) { self.id = id }
    public var description : String { return "<ActionID \(id)>" }
  }

  /**
   * A block containing `RichTextElement` elements.
   * Those are in turn some kind of vertically stacked paragraphs.
   */
  case richText(RichText)
  
  /**
   * A section block.
   *
   * A section block can be composed of those things:
   * - a main Text (max 3k characters)
   * - field Texts (2 column layout, max 10 fields, max 2k chars per field)
   * - accessory (an accessory element shown in the upper right, for example
   *   a date picker)
   *
   * vertically stacked paragraphs.
   */
  case section(Section)
  
  case actions(Actions)
  
  case divider
  
  case image(ImageBlock)

  case input(Input)
  
  case context(Context)
  
  case header(Header)
  
  // TODO: file
  // TODO: event
  
  // MARK: - Encoding
  
  enum CodingKeys: String, CodingKey {
    case id = "block_id"
    case type, elements
    case text, fields, accessory
  }
    
  public func encode(to encoder: Encoder) throws {
    switch self {
      case .richText(let v): try v.encode(to: encoder)
      case .section (let v): try v.encode(to: encoder)
      case .actions (let v): try v.encode(to: encoder)
      case .image   (let v): try v.encode(to: encoder)
      case .input   (let v): try v.encode(to: encoder)
      case .context (let v): try v.encode(to: encoder)
      case .header  (let v): try v.encode(to: encoder)
        
      // TODO: file, event

      case .divider:
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("divider", forKey: .type)
    }
  }
}

public extension Block {
  
  struct BlockTypeSet: OptionSet {
    public let rawValue : UInt16
    public init(rawValue: UInt16) { self.rawValue = rawValue }
    
    public static let richText = BlockTypeSet(rawValue: 1 << 1)
    public static let section  = BlockTypeSet(rawValue: 1 << 2)
    public static let actions  = BlockTypeSet(rawValue: 1 << 3)
    public static let divider  = BlockTypeSet(rawValue: 1 << 4)
    public static let context  = BlockTypeSet(rawValue: 1 << 5)
    public static let input    = BlockTypeSet(rawValue: 1 << 6)
    public static let image    = BlockTypeSet(rawValue: 1 << 7)
    public static let header   = BlockTypeSet(rawValue: 1 << 8)
  }
  
  var blockTypeSet : BlockTypeSet {
    switch self {
      case .richText : return [ .richText ]
      case .section  : return [ .section  ]
      case .actions  : return [ .actions  ]
      case .divider  : return [ .divider  ]
      case .image    : return [ .image    ]
      case .input    : return [ .input    ]
      case .context  : return [ .context  ]
      case .header   : return [ .header   ]
    }
  }
}

public extension Block {
  
  enum BlockSurface {
    case homeTab, modal, message
    
    public var asSet : BlockSurfaceSet {
      switch self {
        case .homeTab : return .homeTabs
        case .modal   : return .modals
        case .message : return .messages
      }
    }
  }

  struct BlockSurfaceSet: OptionSet {
    public let rawValue : UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    
    public static let homeTabs = BlockSurfaceSet(rawValue: 1 << 1)
    public static let modals   = BlockSurfaceSet(rawValue: 1 << 2)
    public static let messages = BlockSurfaceSet(rawValue: 1 << 3)
    
    public func containsSurface(_ surface: BlockSurface) -> Bool {
      // TBD: Why can't I use `contains`, hm. Overrides autogenerated code I
      //      suppose.
      switch surface {
        case .homeTab : return contains(.homeTabs)
        case .modal   : return contains(.modals)
        case .message : return contains(.messages)
      }
    }
  }
}

extension Block.BlockID: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) { self.id = value }
}
extension Block.ActionID: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) { self.id = value }
}

extension Block {
  
  @inlinable
  public var id: BlockID {
    switch self {
      case .richText(let v) : return v.id
      case .section (let v) : return v.id
      case .actions (let v) : return v.id
      case .image   (let v) : return v.id
      case .input   (let v) : return v.id
      case .context (let v) : return v.id
      case .header  (let v) : return v.id
      case .divider         : return "$divider"
    }
  }
}

extension Block: CustomStringConvertible {
  
  public var description: String {
    switch self {
      case .richText(let v) : return v.description
      case .section (let v) : return v.description
      case .actions (let v) : return v.description
      case .image   (let v) : return "\(v)"
      case .input   (let v) : return v.description
      case .context (let v) : return v.description
      case .header  (let v) : return v.description
      case .divider         : return "<DividerBlock>"
    }
  }
}

public extension Block {

  /// Render Block as Markdown (as well as possible)
  @inlinable
  var blocksMarkdownString : String {
    switch self {
      case .richText(let v) : return v.blocksMarkdownString
      case .section (let v) : return v.blocksMarkdownString
      case .actions (let v) : return v.blocksMarkdownString
      case .image   (let v) : return v.blocksMarkdownString
      case .input   (let v) : return v.blocksMarkdownString
      case .context (let v) : return v.blocksMarkdownString
      case .header  (let v) : return v.blocksMarkdownString
      case .divider         : return "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"
    }
  }
}

public extension Sequence where Element == Block {
  
  @inlinable
  var blocksMarkdownString : String {
    var ms = ""
    for element in self {
      if !ms.isEmpty && !ms.hasSuffix("\n\n") {
        ms += ms.hasSuffix("\n") ? "\n" : "\n\n"
      }
      ms += element.blocksMarkdownString.trimmingCharacters(in: .newlines)
    }
    return ms
  }
}

public extension Block {
  
  func replacingRichText() -> Block {
    switch self {
      case .richText(let richText) : return .section(richText.asSection())
      default                      : return self
    }
  }
}

public extension Sequence where Element == Block {

  func replacingRichText() -> [ Block ] {
    return map { $0.replacingRichText() }
  }
}
