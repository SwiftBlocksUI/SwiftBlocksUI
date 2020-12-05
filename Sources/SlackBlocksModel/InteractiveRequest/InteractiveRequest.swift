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
  
  case shortcut      (Shortcut)
  case messageAction (MessageAction)
  case blockActions  (BlockActions)
  case viewSubmission(ViewSubmission)
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
