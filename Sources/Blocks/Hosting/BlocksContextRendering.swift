//
//  BlocksContextRendering.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.View
import struct SlackBlocksModel.CallbackID

public extension BlocksContext {
  
  @inlinable
  func render<V: Blocks>(_ component: V) throws {
    let didPush = pushRootCallbackID(CallbackID.blockID(for: component))
    defer { if didPush { popRootCallbackID() }}

    if case .dynamic(let props) = lookupTypeInfo(for: component) {
      try withMutableComponent(for: component) { mutableComponent in
        enterComponent(&mutableComponent)
        defer { leaveComponent(&mutableComponent) }

        // Using ElementIDs to maintain the property storage is a little hacky,
        // but not that much.
        // This way we don't need to communicate the position of a property
        // wrapper explicitly (i.e. inject the "slot" in SwiftWebUI).
        
        currentElementID.appendZeroElementIDComponent()
        props.forEach { prop in
          prop.withMutablePointer(&mutableComponent) { ptr in
            prop.typeInstance._updateInstance(at: ptr, context: self)
          }
          currentElementID.incrementLastElementIDComponent()
        }
        currentElementID.deleteLastElementIDComponent()
        
        if let primitive = mutableComponent as? BlocksPrimitive {
          try primitive.render(in: self)
        }
        else {
          try render(mutableComponent.body)
        }
      }
    }
    else if let primitive = component as? BlocksPrimitive {
      try primitive.render(in: self)
    }
    else {
      try render(component.body)
    }
  }
  
  @inlinable
  func render<V: Blocks & BlocksPrimitive>(_ blocks: V) throws {
    let didPush = pushRootCallbackID(CallbackID.blockID(for: blocks))
    defer { if didPush { popRootCallbackID() }}
    try blocks.render(in: self)
  }
  
}

extension BlocksContext {
  
  /**
   * This can be overidden by implementations which provide outline View state
   * somewhere.
   * The default implementation just captures the View in a local variable, and
   * passes that along.
   */
  @inlinable
  func withMutableComponent<V: Blocks>(for component: V,
                                       execute: ( inout V ) throws -> Void)
         throws
  {
    var localCopy = component
    try execute(&localCopy)
  }
}

extension BlocksContext {
  
  enum BlockNesting: String {
    case none
    case level2    // a generic level 2 nesting
    case accessory // section accessory
    case field     // section field
    case button    // a button (in an action)
    case picker    // a picker (in an action)
  }

  /**
   * Start a new block.
   */
  func startBlock(_ block: Block) {
    if let oldBlock = currentBlock {
      log.error(
        """
        invalid block nesting, attempt to start a new block:
        
          \(block)
        
        while another block is still open:
        
          \(oldBlock)
        
        This probably means top-level blocks have been nested!
        """
      )
      closeBlock()
    }
    
    assert(currentBlock == nil)
    currentBlock  = block
    level2Nesting = .none
  }
  
  func reopenLastBlock() -> Block? {
    if currentBlock != nil { return nil } // already open
    if blocks.isEmpty      { return nil } // no last block
    currentBlock = blocks.removeLast()
    return currentBlock
  }
  
  /**
   * Add the current block to the list of finished blocks.
   */
  func closeBlock() {
    assert(level2Nesting == .none)
    guard let oldBlock = currentBlock else {
      return log.warning("Attempt to close a block when none is open!")
    }
    blocks.append(oldBlock)
    currentBlock  = nil
    level2Nesting = .none
  }
  func dropCurrentBlock() {
    guard currentBlock != nil else {
      return log.warning("Attempt to drop a block when none is open!")
    }
    currentBlock = nil
    level2Nesting = .none
  }
  func dropLastBlock() {
    defer { level2Nesting = .none; currentBlock = nil }
    if currentBlock != nil { return }
    guard !blocks.isEmpty else {
      return log.warning("Attempt to drop last block, but there is none!")
    }
    blocks.removeLast()
  }

  func startLevelTwo(_ nesting: BlockNesting) {
    if level2Nesting != .none {
      log.error(
        "New 2nd-level element while another is still open, incorrect nesting!"
      )
    }
    level2Nesting = nesting
  }
  func endLevelTwo() {
    level2Nesting = .none
  }
  
  @discardableResult
  public func finishView(defaultTitle: String) -> SlackBlocksModel.View {
    let privateMetaData : String?
    do {
      let s = try metaData.encodeMetaDataString()
      privateMetaData = s.isEmpty ? nil : s
      if s.count > 3000 {
        log.warning("encoded meta data exceeds the limit of 3k characters!")
      }
    }
    catch {
      log.error("failed to encode meta data as string! \(metaData): \(error)")
      privateMetaData = nil
    }
    
    if var view = self.view {
      self.view = nil
      view.blocks += blocks.asBlockSuitableForSurface(surface)
      blocks = []
      if view.callbackID == nil { view.callbackID = rootCallbackID }
      assert(view.callbackID != nil)
      view.privateMetaData = privateMetaData
      self.view = view
    }
    else {
      let viewType  : SlackBlocksModel.View.ViewType
      switch surface {
        case .homeTab : viewType = .home
        case .modal   : viewType = .modal
        case .message:
          log.warning("surface for View is message?! \(self)")
          viewType = .modal
      }
      
      assert(!defaultTitle.isEmpty, "A view *must* have a title!")
      assert(defaultTitle.count < 25)
      
      self.view = SlackBlocksModel.View(
        type            : viewType,
        callbackID      : rootCallbackID,
        externalID      : nil,
        title           : defaultTitle,
        closeTitle      : nil,    submitTitle     : nil,
        clearOnClose    : false,  notifyOnClose   : false,
        blocks          : blocks.asBlockSuitableForSurface(surface),
        privateMetaData : privateMetaData
      )
      blocks = []
    }
    
    return checkViewForConsistency()
  }
  
  @discardableResult
  private func checkViewForConsistency() -> SlackBlocksModel.View {
    // Make sure the View has a Submit title if it contains Input's.
    guard var view = self.view else {
      log.error("still got no View after finishView!")
      return .init(title: "Internal Error")
    }
    
    var hasInput : Bool {
      view.blocks.contains(where: { block in
        if case .input = block { return true }
        return false
      })
    }
    
    if case .render = mode {
      if view.submitTitle == nil, hasInput {
        log.notice(
          "View w/ Input, but has no explicit submit title: \(view) \(mode)")
        view.submitTitle = "Submit"
        self.view = view
      }
    }
    return view
  }
}
