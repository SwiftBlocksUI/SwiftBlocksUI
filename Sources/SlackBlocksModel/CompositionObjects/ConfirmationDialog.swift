//
//  ConfirmationDialog.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * A confirmation dialog
   *
   * Docs: https://api.slack.com/reference/block-kit/composition-objects#confirm
   */
  struct ConfirmationDialog: Encodable {
    
    public enum Style: String, Encodable {
      case danger, primary, none
    }
    
    public var title   : String  // max 100 chars
    public var text    : Text    // max 300 chars
    public var confirm : String  // max  30 chars
    public var deny    : String  // max  30 chars
    public var style   : Style
    
    public init(title   : String, text : Text,
                confirm : String = "OK", deny : String = "Cancel",
                style   : Style = .none)
    {
      self.title   = title
      self.text    = text
      self.confirm = confirm
      self.deny    = deny
      self.style   = style
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case title, text, confirm, deny, style
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(Text(title),   forKey: .title)
      try container.encode(text,          forKey: .text)
      try container.encode(Text(confirm), forKey: .confirm)
      try container.encode(Text(deny),    forKey: .deny)
      if style != .none { try container.encode(style, forKey: .style) }
    }
  }
}
