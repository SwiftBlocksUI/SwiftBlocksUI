//
//  BlocksEndpointResponse.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct   Foundation.Data
import struct   Foundation.URL
import class    Foundation.JSONEncoder
import struct   Foundation.CharacterSet
import struct   SlackBlocksModel.ViewID
import struct   SlackBlocksModel.View
import enum     SlackBlocksModel.Block
import enum     SlackBlocksModel.InteractiveRequest
import protocol Blocks.Blocks
import class    Blocks.BlocksContext
import protocol Blocks.ActionResponse
import class    MacroExpress.ServerResponse
import struct   SlackClient.SlackClient

// This is in SwiftBlocksUI because otherwise BlocksExpress would need a
// dependency on SlackClient.

/**
 * An `ActionResponse` object. This is passed to Blocks actions, to choose
 * how the action wants to finish the current interaction.
 *
 * See `Action` and `ActionResponse` for more details.
 */
public final class BlocksEndpointResponse<B: Blocks>: ActionResponse {
  // TODO: This could have a timer to auto-end the action if it doesn't complete
  //       in 3 seconds (because the client will show an error).
  //       We could also send the ACK, then set `responseActionEnabled` to false
  //       to trigger a regular, client triggered, async update?!
  // TBD:  Early ACK or late ACK?
  // This intentionally doesn't get the `InteractiveRequest`, constrained to the
  // stuff it actually needs.
  
  let context               = BlocksContext()
  let response              : ServerResponse
  let client                : SlackClient
  let blocks                : B
  
  // request data
  let requestContainer      : InteractiveRequest.Container?
  let triggerID             : TriggerID?
  let responseURL           : URL?
  let userID                : UserID
  var responseActionEnabled = false
  
  @usableFromInline
  var matchingActions = 0

  /// This is enabled for `viewSubmission` requests, which allow for error
  /// results and such.
  @usableFromInline
  func enableResponseAction() {
    responseActionEnabled = true
  }

  public init(requestContainer : InteractiveRequest.Container?,
              responseURL      : URL?,
              triggerID        : TriggerID?,
              userID           : UserID,
              accessToken      : Token,
              response         : ServerResponse,
              blocks           : B)
  {
    self.response         = response
    self.blocks           = blocks
    self.requestContainer = requestContainer
    self.responseURL      = responseURL
    self.triggerID        = triggerID
    self.userID           = userID
    self.client           = SlackClient(token: accessToken)
    
    // TBD: if there is a viewID, should we switch the surface to modal,
    //      if the message is set?

    switch requestContainer {
      case .none           : break
      case .message        : break // how unfortunate!
      case .contextMessage : break
      case .view(_, .none) : break
      case .view(_, view: .some(let viewInfo)):
        do {
          let values =
            try MetaDataValues(metaDataString: viewInfo.privateMetaData)
          context.pushMetaData(values)
        }
        catch {
          response.log.error(
            "could not parse meta data \(viewInfo.privateMetaData) \(error)")
        }
    }
  }
  
  
  // MARK: - Response Fallback
  
  @usableFromInline
  func endWithNoActionTriggered() {
    if !response.writableEnded {
      if !context.blockErrors.isEmpty {
        if sendErrorsInErrorView()      { return }
        if !context.blockErrors.isEmpty { return endWithSimpleACK() }
      }
      else {
        end()
      }
    }
  }
  
  
  // MARK: - Errors
  
  /// returns true if it finished the current response,
  /// even if we sent errors, the caller might still need to ACK!
  internal func sendErrorsInErrorView() -> Bool {
    guard !context.blockErrors.isEmpty else { return false }
    if responseActionEnabled { return sendValidationErrors() }
    
    // TODO:
    // - If we are in a View context, push a new "error" View.
    // - If we are in a message context, and we have a trigger, push new
    //   "error" View
    // - otherwise fail via `sendValidationErrors`
    return sendValidationErrors()
  }
  
