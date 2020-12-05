//
//  Token.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A Slack authentication token
 *
 * Those come in various versions, the one appropriate for most apps are
 * bot tokens ("xoxb-...").
 */
public struct Token: Hashable, Codable, ExpressibleByStringLiteral {

  public let value : String
  public init(_ value: String) { self.value = value }

  public init(stringLiteral value: String) { self.init(value) }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.value = try container.decode(String.self)
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
  
  public var isValid : Bool {
    return value.hasPrefix("xox")
  }

  /**
   * TBD: Is this right? If I chat.postMessage w/ an xoxb token, `rich_text`
   *      blocks seem to be unsupported. It does seem to work w/ other tokens.
   */
  public var supportsRichText: Bool {
    return !value.hasPrefix("xoxb-")
  }
}

extension Token: CustomStringConvertible {
  
  public var description: String {
    return "<Token: \(value)\(isValid ? "" : " INVALID")>"
  }
}
