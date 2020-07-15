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
    
    public typealias YearMonthDay = Block.YearMonthDay
    
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


// MARK: - YMD Date Conversion Stuff

import struct Foundation.DateComponents

public extension Block.DatePicker.YearMonthDay {

  @inlinable
  init(_ dateComponents: DateComponents) {
    self.init(year  : Int16(dateComponents.year  ?? 2010),
              month : UInt8(dateComponents.month ?? 1),
              day   : UInt8(dateComponents.day   ?? 31))
  }
  
  @inlinable
  var dateComponents: DateComponents {
    var plain = DateComponents()
    plain.year  = Int(year)
    plain.month = Int(month)
    plain.day   = Int(day)
    return plain
  }
}

import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.Locale

public extension Block.DatePicker.YearMonthDay {

  @inlinable
  init(_ date: Date, in calendar: Calendar? = nil) {
    let calendar   = calendar ?? Locale.current.calendar
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    self.init(components)
  }
  
  @inlinable
  func date(in calendar: Calendar? = nil) -> Date? {
    let calendar = calendar ?? Locale.current.calendar
    var components = dateComponents
    components.hour = 12 // you know it's wrong, but still ;-)
    return calendar.date(from: components)
  }
}
