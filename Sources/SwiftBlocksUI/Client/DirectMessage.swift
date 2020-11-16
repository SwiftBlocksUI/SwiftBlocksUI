//
//  DirectMessage.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Blocks
import enum SlackBlocksModel.Block

public extension SlackClient.Chat {

  fileprivate struct CouldNotFindConversationID: Swift.Error {} // FIXME

  /**
   * Send the blocks as a direct message to the user.
   *
   * Ephemeral is controlled using the scope!
   */
  func sendMessage<B: Blocks>(_ message: B, to userID: UserID,
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
    
    let client = self.client
    client.conversations.open(userID) { error, payload in
      guard error == nil else { return yield(error) }
      guard let conversation = payload["channel"] as? [ String : Any ],
            let conversationID = (conversation["id"] as? String)
                                 .flatMap(ConversationID.init) else
      {
        return yield(CouldNotFindConversationID())
      }
      
      switch scope {
        case .inConversation, .none:
          return client.chat.postMessage(in: conversationID,
                                         blocks: apiBlocks)
          {
            error, payload in return yield(error)
          }
        
        case .userOnly:
          return client.chat.postEphemeral(in: conversationID, to: userID,
                                           blocks: apiBlocks)
          {
            error, payload in return yield(error)
          }
      }
    }
  }
}
