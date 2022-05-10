//
//  YearMonthDay.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Represents a Time, like in just the hour/minute as a combination of
   * hour:minute. Since that is used in the Slack API.
   */
  @frozen
  struct HourMinute: Codable {
    
    public var hour: UInt8, minute: UInt8

    @inlinable
    public init(hour: UInt8, minute: UInt8) {
      self.hour   = hour
      self.minute = minute
    }
    
    @inlinable
    public init?(string: String) {
      // HH:MM
      guard !string.isEmpty else { return nil }
      let parts = string.split(separator: ":", maxSplits: 2,
                               omittingEmptySubsequences: true)
      assert(parts.count == 2)
      guard parts.count == 2 else { return nil }
      guard let hour = Int(parts[0]), let minute = Int(parts[1]),
            hour >= 0 && hour <= 24, minute >= 0 && minute <= 60 else
      {
        assertionFailure("could not parse time: \(string)")
        return nil
      }
      
      self.hour   = UInt8(hour)
      self.minute = UInt8(minute)
    }
    
    public init(from decoder: Decoder) throws {
      typealias Error = InteractiveRequest.DecodingError
      
      let container = try decoder.singleValueContainer()
      let s = try container.decode(String.self)
      guard let hm = HourMinute(string: s) else {
        throw Error.unexpectedValue(s)
      }
      
      self = hm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(stringValue)
    }
    
    @inlinable
    public var stringValue: String {
      let h = leftpad(String(hour),   2)
      let m = leftpad(String(minute), 2)
      return "\(h):\(m)"
    }
  }

  /**
   * Represents a Date, like in just the date as a combination of
   * year/month/day. Since that is used in the Slack API.
   */
  @frozen
  struct YearMonthDay: Codable {
    
    public var year: Int16, month: UInt8, day: UInt8
    
    @inlinable
    public init(year: Int16, month: UInt8, day: UInt8) {
      self.year  = year
      self.month = month
      self.day   = day
    }
    
    @inlinable
    public init?(string: String) {
      // YYYY-mm-dd
      guard !string.isEmpty else { return nil }
      let parts = string.split(separator: "-", maxSplits: 3,
                               omittingEmptySubsequences: true)
      assert(parts.count == 3)
      guard parts.count == 3 else { return nil }
      guard let year  = Int(parts[0]),
            let month = Int(parts[1]),
            let day   = Int(parts[2]),
            month >= 1 && month <= 12, day >= 1 && day <= 31
       else
      {
        assertionFailure("could not parse date: \(string)")
        return nil
      }
      
      self.year  = Int16(year)
      self.month = UInt8(month)
      self.day   = UInt8(day)
    }

    public init(from decoder: Decoder) throws {
      typealias Error = InteractiveRequest.DecodingError
      
      let container = try decoder.singleValueContainer()
      let s = try container.decode(String.self)
      guard let ymd = YearMonthDay(string: s) else {
        throw Error.unexpectedValue(s)
      }
      
      self = ymd
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(stringValue)
    }
    
    @inlinable
    public var stringValue: String {
      let y = leftpad(String(year),  4)
      let m = leftpad(String(month), 2)
      let d = leftpad(String(day),   2)
      return "\(y)-\(m)-\(d)"
    }
  }
}

@usableFromInline func leftpad(_ s: String, _ width: Int) -> String {
  let left = width - s.count
  return left <= 0 ? s : String(repeating: "0", count: left) + s
}


// MARK: - Description

extension Block.YearMonthDay: CustomStringConvertible {
  @inlinable public var description: String { return stringValue }
}
extension Block.HourMinute: CustomStringConvertible {
  @inlinable public var description: String { return stringValue }
}


// MARK: - YMD Date Conversion Stuff

import struct Foundation.DateComponents

public extension Block.YearMonthDay {

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

public extension Block.HourMinute {

  @inlinable
  init(_ dateComponents: DateComponents) {
    self.init(hour   : UInt8(dateComponents.hour   ?? 0),
              minute : UInt8(dateComponents.minute ?? 0))
  }
  
  @inlinable
  var dateComponents: DateComponents {
    var plain = DateComponents()
    plain.hour   = Int(hour)
    plain.minute = Int(minute)
    return plain
  }
}

import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.Locale

public extension Block.YearMonthDay {

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

public extension Block.HourMinute {
  
  @inlinable
  init(_ date: Date, in calendar: Calendar? = nil) {
    let calendar   = calendar ?? Locale.current.calendar
    let components = calendar.dateComponents([.hour, .minute], from: date)
    self.init(components)
  }
}
