//
//  DatePicker.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Locale
import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.DateComponents
import enum   SlackBlocksModel.Block

/**
 * A picker to pick a date. That is year, month, day - NOT time.
 *
 * Example:
 *
 *     DatePicker("Pick a date!", selection: $date)
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#multi_select
 */
public struct DatePicker: Blocks {
  
  public typealias YearMonthDay = Block.DatePicker.YearMonthDay
  
  @usableFromInline let actionID    : ActionIDStyle
  @usableFromInline let title       : String
  @usableFromInline let placeholder : String?
  @usableFromInline let selection   : Binding<YearMonthDay>?
  @usableFromInline let action      : Action?

  @inlinable
  public init<S>(actionID          : ActionIDStyle = .auto,
                 _     title       : S,
                 selection         : Binding<YearMonthDay>?,
                 placeholder       : String?,
                 action            : Action?)
           where S: StringProtocol
  {
    self.actionID    = actionID
    self.placeholder = placeholder
    self.title       = String(title)
    self.selection   = selection
    self.action      = action
  }
}


// MARK: - Foundation Date Type Bindings

public extension DatePicker {
  
  @inlinable
  init(_ title     : String         = "",
       selection   : Binding<Date>,
       placeholder : String?        = nil,
       calendar    : Calendar?      = nil,
       action      : Action?        = nil)
  {
    self.init(title, selection: selection.rebindAsYearMonthDay(calendar),
              placeholder: placeholder, action: action)
  }

  
  @inlinable
  init(_ title     : String         = "",
       selection   : Binding<Date>,
       placeholder : String?        = nil,
       calendar    : Calendar?      = nil,
       action      : @escaping SyncAction)
  {
    self.init(title, selection: selection.rebindAsYearMonthDay(calendar),
              placeholder: placeholder)
    {
      response in try action(); response.end()
    }
  }
}

public extension DatePicker {
  
  @inlinable
  init(_ title     : String         = "",
       selection   : Binding<DateComponents>,
       placeholder : String?        = nil,
       calendar    : Calendar?      = nil,
       action      : Action?        = nil)
  {
    self.init(title, selection: selection.rebindAsYearMonthDay(calendar),
              placeholder: placeholder, action: action)
  }

  @inlinable
  init(_ title     : String         = "",
       selection   : Binding<DateComponents>,
       placeholder : String?        = nil,
       calendar    : Calendar?      = nil,
       action      : @escaping SyncAction)
  {
    self.init(title, selection: selection.rebindAsYearMonthDay(calendar),
              placeholder: placeholder)
    {
      response in try action(); response.end()
    }
  }
}


// MARK: - Rebind Date Values

public extension Binding where Value == Date {
  
  func rebindAsYearMonthDay(_ calendar: Calendar? = nil)
       -> Binding<DatePicker.YearMonthDay>
  {
    return .init(
      getValue: { return .init(self.getter(), in: calendar) },
      setValue: { ymd in
        guard let date = ymd.date(in: calendar) else {
          return globalBlocksLog.error("could not convert to Date: \(ymd)")
        }
        self.setter(date)
      }
    )
  }
}

public extension Binding where Value == DateComponents {
  
  func rebindAsYearMonthDay(_ calendar: Calendar? = nil)
       -> Binding<DatePicker.YearMonthDay>
  {
    return .init(
      getValue: { return .init(self.getter())            },
      setValue: { ymd in self.setter(ymd.dateComponents) }
    )
  }
}
