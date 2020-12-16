//
//  MultiChannelsSelect.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Docs: https://api.slack.com/reference/block-kit/block-elements#channel_multi_select
   */
  struct MultiChannelsSelect: SelectElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .input ]
                 
    public let actionID          : ActionID
    public let placeholder       : String // max 150 chars
    public let initialChannelIDs : [ ChannelID ]?
    public let maxSelectedItems  : Int?
    public let confirm           : ConfirmationDialog?
    
    public init(actionID          : ActionID,
                placeholder       : String,
                initialChannelIDs : [ ChannelID ]?         = nil,
                maxSelectedItems  : Int?                = nil,
                confirm           : ConfirmationDialog? = nil)
    {
      self.actionID          = actionID
      self.placeholder       = placeholder
      self.initialChannelIDs = initialChannelIDs
      self.maxSelectedItems  = maxSelectedItems
      self.confirm           = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder
      case actionID          = "action_id"
      case initialChannelIDs = "initial_channels"
      case initialChannelID  = "initial_channel"
      case maxSelectedItems  = "max_selected_items"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      if isSingle {
        try container.encode("channels_select", forKey: .type)
        if let v = initialChannelIDs?.first {
          try container.encode(v, forKey: .initialChannelID)
        }
      }
      else {
        try container.encode("multi_channels_select", forKey: .type)
        if let v = initialChannelIDs, !v.isEmpty {
          try container.encode(v, forKey: .initialChannelIDs)
        }
        if let v = maxSelectedItems, v >= 0 {
          try container.encode(v, forKey: .maxSelectedItems)
        }
      }
      try container.encode(actionID,                forKey: .actionID)
      try container.encode(Text(placeholder),       forKey: .placeholder)
      
      
      if let v = confirm { try container.encode(v, forKey: .confirm) }
    }
  }
}


// MARK: - Description

extension Block.MultiChannelsSelect: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<MultiChannelsSelect[\(actionID.id)]:"
    
    if !placeholder.isEmpty      { ms += " placeholder='\(placeholder)'" }
    if let v = maxSelectedItems  { ms += " #max=\(v)"  }
    
    if let options = initialChannelIDs {
      if      options.isEmpty    { ms += " EMPTY"      }
      else if options.count == 1 { ms += " single-channel=\(options[0])" }
      else                       { ms += " \(options)" }
    }
    
    if let v = confirm { ms += " \(v)" }
    ms += ">"
    return ms
  }
}
