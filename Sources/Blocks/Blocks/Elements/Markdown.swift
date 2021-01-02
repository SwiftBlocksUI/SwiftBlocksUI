//
//  Markdown.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class Foundation.Formatter
import class Foundation.Bundle
import enum  SlackBlocksModel.Block

/**
 * This element emits raw
 * [Slack Markdown](https://api.slack.com/reference/surfaces/formatting#basics).
 *
 * Markdown can be styled:
 *
 *     Markdown("Price")
 *       .bold()
 *
 * Will result in
 *
 *     *Price*
 *
 * `Markdown` elements can be added together, Strings can be appended:
 *
 *     Markdown("Price:").bold + Markdown(" 100") + "€"
 *
 * Will result in
 *
 *     *Price:* 100 €
 *
 * The block also supports generating Slack specific runs, e.g. dates:
 *
 *     Markdown(Date(), format: .date)
 *
 */
public struct Markdown: Equatable {
  
  // TODO: Doesn't work in quote yet
  
  public let markdown : String
  
  @inlinable
  public init(_ markdown: String) {
    self.markdown = markdown
  }
  
  @inlinable
  public static func +(lhs: Markdown, rhs: Markdown) -> Markdown {
    // FIXME: Make smarter, combine runs
    return Markdown(lhs.markdown + rhs.markdown)
  }
  @inlinable
  public static func +(lhs: Markdown, rhs: String) -> Markdown {
    return Markdown(lhs.markdown + rhs)
  }
  @inlinable
  public static func +(lhs: Text, rhs: Markdown) -> Markdown {
    return Markdown(lhs.slackMarkdownString) + rhs
  }
}

extension Markdown: Blocks {
  public typealias Body = Never
}

public extension Markdown {
  
  @usableFromInline
  internal func adding(_ modifier: Text.Modifier) -> Markdown {
    return Markdown(modifier.markdownStyle(markdown))
  }
  @inlinable func bold()   -> Markdown { return adding(.bold)   }
  @inlinable func italic() -> Markdown { return adding(.italic) }
  @inlinable func code()   -> Markdown { return adding(.code)   }
  @inlinable func strike() -> Markdown { return adding(.strike) }
}

 extension String {
  
  @usableFromInline
  func stringByRemovingMarkdown() -> String {
    return self // TODO :-)
  }
  @usableFromInline
  func stringByEscapingMarkdown() -> String {
    // Note how the Slash is escaped here:
    //   <!date^1608205500^{time}|12\/17\/20>
    return self
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "/", with: "\\/")
      .replacingOccurrences(of: ">", with: "\\>")
  }
  @usableFromInline
  func stringByEscapingFallbackMarkdown() -> String {
    return stringByEscapingMarkdown()
  }
}

public extension Markdown {
  
  var slackMarkdownString: String {
    return markdown
  }
  
  var contentString: String {
    return markdown.stringByRemovingMarkdown()
  }
}

public extension Markdown {
  
  @inlinable
  init(emoji named: String) {
    assert(!named.contains(":"))
    self.init(":\(named):")
  }
}
