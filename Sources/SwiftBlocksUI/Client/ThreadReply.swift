//
//  ThreadReply.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Blocks
import enum SlackBlocksModel.Block

public extension SlackClient.Chat {

  /**
   * Send the blocks as a reply message to a thread.
   */
  func replyMessage<B: Blocks>(_ message: B, to messageID: MessageID,
                               in conversationID: ConversationID,
                               yield: @escaping ( Swift.Error? ) -> Void)
  {
    let scope     : MessageResponse.ResponseType?
    let apiBlocks : [ Block ]
    do {
      ( scope, apiBlocks ) =
        try renderMessage(message,
                          supportsRichText: client.token.supportsRichText)
    }
    catch {
      return yield(error)
    }
    
    if scope == .userOnly {
      console.error("Ephemeral not supported in threads!")
      assertionFailure("Using ephemeral message as a reply!")
    }

    client.chat.replyToMessage(messageID, in: conversationID,
                               blocks: apiBlocks)
    {
      error, payload in
      
      yield(error)
    }
  }
}
