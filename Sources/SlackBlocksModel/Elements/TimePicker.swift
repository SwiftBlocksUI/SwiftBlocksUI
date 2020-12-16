//
//  TimePicker.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Docs: https://api.slack.com/reference/block-kit/block-elements#timepicker
   */
  struct TimePicker: InteractiveBlockElement, Encodable {
    
    public typealias YearMonthDay = Block.YearMonthDay
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .actions, .input ]
                 
    public let actionID    : ActionID
    public let placeholder : String? // max 150 chars
    public let initialTime : HourMinute?
    public let confirm     : ConfirmationDialog?
    
    public init(actionID    : ActionID,
                placeholder : String?             = nil,
                initialTime : HourMinute?         = nil,
                confirm     : ConfirmationDialog? = nil)
    {
      self.actionID    = actionID
      self.placeholder = placeholder
      self.initialTime = initialTime
      self.confirm     = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder
      case actionID    = "action_id"
      case initialTime = "initial_time"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("timepicker", forKey: .type)
      try container.encode(actionID,     forKey: .actionID)
      
      if let v = placeholder {
        try container.encode(Text(v), forKey: .placeholder)
      }
      
      if let v = initialTime { try container.encode(v, forKey: .initialTime) }
      if let v = confirm     { try container.encode(v, forKey: .confirm)     }
    }
  }
}


// MARK: - Description

extension Block.TimePicker: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<TimePicker[\(actionID.id)]:"
    if let v = placeholder { ms += " placeholder='\(v)'" }
    if let v = initialTime { ms += " initial=\(v)"       }
    if let v = confirm     { ms += " \(v)"               }
    ms += ">"
    return ms
  }
}
