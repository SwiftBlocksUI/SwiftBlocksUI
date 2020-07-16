//
//  Conversations.swift
//  SlackClient
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.MessageID
import struct SlackBlocksModel.ConversationID
import struct SlackBlocksModel.UserID
import enum   SlackBlocksModel.Block

public extension SlackClient {

  var conversations : Conversations { Conversations(client: self) }
  
  struct Conversations {
    
    public let client : SlackClient
    
    /// https://api.slack.com/methods/conversations.open
    public func open(_ users : UserID...,
                       yield : @escaping ResponseHandler)
    {
      struct Call: Encodable {
        let users : [ UserID ]
      }
      let call = Call(users: users)
      client.post(call, to: "conversations.open", yield: yield)
    }
  }
}
