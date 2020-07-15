//
//  RichTextBlock.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {
  
  /**
   * A block containing `RichTextElement` elements.
   * Those are in turn some kind of vertically stacked paragraphs.
   *
   * Not valid in Views!
   */
  struct RichText: Encodable {

    public static let validInSurfaces = BlockSurfaceSet.messages

    public var id       : BlockID
    public var elements : [ RichTextElement ]

    public init(id: BlockID, elements: [ RichTextElement ]) {
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
      try container.encode("rich_text", forKey: .type)
      try container.encode(id,          forKey: .id)
      try container.encode(elements,    forKey: .elements)
    }
  }
  
  /**
   * A rich text element is similar to a block, it is like a vertically
   * stacked paragraph.
   * Contained in `richText` blocks.
   */
  enum RichTextElement: Encodable {
    
    /// Essentially a paragraph, plain content.
    case section([ Run ])

    /// A quoted paragraph.
    case quote([ Run ])
    
    /// Shows up as a preformatted code section
    case preformatted(String)
    
    // TODO: (style, indent, items)
    // rich_text_list
    
    public enum Run: Encodable {
      
      public enum BroadcastRange: String, Codable {
        case here, channel, everyone
      }

      case text        (String, style: FontStyle)
      case emoji       (name: String)
      case link        (URL, text: String)
      case color       (String)
      case conversation(id: ConversationID)
      case user        (id: UserID)
      case team        (id: TeamID)
      case userGroup   (id: UserGroupID)
      case broadcast   (range: BroadcastRange)
      
      /**
       * The markdown style applying to a string. I.e.: *bold*, _italic_, `code` or
       * ~strike~.
       *
       * This also maps to a style element of the new `rich_text_section`.
       */
      public struct FontStyle : OptionSet, Hashable, Encodable {
        public let rawValue : UInt8
        public init(rawValue: UInt8) { self.rawValue = rawValue }
        
        public static let bold   = FontStyle(rawValue: 1 << 1)
        public static let italic = FontStyle(rawValue: 1 << 2)
        public static let code   = FontStyle(rawValue: 1 << 3)
        public static let strike = FontStyle(rawValue: 1 << 4)

        // MARK: - Coding
        
        enum CodingKeys: String, CodingKey {
          case bold, italic, code, strike
        }
        public func encode(to encoder: Encoder) throws {
          guard !isEmpty else { return }
          var container = encoder.container(keyedBy: CodingKeys.self)
          if contains(.bold)   { try container.encode(true, forKey: .bold)   }
          if contains(.italic) { try container.encode(true, forKey: .italic) }
          if contains(.code)   { try container.encode(true, forKey: .code)   }
          if contains(.strike) { try container.encode(true, forKey: .strike) }
        }
      }
      
      // MARK: - Coding
      
      enum CodingKeys: String, CodingKey {
        case type, text, name, range, url, value, style
        case conversationID = "channel_id"
        case userID         = "user_id"
        case teamID         = "team_id"
        case userGroupID    = "usergroup_id"
      }
      
      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
          case .text(let text, let style):
            try container.encode("text",       forKey: .type)
            try container.encode(text,         forKey: .text)
            if !style.isEmpty { try container.encode(style,   forKey: .style) }
          case .emoji(let name):
            try container.encode("emoji",      forKey: .type)
            try container.encode(name,         forKey: .name)
          case .link(let url, let text):
            try container.encode("link",       forKey: .type)
            try container.encode(url,          forKey: .url)
            if !text.isEmpty {
              try container.encode(text,       forKey: .text)
            }
          case .color(let value):
            try container.encode("color",      forKey: .type)
            try container.encode(value,        forKey: .value)
          case .conversation(let id):
            try container.encode("channel_id", forKey: .type)
            try container.encode(id,           forKey: .conversationID)
          case .user(let id):
            try container.encode("user",      forKey: .type)
            try container.encode(id,          forKey: .userID)
          case .team(let id):
            try container.encode("team",      forKey: .type)
            try container.encode(id,          forKey: .teamID)
          case .userGroup(let id):
            try container.encode("usergroup", forKey: .type)
            try container.encode(id,          forKey: .userGroupID)
          case .broadcast(let range):
            try container.encode("broadcast", forKey: .type)
            try container.encode(range,       forKey: .range)
        }
      }
    }
    
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type
      case runs = "elements"
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
        case .preformatted(let text):
          try container.encode("rich_text_preformatted", forKey: .type)
          let run = Run.text(text, style: [])
          try container.encode([ run ],             forKey: .runs)
        case .section(let runs):
          try container.encode("rich_text_section", forKey: .type)
          try container.encode(runs,                forKey: .runs)
        case .quote(let runs):
          try container.encode("rich_text_quote", forKey: .type)
          try container.encode(runs,              forKey: .runs)
      }
    }
  }
}

