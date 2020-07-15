//
//  Token.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public struct Token: Hashable, Codable, ExpressibleByStringLiteral {

  public let value : String
  public init(_ value: String) { self.value = value }

  public init(stringLiteral value: String) { self.init(value) }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
  
  public var isValid : Bool {
    // TODO: check for xox prefix?
    return !value.isEmpty
  }
}
