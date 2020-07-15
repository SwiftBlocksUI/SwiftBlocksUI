//
//  ShortcutRequest.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension InteractiveRequest {

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