public extension Block.RichTextElement.Run.BroadcastRange {
  
  @inlinable
  var blocksMarkdownString : String {
    // FIXME: syntax correct?
    switch self {
      case .channel  : return "!channel"
      case .here     : return "!here"
      case .everyone : return "!everyone"
    }
  }
}

public extension Block.RichTextElement.Run {
  
  @inlinable
  var blocksMarkdownString : String {
    // FIXME: this is only roughly right
    switch self {
      case .text (let value, let style) : return style.markdownStyle(value)
      case .emoji       (let name)      : return ":\(name):"
      case .link        (let url, let text):
        var ms = "<\(url.absoluteString)"
        if !text.isEmpty { ms += "|\(text)" }
        ms += ">"
        return ms
      case .color       (let value)     : return value
      case .conversation(let id)        : return "#\(id)"
      case .user        (let id)        : return "@\(id)"
      case .team        (let id)        : return "\(id)" // TBD
      case .userGroup   (let id)        : return "\(id)" // TBD
      case .broadcast   (let range)     : return range.blocksMarkdownString
    }
  }
}

public extension Sequence where Element == Block.RichTextElement.Run {

  @inlinable
  var blocksMarkdownString : String {
    return lazy.map { $0.blocksMarkdownString }.joined()
  }
}

extension Block.RichTextElement.Run.FontStyle: CustomStringConvertible {
  
  public var description: String {
    var ms = ""
    ms.reserveCapacity(4)
    if contains(.bold)   { ms += "*" }
    if contains(.italic) { ms += "_" }
    if contains(.strike) { ms += "~" }
    if contains(.code)   { ms += "`" }
    return ms
  }
}

extension Block.RichTextElement.Run.FontStyle {
  /**
   * Returns the given string wrapped in Markdown instructions represented
   * by the font style.
   * Does NOT escape the string.
   */
  public func markdownStyle(_ s: String) -> String {
    guard !s.isEmpty else { return "" }
    if isEmpty { return s }
    var ms = ""
    ms.reserveCapacity(s.count + 9)
    if contains(.bold)   { ms += "*" }
    if contains(.italic) { ms += "_" }
    if contains(.strike) { ms += "~" }
    if contains(.code)   { ms += "`" }
    ms += s
    if contains(.code)   { ms += "`" }
    if contains(.strike) { ms += "~" }
    if contains(.italic) { ms += "_" }
    if contains(.bold)   { ms += "*" }
    return ms
  }
}

public extension Block.RichText {
  @inlinable
  func asSection() -> Block.Section {
    return Block.Section(id: id, text: .init(blocksMarkdownString,
                                             type: .markdown(verbatim: true)))
  }
}

public extension Block.RichText {

  @inlinable
  var blocksMarkdownString : String {
    return elements.blocksMarkdownString
  }
}

public extension Sequence where Element == Block.RichTextElement {
  
  @inlinable
  var blocksMarkdownString : String {
    var ms = ""
    for element in self {
      switch element {
        case .section:
          if !ms.isEmpty && !ms.hasSuffix("\n\n") {
            ms += ms.hasSuffix("\n") ? "\n" : "\n\n"
          }
          ms += element.blocksMarkdownString.trimmingCharacters(in: .newlines)
          
        case .quote:
          if !ms.isEmpty && !ms.hasSuffix("\n") { ms += "\n" }
          let content =
            element.blocksMarkdownString.trimmingCharacters(in: .newlines)
          for line in content.split(separator: "\n") {
            ms += "> \(line)\n"
          }

        case .preformatted(let code):
          if !ms.isEmpty && !ms.hasSuffix("\n") { ms += "\n" }
          ms += "```"
          if !code.hasPrefix("\n") { ms += "\n" }
          ms += code
          if !code.hasSuffix("\n") { ms += "\n" }
          ms += "```\n"
      }
    }
    return ms
  }
}

public extension Block.RichTextElement {

  @inlinable
  var blocksMarkdownString : String {
    // No escaping at all
    switch self {
      case .section(let runs):
        return runs.blocksMarkdownString
        
      case .quote(let runs):
        let unquoted = runs.blocksMarkdownString
        return unquoted.lazy
          .split (separator: "\n")
          .map   { "> \($0)" }
          .joined(separator: "\n")
        
      case .preformatted(let code):
        guard !code.isEmpty else { return "" }
        var ms = ""
        ms.reserveCapacity(code.count + 8)
        ms += "```"
        if !code.hasPrefix("\n") { ms += "\n" }
        ms += code
        if !code.hasSuffix("\n") { ms += "\n" }
        ms += "```"
        return ms
    }
  }
}
