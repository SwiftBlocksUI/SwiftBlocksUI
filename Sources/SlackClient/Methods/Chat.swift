//
//  Chat.swift
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

  var chat : Chat { Chat(client: self) }
  
  struct Chat {
    
    public let client : SlackClient
    
    /// https://api.slack.com/methods/chat.delete
    public func delete(_ id: MessageID, in conversation: ConversationID,
                       yield : @escaping ResponseHandler)
    {
      struct Call: Encodable {
        let channel : ConversationID
        let ts      : MessageID
        //let as_user : Bool
      }
      let call = Call(channel: conversation, ts: id)
      client.post(call, to: "chat.delete", yield: yield)
    }
    
    /// https://api.slack.com/methods/chat.update
    public func update(id     : MessageID, in conversation: ConversationID,
                       blocks : [ Block ],
                       yield  : @escaping ResponseHandler)
    {
      struct Call: Encodable {
        let channel : ConversationID
        let ts      : MessageID
        let blocks  : [ Block ]
        //as_user,attachments,link_names,parse,text
      }
      // TODO: Also render blocks as markdown. Quite possible!
      let call = Call(channel: conversation, ts: id, blocks: blocks)
      client.post(call, to: "chat.update", yield: yield)
    }
    
    /// https://api.slack.com/methods/chat.postMessage
    public func postMessage(in conversation: ConversationID,
                            blocks : [ Block ],
                            yield  : @escaping ResponseHandler)
    {
      struct Call: Encodable {
        let channel : ConversationID
        let blocks  : [ Block ]
        let text    : String
        // lots more
      }
      let call = Call(channel: conversation, blocks: blocks,
                      text: blocks.blocksMarkdownString)
      client.post(call, to: "chat.postMessage", yield: yield)
    }
    
    /// https://api.slack.com/methods/chat.postEphemeral
    public func postEphemeral(in conversation : ConversationID,
                              to         user : UserID,
                              blocks          : [ Block ],
                              yield           : @escaping ResponseHandler)
    {
      struct Call: Encodable {
        let channel : ConversationID
        let user    : UserID
        let blocks  : [ Block ]
        let text    : String
      }
      // TODO: Also render blocks as markdown. Quite possible!
      let call = Call(channel: conversation, user: user, blocks: blocks,
                      text: blocks.blocksMarkdownString)
      client.post(call, to: "chat.postEphemeral", yield: yield)
    }
  }
}
