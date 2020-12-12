//
//  InteractiveRequest.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import struct Foundation.URL
import class  Foundation.JSONDecoder

/**
 * The set of requests that can arrive at the "interactive endpoint" URL.
 *
 * On the wire it is JSON encoded in a "payload" form field.
 */
public enum InteractiveRequest: Decodable, CustomStringConvertible {
  
  /**
   * A _global_ shortcut endpoint, those are configured (the name etc) in the
   * Slack admin panel and appear in the global shortcuts menu in the client
   * (the "lightning" button left of the message field).
   *
   * It is similar to a slash command, but can't have arguments,
   * and DOES NOT have access to the active conversation.
   *
   * There is also `.messageAction`, which is a shortcut being used in a message
   * context (i.e. appears in the context menu for a message).
   *
   * Global shortcuts have little context and need to resort to API calls to
   * create messages or modals (the latter is recommended).
   *
   * Docs: https://api.slack.com/interactivity/shortcuts/using
   */
  case shortcut      (Shortcut)
  
  /**
   * A message shortcut endpoint, those are configured (the name etc) in the
   * Slack admin panel and appear in the message context menu in the client
   * (within the "More Actions" button).
   *
   * This does get the message content and associated meta data upon action.
   *
   * There is also `.shortcut`, which is a global shortcut accessible using the
   * "Lightning" button left of the message input field.
   *
   * Docs: https://api.slack.com/interactivity/shortcuts/using
   */
  case messageAction (MessageAction)

  /**
   * Block actions are sent when form elements change their values, e.g. if
   * a button is pressed or a date is selected in a date picker.
   *
   * Note that components contained in `input` blocks of a View do NOT trigger
   * block actions.
   *
   * Block actions can happen in Views (modal forms) or directly within
   * messages.
   * Note that there can be multiple actions (all with their own ID) within
   * a single `blockActions` interactive request.
   *
   * Docs: https://api.slack.com/reference/interaction-payloads/block-actions
   */
  case blockActions  (BlockActions)
  
  /**
   * A ViewSubmission is triggered when the user submits a View in Slack.
   *
   * A lot of information is provided as part of the `ViewInfo` property,
   * including the state of all interactive view (form) elements!
   *
   * There are also `BlockActions`, but those are only triggered for interactive
   * components which are outside of `input` blocks (e.g. in section accessories
   * or an actions block).
   */
  case viewSubmission(ViewSubmission)
  
  /**
   * An event which gets sent when a view (a modal panel) gets closed.
   */
  case viewClosed    (ViewClosed)

  enum DecodingError : Swift.Error {
    case unsupportedPayloadType(String)
    case unsupportedViewStateValue
    case unexpectedValue(Any)
    case missingID
  }
  
  public var description: String {
    switch self {
      case .shortcut      (let v): return v.description
      case .messageAction (let v): return v.description
      case .blockActions  (let v): return v.description
      case .viewSubmission(let v): return v.description
      case .viewClosed    (let v): return v.description
    }
  }
  
  // MARK: - Coding
  
  enum CodingKeys: String, CodingKey { case type }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type      = try container.decode(String.self, forKey: .type)
    
    switch type {
      case "shortcut":
        self = .shortcut      (try Shortcut(from: decoder))
      case "message_action":
        self = .messageAction (try MessageAction(from: decoder))
      case "block_actions":
        self = .blockActions  (try BlockActions(from: decoder))
      case "view_submission":
        self = .viewSubmission(try ViewSubmission(from: decoder))
      case "view_closed":
        self = .viewClosed    (try ViewClosed(from: decoder))
      default:
        throw DecodingError.unsupportedPayloadType(type)
    }
  }
}

public extension InteractiveRequest { // emulating OO 🙄

  @inlinable
  var userID : UserID {
    switch self {
      case .shortcut      (let v) : return v.user.id
      case .messageAction (let v) : return v.user.id
      case .viewSubmission(let v) : return v.user.id
      case .viewClosed    (let v) : return v.user.id
      case .blockActions  (let v) : return v.user.id
    }
  }
  
