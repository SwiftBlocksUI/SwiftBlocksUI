//
//  ResponseAction.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.View

/**
 * Stuff which can be returned in a view submission response action.
 *
 * Docs: https://api.slack.com/surfaces/modals/using#closing_views
 */
internal struct ResponseAction: Encodable {
  
  enum Action: String, Codable {
    /// update view which did the submit
    case update
    /// push new view on top of the submitting view
    case push
    /// close whole modal (instead of just the view, which is a no-content 200)
    case clear
    /// show errors attached to Input blocks (keyed by BlockID)
    case errors
  }
  
  private let action : Action
  private let view   : View?
  private let errors : [ Block.BlockID : String ]?
  
  // MARK: - Constructors
  
  static func errors(_ errors: [ Block.BlockID : String ]) -> ResponseAction {
    ResponseAction(action: .errors, view: nil, errors: errors)
  }
  static func push(_ view: View) -> ResponseAction {
    ResponseAction(action: .push, view: view, errors: nil)
  }
  static func update(_ view: View) -> ResponseAction {
    ResponseAction(action: .update, view: view, errors: nil)
  }
  static func clear() -> ResponseAction {
    ResponseAction(action: .clear, view: nil, errors: nil)
  }
  
  // MARK: - Coding
  
  enum CodingKeys: String, CodingKey {
    case view, errors
    case action = "response_action"
  }

  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(action, forKey: .action)
    if let view = view {
      try container.encode(view, forKey: .view)
    }
    if let errors = errors, !errors.isEmpty {
      // not sure why this has to be done, Codable, uggh.
      var dict = [ String : String ]()
      for ( blockID, message ) in errors {
        dict[blockID.id] = message
      }
      try container.encode(dict, forKey: .errors)
    }
  }
}
