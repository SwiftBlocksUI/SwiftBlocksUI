//
//  MultiExternalSelect.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Select driven by an external datasource (needs to be configured in the app
   * config).
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#external_select
   */
  struct MultiExternalSelect: SelectElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .input ]
                 
    public let actionID         : ActionID
    public let placeholder      : String // max 150 chars
    public let initialOptions   : [ Option ]?
    public let minQueryLength   : Int?
    public let maxSelectedItems : Int?
    public let confirm          : ConfirmationDialog?
    
    public init(actionID         : ActionID,
                placeholder      : String,
                initialOptions   : [ Option ]?         = nil,
                minQueryLength   : Int?                = nil,
                maxSelectedItems : Int?                = nil,
                confirm          : ConfirmationDialog? = nil)
    {
      self.actionID         = actionID
      self.placeholder      = placeholder
      self.initialOptions   = initialOptions
      self.minQueryLength   = minQueryLength
      self.maxSelectedItems = maxSelectedItems
      self.confirm          = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder
      case actionID         = "action_id"
      case initialOptions   = "initial_options"
      case minQueryLength   = "min_query_length"
      case maxSelectedItems = "max_selected_items"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      if isSingle {
        try container.encode("external_select", forKey: .type)
      }
      else {
        try container.encode("multi_external_select", forKey: .type)
        if let v = maxSelectedItems, v >= 0 {
          try container.encode(v, forKey: .maxSelectedItems)
        }
      }
      try container.encode(actionID,                forKey: .actionID)
      try container.encode(Text(placeholder),       forKey: .placeholder)
      
      if let v = initialOptions, !v.isEmpty {
        try container.encode(v, forKey: .initialOptions)
      }
      
      if let v = minQueryLength, v >= 0 {
        try container.encode(v, forKey: .minQueryLength)
      }
      if let v = confirm { try container.encode(v, forKey: .confirm) }
    }
  }
}
