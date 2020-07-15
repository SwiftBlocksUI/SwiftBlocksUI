//
//  PlainTextInput.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Just a plain text field.
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#input
   */
  struct PlainTextInput: BlockElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .actions, .input ]
                 
    public let actionID         : ActionID
    public let placeholder      : String? // max 150 chars
    public let initialValue     : String?
    public let multiline        : Bool
    public let minLength        : Int? // max 3000
    public let maxLength        : Int?
    
    public init(actionID     : ActionID,
                placeholder  : String? = nil,
                initialValue : String? = nil,
                multiline    : Bool    = false,
                minLength    : Int?    = nil,
                maxLength    : Int?    = nil)
    {
      self.actionID     = actionID
      self.placeholder  = placeholder
      self.initialValue = initialValue
      self.multiline    = multiline
      self.minLength    = minLength
      self.maxLength    = maxLength
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder, multiline
      case actionID       = "action_id"
      case initialValue   = "initial_value"
      case minLength      = "min_length"
      case maxLength      = "max_length"
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("plain_text_input", forKey: .type)
      try container.encode(actionID,           forKey: .actionID)
      
      if multiline {
        try container.encode(true, forKey: .multiline)
      }
      
      if let v = placeholder {
        try container.encode(Text(v), forKey: .placeholder)
      }
      if let v = initialValue {
        try container.encode(v, forKey: .initialValue)
      }

      if let v = minLength, v >= 0 {
        try container.encode(v, forKey: .minLength)
      }
      if let v = maxLength, v >= 0 {
        try container.encode(v, forKey: .maxLength)
      }
    }
  }
}
