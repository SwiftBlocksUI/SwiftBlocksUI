//
//  DateFormatToken.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class Foundation.DateFormatter

public extension Block {
  
  // TBD: maybe move to BlocksModel?
  
  /**
   * A token which can be used within a Slack date format string.
   *
   * Dox: https://api.slack.com/reference/surfaces/formatting#date-formatting
   */
  enum DateFormatToken {
        
    /**
     * Gives: "1973-01-31" (`{date_num}`)
     *
     * Leading zeros before month/date.
     */
    case isoDate
    
    /**
     * Styles:
     * - `.medium`/`.short` - "Jan 31, 1973" (`{date_short}`)
     * - `.long`/`.none`    - "January 31st, 1973" (`{date}`)
     * - `.full`            - "Wednesday, January 31st, 1973" (`{date_long}`)
     *
     * If pretty is on, this will use "tomorrow", "today" etc if appropriate.
     */
    case date(style: DateFormatter.Style, pretty: Bool)
    
    /**
     * Styles:
     *  - `.none`/`.short` - "9:41 AM"    `{time}`
     *  - `.medium`/...    - "9:41:23 AM" `{time_secs}`
     */
    case time(style: DateFormatter.Style)
    
    case text(String)
    
    
    // MARK: - Configurations
    
    public static let date     = DateFormatToken.date(style: .long, pretty: false)
    public static let time     = DateFormatToken.time(style: .short)
    public static let timeSecs = DateFormatToken.time(style: .medium)

    public static let dateLong  =
                        DateFormatToken.date(style: .full,  pretty: false)
    public static let dateShort =
                        DateFormatToken.date(style: .short, pretty: false)
    public static let datePrettyLong  =
                        DateFormatToken.date(style: .full, pretty: true)
    public static let datePrettyShort =
                        DateFormatToken.date(style: .short, pretty: true)
    public static let datePretty =
                        DateFormatToken.date(style: .long, pretty: true)

    
    // MARK: - API String Representation
    
    @inlinable
    public var tokenString: String {
      switch self {
        case .isoDate:  return "{date_num}"
          
        case .date(.long,   false), .date(.none,  false): return "{date}"
        case .date(.long,   true ), .date(.none,  true ): return "{date_pretty}"
        case .date(.medium, false), .date(.short, false): return "{date_short}"
        case .date(.medium, true ), .date(.short, true ):
          return "{date_pretty_short}"
        case .date(.full, false): return "{date_long}"
        case .date(.full, true ): return "{date_pretty_long}"
          
        case .time(.none), .time(.short): return "{time}"
        case .time(.medium), .time(.long), .time(.full): return "{time_secs}"
          
        case .text(let value) : return value
          
        case .date(let style, let pretty): // hm, why necessary?
          assertionFailure("unexpected date style: \(style)")
          return pretty ? "{date_pretty}" : "{date}"
        case .time(let style):
          assertionFailure("unexpected time style: \(style)")
          return "{time}"
      }
    }
    
    @inlinable
    public init(string: String) {
      switch string {
        case "{date_num}"          : self = .isoDate
        case "{date}"              : self = .date(style: .long,  pretty: false)
        case "{date_pretty}"       : self = .date(style: .long,  pretty: true)
        case "{date_short}"        : self = .date(style: .short, pretty: false)
        case "{date_pretty_short}" : self = .date(style: .short, pretty: true)
        case "{date_long}"         : self = .date(style: .full,  pretty: false)
        case "{date_pretty_long}"  : self = .date(style: .full,  pretty: true)
        case "{time}"              : self = .time(style: .short)
        case "{time_secs}"         : self = .time(style: .medium)
        default:
          assert(string.first != "{", "unsupported dateformat token")
          self = .text(string)
      }
    }
  }
}
