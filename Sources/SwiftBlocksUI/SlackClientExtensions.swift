//
//  SlackClientExtensions.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackClient.SlackClient
import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.View
import enum   SlackBlocksModel.InteractiveRequest

public extension SlackClient.Views {

  fileprivate struct CouldNotProcessView: Swift.Error {} // FIXME

  // TODO: make it a BlocksBuilder, but figure out how to do the yield.
  // TODO: replace arguments w/ ViewState in Context
  // All this probably belongs into the specific endpoint?
  
  func open<V>(_ view: V, with triggerID: SlackBlocksModel.TriggerID,
               yield: @escaping (SlackClient.APIError?, [String : Any]) -> Void)
       where V: Blocks
  {
    var apiView : SlackBlocksModel.View
    
    do {
      let context = BlocksContext()
      context.surface = .modal
      
      try context.render(view)

      if context.view == nil {
        context.log.warning("no explicit view passed to views.open \(view)")
      }
      context.finishView(defaultTitle: "\(type(of: view))")

      guard let ctxView = context.view else {
        assertionFailure("missing view even after finish ... \(context)")
        return yield(SlackClient.APIError.noValidJSONResponseContent(nil), [:])
      }
      apiView = ctxView
    }
    catch {
      //log.error("Failed to render blocks: \(blocks)\n  error: \(error)")
      //return sendStatus(500)
      assertionFailure("error: \(error)")
      return yield(SlackClient.APIError.noValidJSONResponseContent(nil), [:])
    }
    
    self.open(apiView, with: triggerID, yield: yield)
  }
}

import Blocks

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
    
    let context = BlocksContext()
    do {
      context.surface = .message

      // TODO: provide a proper environment?!
      try context.render(message)
      
      if let view = context.view {
        context.log.warning("a view was passed chat.sendMessage \(view)")
        apiBlocks = view.blocks + context.blocks
      }
      else {
        apiBlocks = context.blocks
      }
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
