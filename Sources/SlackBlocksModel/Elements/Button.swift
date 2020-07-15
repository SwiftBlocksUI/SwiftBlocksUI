//
//  Button.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {
  
  struct Button: InteractiveBlockElement {

    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .actions ]
    
    public enum Style: String, Codable {
      case primary, danger, none
    }
    
    public let actionID : ActionID // unique, required
    public var text     : String   // max 75 chars
    public var url      : URL?     // max 3k chars
    public let value    : String?  // max 2k chars
    public let style    : Style
    public var confirm  : ConfirmationDialog?

    public init(actionID : ActionID,
                text     : String,
                url      : URL?                = nil,
                value    : String?             = nil,
                style    : Style               = .none,
                confirm  : ConfirmationDialog? = nil)
    {
      self.actionID = actionID
      self.text     = text
      self.url      = url
      self.value    = value
      self.style    = style
      self.confirm  = confirm
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, text, url, value, style, confirm
      case actionID = "action_id"
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("button",   forKey: .type)
      try container.encode(actionID,   forKey: .actionID)
      try container.encode(Text(text), forKey: .text)
      if let v = url     { try container.encode(v,     forKey: .url)     }
      if let v = value   { try container.encode(v,     forKey: .value)   }
      if let v = confirm { try container.encode(v,     forKey: .confirm) }
      if style != .none  { try container.encode(style, forKey: .style)   }
    }
  }
}
