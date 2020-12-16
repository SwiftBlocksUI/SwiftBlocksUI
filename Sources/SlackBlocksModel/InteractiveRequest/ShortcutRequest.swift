//
//  ShortcutRequest.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension InteractiveRequest {

  /**
   * A _global_ shortcut endpoint, those are configured (the name etc) in the
   * Slack admin panel and appear in the global shortcuts menu in the client
   * (the "lightning" button left of the message field).
   *
   * It is similar to a slash command, but can't have arguments,
   * and DOES NOT have access to the active conversation.
   *
   * There is also `MessageAction`, which is a shortcut being used in a message
   * context (i.e. appears in the context menu for a message).
   *
   * Global shortcuts have little context and need to resort to API calls to
   * create messages or modals (the latter is recommended).
   *
   * Docs: https://api.slack.com/interactivity/shortcuts/using
   */
  struct Shortcut: Codable, CustomStringConvertible {
    
    public let token      : String     // Du123456789123456789123o
    public let actionTS   : String     // 1593433040.329761
    public let callbackID : CallbackID // vaca (name of shortcut)
    public let triggerID  : TriggerID  // 1211234558162.426789018178.176a..e7
    public let team       : Team
    public let user       : User
    
    enum CodingKeys: String, CodingKey {
      case token, team, user
      case actionTS   = "action_ts"
      case callbackID = "callback_id"
      case triggerID  = "trigger_id"
    }
    
    public var description: String {
      var ms = "<Shortcut[\(callbackID.id)]:"
      ms += " @\(user.id.id)(\(user.username)"
      if token       .isEmpty { ms += " no-token"      }
      if triggerID.id.isEmpty { ms += " no-trigger-id" }
      ms += ">"
      return ms
    }
  }
}
