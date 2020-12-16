//
//  TimePicker.swift
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
 * A picker to pick a time. That is hour/minute, no date. (see `DatePicker`)
 *
 * The `selection` can be either of those:
 * - `TimePicker.HourMinute` (a BlocksUI struct w/ hour/minute properties)
 * - a Foundation `DateComponents`
 *
 * Example:
 *
 *     TimePicker("Pick a time!", selection: $time)
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#timepicker
 */
public struct TimePicker: Blocks {
  
  public typealias HourMinute = Block.HourMinute
  
  @usableFromInline let actionID    : ActionIDStyle
  @usableFromInline let title       : String
  @usableFromInline let placeholder : String?
  @usableFromInline let selection   : Binding<HourMinute>?
  @usableFromInline let action      : Action?

  @inlinable
  public init<S>(actionID          : ActionIDStyle = .auto,
                 _     title       : S,
                 selection         : Binding<HourMinute>?,
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

public extension TimePicker {
  
  @inlinable
  init(_ title     : String         = "",
       selection   : Binding<DateComponents>,
       placeholder : String?        = nil,
       calendar    : Calendar?      = nil,
       action      : Action?        = nil)
  {
    self.init(title, selection: selection.rebindAsHourMinute(calendar),
              placeholder: placeholder, action: action)
  }

  @inlinable
  init(_ title     : String         = "",
       selection   : Binding<DateComponents>,
       placeholder : String?        = nil,
       calendar    : Calendar?      = nil,
       action      : @escaping SyncAction)
  {
    self.init(title, selection: selection.rebindAsHourMinute(calendar),
              placeholder: placeholder)
    {
      response in try action(); response.end()
    }
  }
}


// MARK: - Rebind Date Values

public extension Binding where Value == DateComponents {
  
  func rebindAsHourMinute(_ calendar: Calendar? = nil)
       -> Binding<TimePicker.HourMinute>
  {
    return .init(
      getValue: { return .init(self.getter())          },
      setValue: { hm in self.setter(hm.dateComponents) }
    )
  }
}
