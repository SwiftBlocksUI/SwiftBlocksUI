//
//  BlocksContextIDs.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.CallbackID

extension BlocksContext { // MARK: - Root IDs (CallbackIDs)

  @inlinable
  internal func pushRootCallbackID(_ id: @autoclosure () -> CallbackID) -> Bool
  {
    guard rootCallbackID == nil else { return false }
    let id = id()
    rootCallbackID = id
    assert(currentElementID.isEmpty)
    currentElementID.appendElementIDComponent(id)
    // This is to ensure that we always have a dot in generated element IDs.
    currentElementID.appendElementIDComponent("/")
    return true
  }
  @inlinable
  internal func popRootCallbackID() {
    assert(rootCallbackID != nil)
    assert(currentElementID.count == 2)
    currentElementID.deleteLastElementIDComponent()
    currentElementID.deleteLastElementIDComponent()
  }
}

extension BlocksContext {

  func consumePendingTag() -> AnyHashable? {
    let tag = pendingTag
    pendingTag = nil
    return tag
  }

  func consumePendingID() -> AnyHashable? {
    let id = pendingID
    pendingID = nil
    return id
  }

  fileprivate func logUnusedPendingID(_ id: AnyHashable?) {
    guard let id = id else { return }
    log.notice("did not use pending-ID: \(id)")
  }
}

public extension BlocksContext { // MARK: - Block IDs

  func currentBlockID(for style: BlockIDStyle) -> Block.BlockID {
    let pendingID = consumePendingID()
    
    switch style {
      case .globalID(let id):
        logUnusedPendingID(pendingID)
        return id
        
      case .rootRelativeID(let part):
        logUnusedPendingID(pendingID)
        if rootCallbackID == nil {
          log.error(
            "attempt to generate relative blockID, but no root-id is set!")
        }
        assert(rootCallbackID != nil)
        return Block.BlockID((rootCallbackID?.id ?? "_") + "." + part)
        
      case .elementID:
        logUnusedPendingID(pendingID)
        return Block.BlockID(currentElementID)
        
      case .auto:
        if let id = pendingID {
          return Block.BlockID((rootCallbackID?.id ?? "_") + "." + id.webID)
        }
        else {
          return Block.BlockID(currentElementID)
        }
    }
  }
  func blockID<B: TopLevelPrimitiveBlock>(for block: B) -> Block.BlockID {
    return currentBlockID(for: block.blockID)
  }
}

extension BlocksContext { // MARK: - Action IDs
  
  func currentActionID(for style: ActionIDStyle) -> Block.ActionID {
    let pendingID = consumePendingID()

    switch style {
      case .globalID(let id):
        logUnusedPendingID(pendingID)
        return id
        
      case .rootRelativeID(let part):
        logUnusedPendingID(pendingID)
        if rootCallbackID == nil {
          log.error(
            "attempt to generate relative actionID, but no root-id is set!")
        }
        assert(rootCallbackID != nil)
        return Block.ActionID((rootCallbackID?.id ?? "_") + "." + part)
        
      case .elementID:
        logUnusedPendingID(pendingID)
        return Block.ActionID(currentElementID)
        
      case .auto:
        if let id = pendingID {
          return Block.ActionID((rootCallbackID?.id ?? "_") + "." + id.webID)
        }
        else {
          return Block.ActionID(currentElementID)
        }
    }
  }
}