  @inlinable
  var teamID : TeamID {
    switch self {
      case .shortcut      (let v) : return v.team.id
      case .messageAction (let v) : return v.team.id
      case .viewSubmission(let v) : return v.team.id
      case .viewClosed    (let v) : return v.team.id
      case .blockActions  (let v) : return v.team.id
    }
  }
  
  /**
   * Returns the callback ID of an Interactive Message, if the type supports
   * one.
   *
   * Only shortcuts (global shortcuts or message actions) get assigned
   * callback IDs in the Slack admin interface.
   * Do not confuse those with action IDs (e.g. button action IDs) or block IDs.
   */
  @inlinable
  var callbackID : CallbackID? {
    switch self {
      case .shortcut      (let v)       : return v.callbackID
      case .messageAction (let v)       : return v.callbackID
      case .viewSubmission, .viewClosed, .blockActions:
        return nil // not submitted
    }
  }
  
  @inlinable
  var triggerID : TriggerID? {
    switch self {
      case .shortcut      (let v) : return v.triggerID
      case .messageAction (let v) : return v.triggerID
      case .viewSubmission(let v) : return v.triggerID
      case .viewClosed            : return nil
      case .blockActions  (let v) : return v.triggerID
    }
  }
  
  /**
   * Response URLs can be used to reply to certain interactive requests
   * w/o having a related access token.
   *
   * TODO: more details :-) I think it is only used for messages.
   */
  @inlinable
  var responseURL : URL? {
    switch self {
      case .shortcut              : return nil
      case .messageAction (let v) : return v.responseURL
      case .viewSubmission(let v) : return v.responseURLs.first // TBD
      case .viewClosed            : return nil
      case .blockActions  (let v) : return v.responseURL
    }
  }
  
  @inlinable
  var viewInfo : InteractiveRequest.ViewInfo? {
    switch self {
      case .shortcut, .messageAction     : return nil
      case .viewSubmission(let v)        : return v.view
      case .viewClosed    (let v)        : return v.view
      case .blockActions  (let v):
        switch v.container {
          case .view(_, .some(let info)) : return info
          case .view(_, .none)           : return nil
          case .message, .contextMessage : return nil
        }
    }
  }
  
  typealias Container = BlockActions.Container
  
  @inlinable
  var container : Container? {
    switch self {
      case .messageAction (let v) : return v.container
      case .viewSubmission(let v) : return v.container
      case .viewClosed    (let v) : return v.container
      case .blockActions  (let v) : return v.container
      case .shortcut              : return nil
    }
  }
}
  
public extension InteractiveRequest {
  
  struct User: Codable, Identifiable, CustomStringConvertible {
    
    public let id       : UserID
    public let username : String
    public let teamID   : TeamID
    
    @inlinable
    public init(id: UserID, username: String, teamID: TeamID) {
      self.id       = id
      self.username = username
      self.teamID   = teamID
    }
    
    enum CodingKeys: String, CodingKey {
      case id, username, teamID = "team_id"
    }
    
    public var description: String { return "<@\(id.id) '\(username)'>" }
  }
  
  struct Team: Codable, Identifiable, CustomStringConvertible {
    
    public let id     : TeamID
    public let domain : String
    
    @inlinable
    public init(id: TeamID, domain: String) {
      self.id     = id
      self.domain = domain
    }

    public var description: String { return "<\(id.id) \(domain)>" }
  }
  
  struct Enterprise: Codable, Identifiable, CustomStringConvertible {
    
    public let id   : EnterpriseID
    public let name : String

    @inlinable
    public init(id: EnterpriseID, name: String) {
      self.id   = id
      self.name = name
    }

    public var description: String { return "<\(id.id) '\(name)'>" }
  }
}

public extension InteractiveRequest {
  
  static func from(json: String) throws -> InteractiveRequest {
    guard let data = json.data(using: .utf8) else {
      struct CouldNotConvertToUTF8Data: Swift.Error {}
      throw CouldNotConvertToUTF8Data()
    }
    return try from(json: data)
  }
  
  static func from(json: Data) throws -> InteractiveRequest {
    do {
      return try JSONDecoder().decode(InteractiveRequest.self, from: json)
    }
    catch {
      throw error
    }
  }
}
