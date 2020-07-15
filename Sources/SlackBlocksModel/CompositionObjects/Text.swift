//
//  Text.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * A block Text object:
   *
   * Docs: https://api.slack.com/reference/block-kit/composition-objects#text
   */
  struct Text: Encodable, Hashable {
    
    public enum TextType: Hashable {
      case plain   (encodeEmoji : Bool)
      case markdown(verbatim    : Bool)
    }
    
    public var type  : TextType
    public var value : String
    
    @inlinable
    public init(_ value: String, type: TextType = .plain(encodeEmoji: false)) {
      self.type  = type
      self.value = value
    }
    
    @inlinable
    public var isEmpty : Bool { return value.isEmpty }

    @inlinable
    var blocksMarkdownString : String {
      // TODO: escape plain stuff (there is no actual escaping, right?)
      return value
    }

    // MARK: - Coding
    
    enum CodingKeys: String, CodingKey {
      case type, text, emoji, verbatim
    }
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(value, forKey: .text)
      
      switch type {
        case .markdown(verbatim: true):
          try container.encode("mrkdwn", forKey: .type)
          try container.encode(true,     forKey: .verbatim)
        case .markdown(verbatim: false):
          try container.encode("mrkdwn", forKey: .type)
        case .plain(encodeEmoji: true):
          try container.encode("plain_text", forKey: .type)
          try container.encode(true, forKey: .emoji)
        case .plain(encodeEmoji: false):
          try container.encode("plain_text", forKey: .type)
      }
    }
  }
}

extension Block.Text: CustomStringConvertible {
  
  public var description: String {
    switch type {
      case .plain   (true)  : return "<Text(e): '\(value)'>"
      case .plain   (false) : return "<Text: '\(value)'>"
      case .markdown(true)  : return "<MarkdownText(V): '\(value)'>"
      case .markdown(false) : return "<MarkdownText: '\(value)'>"
    }
  }
}
