//
//  BlocksEndpoint.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import protocol  Blocks.Blocks
import struct    Blocks.BlocksBuilder
import protocol  Blocks.CallbackIDTransparentModifier
import typealias MacroExpress.Middleware
import enum      MacroExpress.bodyParser
import struct    SlackBlocksModel.CallbackID
import enum      SlackBlocksModel.InteractiveRequest

// This is in SwiftBlocksUI because otherwise BlocksExpress would need a
// dependency on SlackClient.

/**
 * A middleware which can run interactive requests of all sorts against a
 * given block. I.e. it will push request values into the Blocks, invoke
 * actions if applicable, and perform responses on behalf of actions.
 *
 * If this needs to do SlackClient actions, it'll resort to the SlackClient
 * environment key default, which is not quite perfect. (i.e. it requires the
 * token environment variable to be set up properly).
 */
@inlinable
public func interactiveBlocks<B: Blocks>(@BlocksBuilder blocks: () -> B)
            -> Middleware
{
  // Intentionally static. (TBD)
  let rootBlocks = blocks() // can be a View or other interactive Blocks
  let callbackID = CallbackID.blockID(for: rootBlocks)
  
  return { req, res, next in
    
    try bodyParser.parseInteractiveRequest(req: req, res: res)
    guard let request = req.interactiveRequest     else { return next() }
    guard request.isValidForCallbackID(callbackID) else { return next() }
    
    let client = SlackClient(token: req.slackAccessToken)
    
    // Setting the client only to make it explicit. Maybe we should rather
    // collect the client from the context somehow.
    let blocks = CallbackIDTransparentEnvironmentWritingModifier(rootBlocks) {
                   env in
                   env[keyPath: \.log]    = req.log
                   env[keyPath: \.client] = client
                 }
                 .interactiveEnvironment(request)
    #if DEBUG
      assert(callbackID == CallbackID.blockID(for: blocks))
    #endif

    let response = BlocksEndpointResponse(
      requestContainer : request.container,
      responseURL      : request.responseURL,
      triggerID        : request.triggerID,
      userID           : request.userID,
      accessToken      : req.slackAccessToken,
      response         : res,
      blocks           : blocks
    )
    
    switch request { // TODO: split up code
    
      case .blockActions(let blockActions):
        req.log.trace("process block actions \(blockActions)")
        try response.takeValues(from: blockActions.actions.asFormState)
        
        // I suspect only a single action will be really active,
        // but multiple block elements may submit values (i.e. all
        // in the Blocks?)
        // temporary test
        assert(blockActions.actions.count == 1)
          // If there is more than one, the `end` needs to be a counter!
        
        try response.invoke(.actions(blockActions.actions, response))
        req.log.trace("done with request handling phase for actions")

      case .viewClosed:
        req.log.trace("process block view close")
        try response.invoke(.viewClose(response))
        req.log.trace("done with request handling phase for close")

      case .viewSubmission(let submit):
        response.enableResponseAction()
        req.log.trace("process block view submission \(submit)")
        try response.takeValues(from: submit.view.state.values)
        req.log.trace("process block view invocation \(submit)")
        try response.invoke(.submit(response))
        req.log.trace("done with request handling phase for: \(submit)")
        
      case .messageAction, .shortcut:
        req.log.notice("not running request handling phase for: \(request)")
    }
    
    if response.matchingActions < 1 {
      response.endWithNoActionTriggered()
    }
  }
}

import enum SlackBlocksModel.InteractiveRequest

extension Collection where Element == InteractiveRequest.BlockAction {
  
  @usableFromInline
  var asFormState: BlocksContext.FormState {
    var state = BlocksContext.FormState()
    
    for action in self {
      guard let value = action.value else { continue }
      state[action.blockID, default: [:]][action.actionID] = value
    }
    return state
  }
}
