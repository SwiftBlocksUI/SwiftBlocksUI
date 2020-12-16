//
//  Event.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.TimeInterval

/**
 * Represents an Event coming in using the HTTP callback based Slack
 * "Events API".
 *
 * The events API sometimes wrappes the event itself (callback_event),
 * but not always.
 * This either exposes the outer or inner payload (and sets isCallback).
 */
public final class SlackEvent {
  // TODO: This might need a little more work, nicer names, etc.
  // It carries the actual payload as an untyped dictionary.
  
  public struct Authorization {
    
    public let teamID : TeamID
    public let userID : UserID
    public let isBot  : Bool
    
    public let enterpriseID        : EnterpriseID?
    public let isEnterpriseInstall : Bool

    init?(json: [ String : Any ]) {
      guard let tid = json["team_id"] as? String, !tid.isEmpty,
            let uid = json["user_id"] as? String, !uid.isEmpty else {
        assertionFailure("missing data in auth")
        return nil
      }
      teamID = TeamID(tid)
      userID = UserID(uid)
      isBot  = (json["is_bot"] as? Bool) ?? false
      
      enterpriseID =
        (json["enterprise_id"] as? String).flatMap(EnterpriseID.init)
      isEnterpriseInstall  = (json["is_enterprise_install"] as? Bool) ?? false
    }
  }

  public let type           : EventType
  public let token          : SlackBlocksModel.Token

  public let applicationID  : ApplicationID
  public let teamID         : TeamID
  public let isExtSharedConversation : Bool
  public let authorizations : [ Authorization ]

  public let eventContext   : String // 1-message-T1234S41234-G1234CA1234
  public let eventID        : String // Ev01EZTW690U
  public let eventDate      : Date
  
  public let isCallback     : Bool
  public let payload        : [ String : Any ]
  
  // - api_app_id
  // - authorizations (array of dicts, w/ team_id, user_id)
  // - event (type, channel, etc)
  // - event_id/time
  
  public init?(json: [ String : Any ]) {
    guard let appID = json["api_app_id"] as? String, !appID.isEmpty else {
      assertionFailure("missing app-id in event")
      return nil
    }
    guard let teamID = json["team_id"] as? String, !teamID.isEmpty else {
      assertionFailure("missing team_id in event")
      return nil
    }
    guard let requestType = json["type"] as? String, !requestType.isEmpty else {
      assertionFailure("missing type in event")
      return nil
    }
    guard let token = json["token"] as? String, !token.isEmpty else {
      assertionFailure("missing token in event")
      return nil
    }
    
    self.token = Token(token)

    // Yes, this is a little weird
    if requestType == "event_callback" {
      guard let payload = json["event"] as? [ String : Any ] else {
        assertionFailure("event_callback has no event structure")
        return nil
      }
      guard let eventType = payload["type"] as? String, !eventType.isEmpty else
      {
        assertionFailure("missing type in callback-event")
        return nil
      }
      guard let type = EventType(rawValue: eventType) else {
        assertionFailure("unexpected type in callback-event \(eventType)")
        return nil
      }
      
      self.type       = type
      self.isCallback = true
      self.payload    = payload
    }
    else {
      guard let type = EventType(rawValue: requestType) else {
        assertionFailure("unexpected request type in event")
        return nil
      }
      self.type       = type
      self.isCallback = false
      self.payload    = json
    }
    
    self.applicationID = ApplicationID(appID)
    self.teamID        = TeamID(teamID)
    
    self.authorizations =
      (json["authorizations"] as? [ [ String : Any ] ])?
      .compactMap(Authorization.init) ?? []
    
    self.eventContext = (json["event_context"] as? String) ?? ""
    self.eventID      = (json["event_id"]      as? String) ?? ""
    self.eventDate    = (json["event_time"]    as? Int).flatMap {
      Date(timeIntervalSince1970: TimeInterval($0))
    } ?? Date()
    
    self.isExtSharedConversation =
      (json["is_ext_shared_channel"] as? Bool) ?? false
  }
  
  /* Sample Nested payload:
     "blocks":[{"block_id":"XunAt","elements":[{"elements":[{"text":"blub","type":"text"}],"type":"rich_text_section"}],"type":"rich_text"}],
     "channel":"G12345678M7","channel_type":"group",
     "client_msg_id":"12345678-1234-5678-bf7e-8d8508a9d256",
     "event_ts":"1605524681.002600",
     "team":"T123456782F",
     "text":"blub",
     "ts":"1605524681.002600",
     "type":"message","user":"U12345678DY"
   */
}