  /// returns true if it sent errors
  internal func sendValidationErrors() -> Bool {
    guard !context.blockErrors.isEmpty else { return false }
    
    // Note: we send the JSON regardless and just switch the response status.
    if !responseActionEnabled {
      response.status(422) // Unprocessable Entity
    }
    
    let result = ResponseAction.errors(context.blockErrors)
    
    #if DEBUG && false
      do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data : Data? = try? encoder.encode(result)
        if let s = data.flatMap({ String(data: $0, encoding: .utf8) }) {
          print("SENDING:\n\(s)")
        }
      }
    #endif
    
    // https://api.slack.com/surfaces/modals/using#displaying_errors
    self.response.json(result)
    return true
  }
  
  
  // MARK: - Phases
  
  @usableFromInline
  func takeValues(from state: BlocksContext.FormState) throws {
    do {
      context.prepareForMode(.takeValues(state))
      try context.render(blocks)
    }
    catch {
      response.log.error("failed to apply state values on: \(blocks)")
      throw error
    }
  }
  
  @usableFromInline
  func invoke(_ invocation: BlocksContext.Mode.Invocation) throws {
    do {
      context.prepareForMode(.invoke(invocation))
      
      do {
        try context.render(blocks)
      }
      catch let error as InputValidationError {
        for ( idStyle, message ) in error.invalidInputs {
          context.addError(message, in: idStyle)
        }
        print("ADDED:", context.blockErrors)
        if case .invoke(let invocation) = context.mode {
          switch invocation { // TODO: move to ctx.markActionAsProcessed ...
            case .submit   (.none), .viewClose(.none), .actions(_, .none): break
            case .submit   (.some) : context.mode = .invoke(.submit(nil))
            case .viewClose(.some) : context.mode = .invoke(.viewClose(nil))
            case .actions(let x, .some):
              context.mode = .invoke(.actions(x, nil))
          }
          endWithNoActionTriggered()
        }
      }
      catch {
        throw error
      }

      let didMatch : Bool = {
        guard case .invoke(let invocation) = context.mode else {
          assertionFailure("mode switch during invocation?! \(context)")
          return false
        }
        switch invocation {
          case .submit(.some), .viewClose(.some), .actions(_, .some):
            return false
          case .submit(.none), .viewClose(.none), .actions(_, .none):
            return true
        }
      }()
      
      if !didMatch {// this is valid! we just return the default
        response.log.notice("no action matched \(self)")
      }
      else {
        matchingActions += 1
      }
    }
    catch {
      response.log.error("failed to invoke action: \(self) \(error)")
      throw error
    }
  }
  
  // MARK: - Responses
  
  internal func endWithSimpleACK() {
    response.status(200).end()
  }
  internal func endWithInternalError(_ info  : String       = "",
                                     _ error : Swift.Error? = nil)
  {
    if !info.isEmpty {
      if let error = error {
        response.log.error("request processing failed: \(info) \(error)")
      }
      else {
        response.log.error("request processing failed: \(info)")
      }
    }
    response.status(500).end()
  }
  internal func endWithNotImplemented(_ feature: String = "") {
    response.log.error("sorry, \(feature) not yet implemented!")
    response.status(501).end()
  }
  
  internal func finishedView(in context: BlocksContext) -> View? {
    if let view = context.view { return view }
    if context.blocks.isEmpty { return nil }
    return context.finishView(defaultTitle: defaultTitle)
  }
  
  /// If the error is set, `endWithInternalError`, else 200 OK.
  internal func endWithErrorOrACK(_ error : Swift.Error?,
                                  _ info  : @autoclosure ( ) -> String)
  {
    if let error = error {
      return self.endWithInternalError(info(), error)
    }
    self.response.sendStatus(200)
  }

  var defaultTitle : String {
    // Hm, well ... User needs to use a proper `View` to set the title.
    var typeName = "\(type(of: blocks))"
    if let idx = typeName.lastIndex(of: "<") {
      let close = CharacterSet(charactersIn: ">\n")
      typeName = String(typeName[typeName.index(after: idx)...])
                   .trimmingCharacters(in: close)
    }
    guard typeName.count < 25 else { return String(typeName.prefix(24)) }
    return typeName
  }
}

