//
//  MarkdownDate.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.URL
import enum  SlackBlocksModel.Block

public extension Markdown {
    
  /**
   * Creates the mrkdwn for the given `Date`.
   *
   * Remember that the Foundation `Date` is just a UTC timestamp, it carries no
   * timezone or actual date components.
   *
   * The format is the Slack date token syntax described over here:
   *
   *   https://api.slack.com/reference/surfaces/formatting#date-formatting
   *
   * It allows textual content in the format string, not just the tokens.
   *
   * A date can also include a link and a fallback text.
   *
   * Examples:
   *
   *     Markdown(Date(), format: "{date_long_pretty}")
   *     Markdown(Date(), format: "{date_long_pretty}",
   *              fallback: "December 17, 2020")
   *     Markdown(Date(), format: "{time}")
   *
   *     Markdown(Date(), format: "Posted {date_num} {time_secs}")
   *
   */
  @inlinable
  init(date: Date, format: String, url: URL? = nil, fallback: String? = nil) {
    let timestamp = Int64(date.timeIntervalSince1970)
    if url == nil && fallback == nil {
      self.init("<!date^\(timestamp)^\(format.stringByEscapingMarkdown())>")
    }
    else {
      var ms = "<!date^\(timestamp)^\(format.stringByEscapingMarkdown())"
      if let url = url { ms += "^\(url.absoluteString)" }
      if let s = fallback?.stringByEscapingFallbackMarkdown() { ms += "|\(s)" }
      ms += ">"
      self.init(ms)
    }
  }
  
  /**
   * Creates the mrkdwn for the given `Date`.
   *
   * Remember that the Foundation `Date` is just a UTC timestamp, it carries no
   * timezone or actual date components.
   *
   * The format is a `DateFormatToken` enum case.
   *
   * A date can also include a link and a fallback text.
   *
   * Examples:
   *
   *     Markdown(Date(), format: .date(style: .long, pretty: true))
   *     Markdown(Date(), format: .time(style: .short))
   *     Markdown(Date(), format: .timeShort)
   *
   */
  @inlinable
  init(date: Date, format: Block.DateFormatToken, url: URL? = nil,
       fallback: String? = nil)
  {
    self.init(date: date, format: format.tokenString,
              url: url, fallback: fallback)
  }
}
