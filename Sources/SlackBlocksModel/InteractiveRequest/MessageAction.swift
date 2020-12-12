//
//  MessageAction.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension InteractiveRequest {

  /**
   * A message shortcut endpoint, those are configured (the name etc) in the
   * Slack admin panel and appear in the message context menu in the client
   * (within the "More Actions" button).
   *
   * This does get the message content and associated meta data upon action.
   *
   * There is also `Shortcut`, which is a global shortcut accessible using the
   * "Lightning" button left of the message input field.
   *
   * Docs: https://api.slack.com/interactivity/shortcuts/using
   */
  struct MessageAction: Codable, CustomStringConvertible {
    
    public let token        : String // Du123456789123456789123o
    public let actionTS     : String // 1593433040.329761
    public let callbackID   : CallbackID // vaca
    public let triggerID    : TriggerID  // 1211234558162.426789018178.176a..e7
    public let responseURL  : URL    // https://hooks.slack.com/app/TC..8/1.5/ziC..
    public let team         : Team
    public let user         : User   // the user who triggered the action, not the msg
    public let conversation : Conversation
    public let message      : Message

    enum CodingKeys: String, CodingKey {
      case token, team, user, message
      case actionTS     = "action_ts"
      case callbackID   = "callback_id"
      case triggerID    = "trigger_id"
      case conversation = "channel"
      case responseURL  = "response_url"
    }
    
    public var description: String {
      var ms = "<MessageAction[\(callbackID.id)]:"
      ms += " @\(user.id.id)(\(user.username)"
      ms += " #\(conversation.id.id)(\(conversation.name)"
      ms += " \(message)"
      if token       .isEmpty { ms += " no-token"      }
      if triggerID.id.isEmpty { ms += " no-trigger-id" }
      ms += ">"
      return ms
    }
  }
  
  struct Conversation: Codable, Identifiable, CustomStringConvertible {
    public let id   : ConversationID
    public let name : String

    public init(id: ConversationID, name: String) {
      self.id   = id
      self.name = name
    }

    public var description: String { return "<#\(id.id) '\(name)'>" }
  }
  
  struct Message: Codable, Identifiable, CustomStringConvertible {
    // TODO: this should _wrap_ SlackBlocksModel.Message
    
    public let id     : MessageID
    public let userID : UserID
    public let teamID : TeamID
    
    public let text   : String
    // TODO: blocks :-)
    // TODO: attachments and more
    // TBD:  can this be ephemeral?

    enum CodingKeys: String, CodingKey {
      case id = "ts", userID = "user", teamID = "team", text
    }

    public var description: String {
      var ms = "<Msg[\(id.id)]: from=@\(userID.id)"
      if text.isEmpty { ms += " no-text" }
      else {
        let s = text.replacingOccurrences(of: "\n", with: "\\n")
        if s.count > 40 {  ms += " '\(s.prefix(40))'.."  }
        else            { ms += " '\(s)'" }
      }
      ms += ">"
      return ms
    }
  }
}

public extension InteractiveRequest.MessageAction {

  @inlinable
  var container : InteractiveRequest.Container? {
    return .contextMessage(messageID      : message.id,
                           conversationID : conversation.id,
                           isEphemeral    : false) // TBD: do we have the info?
  }
}
