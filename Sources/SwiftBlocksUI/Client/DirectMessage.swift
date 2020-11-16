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
    let apiBlocks : [ Block ]
    
    // TODO: Provide a proper environment?! Maybe even copy stuff from the
    //       BlocksEndpointResponse?
    let context = BlocksContext()
    do {
      context.surface = .message

      try context.render(message)

      let hasRichText = client.token.supportsRichText // TBD
      
      let blocks : [ Block ]
      if let view = context.view {
        context.log.warning("a view was passed chat.sendMessage \(view)")
        blocks = view.blocks + context.blocks
      }
      else {
        blocks = context.blocks
      }
      
      apiBlocks = hasRichText ? blocks : blocks.replacingRichText()
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
      
      switch context.messageResponseScope {
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
