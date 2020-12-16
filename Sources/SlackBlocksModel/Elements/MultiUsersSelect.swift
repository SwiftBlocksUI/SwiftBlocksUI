//
//  MultiUsersSelect.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Docs: https://api.slack.com/reference/block-kit/block-elements#users_multi_select
   */
  struct MultiUsersSelect: SelectElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .input ]
                 
    public let actionID         : ActionID
    public let placeholder      : String // max 150 chars
    public let initialUserIDs   : [ UserID ]?
    public let maxSelectedItems : Int?
    public let confirm          : ConfirmationDialog?
    
    public init(actionID         : ActionID,
                placeholder      : String,
                initialUserIDs   : [ UserID ]?         = nil,
                maxSelectedItems : Int?                = nil,
                confirm          : ConfirmationDialog? = nil)
    {
      self.actionID         = actionID
      self.placeholder      = placeholder
      self.initialUserIDs   = initialUserIDs
      self.maxSelectedItems = maxSelectedItems
      self.confirm          = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder
      case actionID         = "action_id"
      case initialUserIDs   = "initial_users"
      case initialUserID    = "initial_user"
      case maxSelectedItems = "max_selected_items"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      if isSingle {
        if let v = initialUserIDs?.first {
          try container.encode(v, forKey: .initialUserID)
        }
      }
      else {
        try container.encode("multi_users_select", forKey: .type)
        if let v = initialUserIDs, !v.isEmpty {
          try container.encode(v, forKey: .initialUserIDs)
        }
        if let v = maxSelectedItems, v >= 0 {
          try container.encode(v, forKey: .maxSelectedItems)
        }
      }
      try container.encode(actionID,             forKey: .actionID)
      try container.encode(Text(placeholder),    forKey: .placeholder)
      
      if let v = confirm { try container.encode(v, forKey: .confirm) }
    }
  }
}


// MARK: - Description

extension Block.MultiUsersSelect: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<MultiUsersSelect[\(actionID.id)]:"
    
    if !placeholder.isEmpty     { ms += " placeholder='\(placeholder)'" }
    if let v = maxSelectedItems { ms += " #max=\(v)" }

    if let options = initialUserIDs {
      if      options.isEmpty    { ms += " EMPTY"      }
      else if options.count == 1 { ms += " single-user=\(options[0])" }
      else                       { ms += " \(options)" }
    }
    
    if let v = confirm { ms += " \(v)" }
    ms += ">"
    return ms
  }
}
