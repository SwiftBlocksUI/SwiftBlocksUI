//
//  MultiConversationsSelect.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Docs: https://api.slack.com/reference/block-kit/block-elements#conversation_multi_select
   */
  struct MultiConversationsSelect: SelectElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .input ]
                 
    public let actionID               : ActionID
    public let placeholder            : String // max 150 chars
    public let initialConversationIDs : [ ConversationID ]?
    public let defaultToCurrent       : Bool
    public let maxSelectedItems       : Int?
    public let filter                 : Filter?
    public let confirm                : ConfirmationDialog?
    
    public init(actionID               : ActionID,
                placeholder            : String,
                initialConversationIDs : [ ConversationID ]? = nil,
                defaultToCurrent       : Bool                = false,
                maxSelectedItems       : Int?                = nil,
                filter                 : Filter?             = nil,
                confirm                : ConfirmationDialog? = nil)
    {
      self.actionID               = actionID
      self.placeholder            = placeholder
      self.initialConversationIDs = initialConversationIDs
      self.defaultToCurrent       = defaultToCurrent
      self.maxSelectedItems       = maxSelectedItems
      self.filter                 = filter
      self.confirm                = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder, filter
      case actionID               = "action_id"
      case initialConversationIDs = "initial_conversations"
      case initialConversationID  = "initial_conversation"
      case defaultToCurrent       = "default_to_current_conversation"
      case maxSelectedItems       = "max_selected_items"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      if isSingle {
        try container.encode("conversations_list", forKey: .type)
        if let v = initialConversationIDs?.first {
          try container.encode(v, forKey: .initialConversationID)
        }
      }
      else {
        try container.encode("multi_conversations_select", forKey: .type)
        if let v = initialConversationIDs, !v.isEmpty {
          try container.encode(v, forKey: .initialConversationIDs)
        }
        else if defaultToCurrent {
          try container.encode(true, forKey: .defaultToCurrent)
        }
        if let v = maxSelectedItems, v >= 0 {
          try container.encode(v, forKey: .maxSelectedItems)
        }
      }
      try container.encode(actionID,                     forKey: .actionID)
      try container.encode(Text(placeholder),            forKey: .placeholder)
      
      if let v = filter  { try container.encode(v, forKey: .filter)  }
      if let v = confirm { try container.encode(v, forKey: .confirm) }
    }
  }
}


// MARK: - Description

extension Block.MultiConversationsSelect: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<MultiConversationsSelect[\(actionID.id)]:"
    
    if !placeholder.isEmpty     { ms += " placeholder='\(placeholder)'" }
    if let v = maxSelectedItems { ms += " #max=\(v)" }
    if let v = filter           { ms += " filter=\(v)" }

    if let options = initialConversationIDs {
      if      options.isEmpty    { ms += " EMPTY"      }
      else if options.count == 1 { ms += " single-conv=\(options[0])" }
      else                       { ms += " \(options)" }
    }
    
    if defaultToCurrent { ms += " default-to-current" }
    
    if let v = confirm { ms += " \(v)" }
    ms += ">"
    return ms
  }
}
