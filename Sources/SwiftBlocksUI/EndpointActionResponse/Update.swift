//
//  Update.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.View
import struct SlackBlocksModel.ViewID

extension BlocksEndpointResponse {
  
  enum UpdateMode {
    case push
    case replace
    
    var usesReplaceInMessage : Bool {
      switch self {
        case .push    : return false
        case .replace : return true
      }
    }
  }

  /**
   * Re-render the same root view / message again.
   */
  @usableFromInline func update() {
    // We need a new context here, because the call can be reentrant!
    let newContext = context.makeResponseContext(preserveState: true)
    
    update(self.blocks, mode: .replace, using: newContext)
  }
  
  /**
   * Replace the originating view or message with the given blocks.
   */
  @usableFromInline
  func replace<B: Blocks>(@BlocksBuilder with blocks: () -> B) {
    if sendErrorsInErrorView()      { return } // may still need ACK
    if !context.blockErrors.isEmpty { return endWithSimpleACK() }
    
    // TBD: Maybe we should decide state preservation depending on whether the
    //      callbackID is still the same?
    
    let log    = response.log
    let blocks = CallbackIDTransparentEnvironmentWritingModifier(blocks()) {
                   env in
                   env[keyPath: \.log]    = log
                   env[keyPath: \.client] = ClientEnvironmentKey.defaultValue
                 }
    let newContext = context.makeResponseContext(preserveState: false)
    
    update(blocks, mode: .replace, using: newContext)
  }
  
  /**
   * If the request is coming from a modal, this pushes a new View to the modal.
   * If the source was a message, this will send a new message to the same
   * container.
   */
  @inlinable
  func push<B: Blocks>(@BlocksBuilder _ blocks: () -> B) {
    push(blocks())
  }
  @usableFromInline
  func push<B: Blocks>(_ blocks: B) {
    if sendErrorsInErrorView()      { return } // may still need ACK
    if !context.blockErrors.isEmpty { return endWithSimpleACK() }
    
    let log    = response.log
    let blocks = CallbackIDTransparentEnvironmentWritingModifier(blocks) {
                   env in
                   env[keyPath: \.log]    = log
                   env[keyPath: \.client] = ClientEnvironmentKey.defaultValue
                 }
    let newContext = context.makeResponseContext(preserveState: false)
    
    update(blocks, mode: .push, using: newContext)
  }
  
  
  // MARK: - Implementation
  
  fileprivate func sendResponseAction(_ view: SlackBlocksModel.View,
                                      in mode: UpdateMode)
  {
    response.log.notice("update/push using response action ...")
    guard let view = finishedView(in: context) else {
      return endWithInternalError("failed to finish re-render view: \(self)")
    }
    switch mode {
      case .replace : return response.json(ResponseAction.update(view))
      case .push    : return response.json(ResponseAction.push  (view))
    }
  }
  

  /**
   * Re-render the same root view / message again.
   */
  fileprivate func update<B: Blocks>(_ blocks: B, mode: UpdateMode,
                                     using context: BlocksContext)
  {
    // FIXME: split up this huuuuge method :-)
    
    if sendErrorsInErrorView()      { return } // may still need ACK
    if !context.blockErrors.isEmpty { return endWithSimpleACK() }
    
    // MARK: - Render blocks
    
    do {
      context.prepareForMode(.render)
      try context.render(blocks)
    }
    catch {
      return endWithInternalError(
               "failed to re-render blocks: \(self) \(error)")
    }
    
    
    // MARK: - View update
    
    // a view submission, we can update the view right in the response
    if responseActionEnabled {
      return sendResponseAction(context.finishView(defaultTitle: defaultTitle),
                                in: mode)
    }
        
    switch requestContainer {
      case .view(let viewID, _):
        switch mode {
          
          case .replace:
            return updateViewWithID(viewID, in: context)
          
          case .push:
            switch context.surface {
              case .homeTab         : return publishView(in: context)
              case .modal, .message :
                // Here we could check decide between sending a message and pushing
                // a view. E.g. depending on whether a `View` was constructed in the
                // content.
                // But it is probably not a good idea, inconsistent with other
                // stuff? But we do it below.
                return pushView(in: context)
            }
        }
      
      case .message, .contextMessage:
        // This can be either a message action, OR a block action (from within
        // an interactive message).
        
        switch mode {
          case .replace:
            // replace always needs to replace the message, we have no view-id
            break
          case .push:
            switch context.surface {
              case .message:
                break // send message
              case .homeTab:
                return publishView(in: context)
              case .modal:
                // a trigger ID is required to open a view
                if triggerID == nil { break } // attempt to send as message
                return openView(in: context)
            }
        }
        
      case .none: // request container available
        break
    }
    
    
    // MARK: - Message Send
    
    // we did render already above!
    let apiBlocks : [ Block ]
    if let view = context.view { // TBD: might be OK, could be used in both?
      // not finishing View
      apiBlocks = view.blocks
                + context.blocks.asBlockSuitableForSurface(context.surface)
    }
    else {
      apiBlocks = context.blocks
    }
    
    /**
     * response_url availability (5 posts for 30 minutes)
     * - I think slash commands
     * - I think message actions
     * - channels/conversations picker (`response_url_enabled`)
     */
    var useResponseURLForMessageSend : Bool {
      switch context.surface { // only use responseURL for messages?
        case .message         : return true // return mode == .replace
        case .homeTab, .modal : return false
      }
    }
    if let responseURL = responseURL, useResponseURLForMessageSend {
      return sendMessage(apiBlocks, in: mode, to: responseURL, in: context)
    }

    guard let requestContainer = requestContainer else {
      // We use this for global shortcuts, which have no request container and
      // live outside of everything. That's why they are called global after
      // all ...
      switch mode {
        case .replace:
          switch context.surface {
            case .homeTab         : return publishView(in: context)
            case .modal, .message :
              return endWithInternalError("missing container for update?!")
          }
        
        case .push:
          // We cannot push a message here, because we have no container
          // to post to! Show it as a modal.
          switch context.surface {
            case .homeTab : return publishView(in: context)
            case .modal   : return openView   (in: context)
            case .message :
              // This is OK, using arbitrary Blocks.
              context.surface = .modal
              return openView(in: context)
          }
      }
    }

    switch requestContainer {
      case .view:
        assertionFailure("update View is handled above?!")
        return endWithInternalError("internal inconsistency")
        
      case .message       (let messageID, let conversationID, _),
           .contextMessage(let messageID, let conversationID, _):
        switch mode {
          
          case .replace:
            response.log.notice("update using chat.update ...")
            return client.chat.update(id: messageID, in: conversationID,
                                      blocks: apiBlocks) {
              error, payload in
              self.endWithErrorOrACK(error, "could not update message \(self)")
            }
          
          case .push:
            response.log
              .notice("push to \(conversationID) using chat.postMessage ...")
            postMessage(apiBlocks, to: conversationID, in: context)
        }
    }
  }
}
