//
//  SlashRequestParser.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   MacroExpress.BodyParserBody
import struct SlackBlocksModel.SlashRequest
import struct SlackBlocksModel.TeamID
import struct SlackBlocksModel.UserID
import struct SlackBlocksModel.EnterpriseID
import struct SlackBlocksModel.ConversationID
import struct SlackBlocksModel.TriggerID

extension SlashRequest {
  
  @usableFromInline
  init?(_ body: BodyParserBody) {
    guard let url = URL(string: body[string: "response_url"]) else {
      return nil
    }

    let team = Team(id       : TeamID(body[string: "team_id"]),
                    domain   : body[string: "team_domain"])
    let user = User(id       : UserID(body[string: "user_id"]),
                    username : body[string: "user_name"],
                    teamID   : team.id)

    let conversation =
      Conversation(id   : ConversationID(body[string: "channel_id"]),
                   name : body[string: "channel_name"])
    
    let enterprise = (body.enterprise_id as? String).flatMap { eid in
      return Enterprise(id   : EnterpriseID(eid),
                        name : (body.enterprise_name as? String) ?? "")
    }

    self.init(
      verificationToken : body[string: "token"],
      triggerID         : TriggerID(body[string: "trigger_id"]),
      responseURL       : url,
      team              : team, 
      conversation      : conversation, 
      user              : user,
      enterprise        : enterprise,
      command           : body[string: "command"],
      text              : body[string: "text"]
    )
  }
}