extension BlocksEndpointResponse { // API operations
  
  /**
   * Post or update a message at the given URL (usually the `responseURL`).
   *
   * Inspects the context's `messageResponseScope` (user or conversation)
   */
  func sendMessage(_ blocks : [ Block ],
                   in  mode : UpdateMode,
                   to   url : URL, in context: BlocksContext)
  {
    response.log.notice("update using response URL ...")
    let hasRichText = client.token.supportsRichText // TBD
    let messageResponse = MessageResponse(
      responseType    : context.messageResponseScope,
      replaceOriginal : mode   .usesReplaceInMessage,
      blocks          : hasRichText ? blocks : blocks.replacingRichText()
    )
    return client.post(messageResponse, to: url) { error, payload in
      self.endWithErrorOrACK(error,
        "failed to update/push message via url: \(self) \(payload)")
    }
  }

  
  /**
   * Update using the View in the context using the client's `views.update`.
   *
   * Does NOT require a trigger, but a valid ViewID.
   */
  func updateViewWithID(_ viewID: ViewID, in context: BlocksContext) {
    guard let view = finishedView(in: context) else {
      return endWithInternalError(
               "failed to finish re-render view: \(self)")
    }
    response.log.notice("replace using views.update ...")
    return client.views.update(view, with: viewID) { error, payload in
      self.endWithErrorOrACK(error, "failed to update view: \(self)")
    }
  }
  
  /**
   * Publish the View in the context to the hometab using the client's
   * `views.publish`.
   *
   * Requires a triggerID.
   *
   * Docs: https://api.slack.com/methods/views.publish
   */
  func publishView(in context: BlocksContext) {
    guard let view = finishedView(in: context) else {
      return endWithInternalError("failed to finish view: \(self)")
    }
    
    response.log.notice("publish using views.publish ...")
    return client.views.publish(view, userID: userID) {
      error, _ in
      self.endWithErrorOrACK(error, "failed to publish view: \(self)")
    }
  }
  
  /**
   * Open the View using the client's `views.open`.
   *
   * Requires a triggerID.
   */
  func openView(in context: BlocksContext) {
    guard let view = finishedView(in: context) else {
      return endWithInternalError("failed to finish view: \(self)")
    }
    guard let triggerID = triggerID else {
      return endWithInternalError("cannot push w/o trigger-id!")
    }
    
    response.log.notice("open using views.open ...")
    return client.views.open(view, with: triggerID) {
      error, _ in
      self.endWithErrorOrACK(error, "failed to open view: \(self)")
    }
  }

  /**
   * Push the View in the context using the client's `views.push`.
   *
   * Requires a triggerID.
   */
  func pushView(in context: BlocksContext) {
    guard let view = finishedView(in: context) else {
      return endWithInternalError("failed to finish render push view: \(self)")
    }
    guard let triggerID = triggerID else {
      return endWithInternalError("cannot push w/o trigger-id!")
    }
    
    response.log.notice("views.push ...")
    return client.views.push(view, with: triggerID) { error, payload in
      self.endWithErrorOrACK(error, "failed to push view: \(self)")
    }
  }
  
  /**
   * Post a message to a conversation publically, or ephemeral if that's set in
   * the context.
   */
  func postMessage(_          blocks : [ Block ],
                   to conversationID : ConversationID,
                   in        context : BlocksContext)
  {
    let hasRichText = client.token.supportsRichText // TBD
    let sendBlocks  = hasRichText ? blocks : blocks.replacingRichText()
    
    switch context.messageResponseScope {
      case .inConversation, .none:
        return client.chat.postMessage(in: conversationID,
                                       blocks: sendBlocks)
        {
          error, payload in
          self.endWithErrorOrACK(error,
                                 "could not push message \(self)")
        }
      
      case .userOnly:
        return client.chat.postEphemeral(in: conversationID, to: userID,
                                         blocks: sendBlocks)
        {
          error, payload in
          self.endWithErrorOrACK(error,
                                 "could not push message \(self)")
        }
    }
  }
  
}
