//
//  YearMonthDay.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {

  /**
   * Represents a Date, like in just the date as a combination of
   * year/month/day. Since that is used in the Slack API.
   */
  struct YearMonthDay: Codable {
    
    public var year: Int16, month: UInt8, day: UInt8
    
    @inlinable
    public init(year: Int16, month: UInt8, day: UInt8) {
      self.year  = year
      self.month = month
      self.day   = day
    }
    
    public init(from decoder: Decoder) throws {
      typealias Error = InteractiveRequest.DecodingError
      
      func parseYMDString(_ s: String) -> YearMonthDay? {
        // YYYY-mm-dd
        guard !s.isEmpty else { return nil }
        let parts = s.split(separator: "-", maxSplits: 3,
                            omittingEmptySubsequences: true)
        assert(parts.count == 3)
        guard parts.count == 3 else { return nil }
        guard let year  = Int(parts[0]),
              let month = Int(parts[1]),
              let day   = Int(parts[2]) else
        {
          assertionFailure("could not parse date: \(s)")
          return nil
        }
        
        return .init(year: Int16(year), month: UInt8(month), day: UInt8(day))
      }

      let container = try decoder.singleValueContainer()
      let s = try container.decode(String.self)
      guard let ymd = parseYMDString(s) else {
        throw Error.unexpectedValue(s)
      }
      
      self.init(year: ymd.year, month: ymd.month, day: ymd.day)
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(stringValue)
    }
    
    @inlinable
    public var stringValue: String {
      func leftpad(_ s: String, _ width: Int) -> String {
        let left = width - s.count
        return left <= 0 ? s : String(repeating: "0", count: left) + s
      }
      let y = leftpad(String(year),  4)
      let m = leftpad(String(month), 2)
      let d = leftpad(String(day),   2)
      return "\(y)-\(m)-\(d)"
    }
  }
}


// MARK: - Description

extension Block.YearMonthDay: CustomStringConvertible {
  
  @inlinable
  public var description: String {
    return stringValue
  }
}
