//
//  StringID.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A String based ID
 *
 * A mixin protocol to make having tons of ID types (`CallbackID`, `ActionID`, etc)
 * reasonable.
 *
 * Features:
 * - initialization from String literals, e.g.: `Button(actionID: "Wow")`
 * - Initialization from String `RawRepresentable`s (i.e. enums)
 * - Coding as a single String value (a struct would otherwise encoded as a map)
 *
 * ### Raw Representable IDs
 *
 * Encourage people to avoid String's and put IDs into enums, like so:
 *
 *     enum ApprovalActionIDs: String {
 *       case approve, deny
 *     }
 *
 *     Button(actionID: .approve)
 *       .actionID(.approve)
 *
 */
public protocol StringID: Hashable, Codable, ExpressibleByStringLiteral {
  
  var id : String { get }
  
  init(_ id: String)
}

public extension StringID { // Literals
  
  init(stringLiteral value: String) { self.init(value) }
}

public extension StringID {

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(try container.decode(String.self))
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(id)
  }
}
public extension StringID {
  init<R>(_ id: R) where R: RawRepresentable, R.RawValue == String {
    self.init(id.rawValue)
  }
}