public extension SlackEvent {
  
  /**
   * Attempt to extract the user-id from the event authorizations or payload.
   */
  var userID: UserID? { // TBD
    for key in [ "user", "sender", "user_id" ] {
      if let userID = (payload[key] as? String).flatMap(UserID.init) {
        return userID
      }
    }
    if let userID = authorizations.first?.userID { return userID }
    return nil
  }
  
  /**
   * Attempt to extract the conversation-id from the eventpayload.
   */
  var conversationID: ConversationID? { // TBD
    if let c = payload["conversation"] {
      if let s = (c as? String).flatMap(ConversationID.init) { return s }
      else if let d = (c as? [ String: Any ]),
              let s = (d["conversation_id"] as? String
                    ?? d["channel_id"] as? String)
      {
        return ConversationID(s)
      }
    }
    if let c = payload["channel"] {
      if let s = (c as? String).flatMap(ConversationID.init) { return s }
      else if let d = (c as? [ String: Any ]),
              let s = d["channel_id"] as? String
      {
        return ConversationID(s)
      }
    }
    return nil
  }
}


// MARK: - Types

public extension SlackEvent {
  
  enum EventType : String {
    // TODO: maybe use nicer names
    
    case app_rate_limited
    case app_uninstalled
    case grid_migration_finished
    case grid_migration_started
    case resources_added
    case resources_removed
    case scope_denied
    case scope_granted
    
    case subteam_created
    case subteam_members_changed
    case subteam_self_added
    case subteam_self_removed
    case subteam_updated
    
    case team_domain_change
    case team_join
    case team_rename
    case tokens_revoked
    case url_verification
    case user_change
    case user_resource_denied
    case user_resource_granted
    case user_resource_removed
    
    case app_mention
    case app_home_opened
    case message_app_home = "message.app_home"

    case dnd_updated
    case dnd_updated_user
    case email_domain_changed
    case emoji_changed
    
    case file_change
    case file_comment_added
    case file_comment_deleted
    case file_comment_edited
    case file_created
    case file_deleted
    case file_public
    case file_shared
    case file_unshared

    case link_shared

    case channel_archive
    case channel_created
    case channel_deleted
    case channel_history_changed
    case channel_left
    case channel_rename
    case channel_unarchive
    
    case group_archive
    case group_close
    case group_deleted
    case group_history_changed
    case group_left
    case group_open
    case group_rename
    case group_unarchive
    
    case im_close
    case im_created
    case im_history_changed
    case im_open
    
    case member_joined_channel
    case member_left_channel

    case message
    case message_channels = "message.channels"
    case message_groups   = "message.groups"
    case message_im       = "message.im"
    case message_mpim     = "message.mpim"
    
    case pin_added
    case pin_removed
    case reaction_added
    case reaction_removed
    case star_added
    case star_removed
  }
}


// MARK: - Description

extension SlackEvent.Authorization: CustomStringConvertible {
  
  public var description: String {
    var ms = "<EventAuth:"; defer { ms += ">" }
    ms += " team=\(teamID.id)"
    ms += " @\(userID.id)"
    if isBot { ms += "(bot)" }
    if isEnterpriseInstall    { ms += " enteprise" }
    if let eid = enterpriseID { ms += "(\(eid.id))" }
    return ms
  }
}

extension SlackEvent: CustomStringConvertible {

  public var description: String {
    var ms = "<EventAuth:"; defer { ms += ">" }
    
    ms += " \(type.rawValue) app=\(applicationID.id) team=\(teamID.id)"
    ms += " ctx=\(eventContext) id=\(eventID)"
    // date
    
    ms += " token=\(token.value)"
    if authorizations.isEmpty {
      ms += " NO-AUTH"
    }
    else if authorizations.count == 1, let auth = authorizations.first {
      ms += " \(auth)"
    }
    else {
      ms += " auths=#\(authorizations.count)"
    }
    
    if isCallback { ms += " CALLBACK" }
    
    if payload.isEmpty { ms += " NO-PAYLOAD" }
    else               { ms += " \(payload)" }

    return ms
  }
}
