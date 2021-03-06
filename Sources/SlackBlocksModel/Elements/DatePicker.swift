//
//  DatePicker.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Docs: https://api.slack.com/reference/block-kit/block-elements#datepicker
   */
  struct DatePicker: InteractiveBlockElement, Encodable {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .actions, .input ]
                 
    public let actionID    : ActionID
    public let placeholder : String? // max 150 chars
    public let initialDate : YearMonthDay?
    public let confirm     : ConfirmationDialog?
    
    public init(actionID    : ActionID,
                placeholder : String?             = nil,
                initialDate : YearMonthDay?       = nil,
                confirm     : ConfirmationDialog? = nil)
    {
      self.actionID    = actionID
      self.placeholder = placeholder
      self.initialDate = initialDate
      self.confirm     = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder
      case actionID    = "action_id"
      case initialDate = "initial_date"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("datepicker", forKey: .type)
      try container.encode(actionID,     forKey: .actionID)
      
      if let v = placeholder {
        try container.encode(Text(v), forKey: .placeholder)
      }
      
      if let v = initialDate { try container.encode(v, forKey: .initialDate) }
      if let v = confirm     { try container.encode(v, forKey: .confirm)     }
    }
  }
}


// MARK: - Description

extension Block.DatePicker: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<DatePicker[\(actionID.id)]:"
    if let v = placeholder { ms += " placeholder='\(v)'" }
    if let v = initialDate { ms += " initial=\(v)"       }
    if let v = confirm     { ms += " \(v)"               }
    ms += ">"
    return ms
  }
}
