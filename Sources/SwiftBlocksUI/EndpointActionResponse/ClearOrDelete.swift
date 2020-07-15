//
//  ClearOrDelete.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension BlocksEndpointResponse {

  /**
   * This closes the whole modal or _deletes_ the originating message.
   *
   * Note that modals can only be closed in response to a view submit (there
   * is no views.close/clear API method).
   */
  @usableFromInline func clear() {
    if responseActionEnabled {
      response.log.notice("clear using response action ...")
      return response.json(ResponseAction.clear)
    }

    switch requestContainer {
      case .some(.view):
        // https://api.slack.com/surfaces/modals/using#closing_views
        // views can only be closed using the responseAction.
        return endWithInternalError("cannot close views w/o response action!")
      case .message, .contextMessage, .none:
        break
    }
    
    if let responseURL = responseURL { // only for messages
      response.log.notice("clear using responseURL ...")
      return client.post([ "delete_original": true ], to: responseURL) {
        error, payload in
        self.endWithErrorOrACK(error, "could not delete orig message \(self)")
      }
    }
    
    guard let requestContainer = requestContainer else {
      return endWithInternalError("missing request container for delete?!")
    }
    
    switch requestContainer {
      case .view:
        return endWithInternalError("cannot close views w/o response action!")
        
      case .message(let messageID, let conversationID, _),
           .contextMessage(let messageID, let conversationID, _):
        response.log.notice("clear using chat.delete ...")
        return client.chat.delete(messageID, in: conversationID) { error, res in
          self.endWithErrorOrACK(error, "could not delete message \(self)")
        }
    }
  }
}
