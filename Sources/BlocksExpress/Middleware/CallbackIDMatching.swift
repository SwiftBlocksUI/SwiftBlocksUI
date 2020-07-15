//
//  CallbackIDMatching.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.CallbackID
import enum   SlackBlocksModel.InteractiveRequest
import enum   SlackBlocksModel.Block

extension InteractiveRequest.ViewInfo {

  /**
   * Scans the element IDs in the state for a root-id which matches our
   * callbackID.
   *
   * Since the user can customize both, block and action-ids, we need to
   * check both.
   *
   * Note that neither a plain block or action ID is itself a callback ID! They
   * do not have the same uniqueness as a callback ID!
   * So this only scans for generated element IDs (i.e. those containing a ".").
   */
  @usableFromInline
  func matchesCallbackID(_ id: CallbackID) -> Bool {
    for ( blockID, state ) in state.values {
      if blockID.matchesCallbackID(id) { return true }
      for actionID in state.keys {
        if actionID.matchesCallbackID(id) { return true }
      }
    }
    return false
  }
}

extension Collection where Element == InteractiveRequest.BlockAction {
  
  @usableFromInline
  func matchesCallbackID(_ id: CallbackID) -> Bool {
    return contains(where: { $0.matchesCallbackID(id) })
  }
}

extension InteractiveRequest.BlockAction {
  
  @usableFromInline
  func matchesCallbackID(_ id: CallbackID) -> Bool {
    if blockID .matchesCallbackID(id) { return true }
    if actionID.matchesCallbackID(id) { return true }
    return false
  }
}

fileprivate protocol CallbackIDMatchable {
  var id : String { get }
}
extension CallbackIDMatchable {
  
  func matchesCallbackID(_ callbackID: CallbackID) -> Bool {
    guard let idx = self.id.firstIndex(of: ".") else { return false }
    let prefix = self.id[..<idx]
    return prefix == callbackID.id
  }
}
extension Block.BlockID  : CallbackIDMatchable {}
extension Block.ActionID : CallbackIDMatchable {}


public extension InteractiveRequest {

  @inlinable
  func isValidForCallbackID(_ callbackID: CallbackID) -> Bool {
    // OK, it is an interactive request, check whether it matches our view
    if let requestID = self.callbackID {
      guard callbackID == requestID else { return false }
    }
    else if case .blockActions(let actions) = self {
      if !actions.actions.isEmpty {
        guard actions.actions.matchesCallbackID(callbackID) else {
          return false
        }
      }
      else if let view = self.viewInfo {
        guard view.matchesCallbackID(callbackID) else { return false }
      }
    }
    else if let view = self.viewInfo { // no explicit ID, try to find it
      // The ID of submit.view is the Slack assigned ViewID (e.g. V172727)
      // Look at state to find our callbackID. We only match
      // rootID.xyz patterns
      guard view.matchesCallbackID(callbackID) else {
        return false
      }
    }
    else {
      return false
    }
    
    return true
  }
}
