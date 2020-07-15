//
//  BlocksContext.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum   SlackBlocksModel.Block
import enum   SlackBlocksModel.InteractiveRequest
import struct SlackBlocksModel.View
import struct SlackBlocksModel.CallbackID
import struct SlackBlocksModel.MessageResponse
import struct Logging.Logger

public final class BlocksContext {

  /// This is the result of the rendering.
  public internal(set) var blocks = [ Block ]()
    // this also affects nesting, which is why we (for this version) also
    // need to create it during request processing ...
  
  public let log     : Logger
  public var surface : Block.BlockSurface = .message
  
  public internal(set) var pendingID  : AnyHashable?
  public internal(set) var pendingTag : AnyHashable?
  var selectionState : SelectionState?

  /// Just a nested map of form values.
  public typealias FormState = [ Block.BlockID
                               : [ Block.ActionID
                                 : InteractiveRequest.View.State.Value ] ]
  
  public enum Mode {
    public enum Invocation {
      case submit   (ActionResponse?)
      case viewClose(ActionResponse?)
      case actions  ([ InteractiveRequest.BlockAction ], ActionResponse?)
    }
    
    case render
    case takeValues(FormState)
    case invoke    (Invocation)
  }
  public var mode : Mode = .render // TBD: make it internal
  
  public internal(set) var view : SlackBlocksModel.View?
  public internal(set) var messageResponseScope : MessageResponse.ResponseType?
  
  var currentBlock  : Block?
  var level2Nesting = BlockNesting.none
  
  var confirmationDialog : Block.ConfirmationDialog?

  /**
   * The root callbackID is the ID of the top-level element which got rendered
   * (i.e. the first).
   * This is being used to route incoming requests to the right View/Blocks.
   */
  @usableFromInline
  internal var rootCallbackID   : CallbackID? // public for inlinable
  @usableFromInline
  internal var currentElementID = ElementID(components: [])
  
  @usableFromInline
  internal var state            = [ ElementID : Any ]()
  @usableFromInline
  internal var metaData         = MetaDataValues()
  
  /// Validation errors for viewSubmission block elements.
  public internal(set) var blockErrors = [ Block.BlockID : String ]()
  public func addError(_ message: String, in blockStyle: BlockIDStyle) {
    blockErrors[currentBlockID(for: blockStyle)]
      = message.isEmpty ? "Invalid Input" : message
  }

  // Type Cache to avoid locking the global one too much
  var _componentTypeCache = [ ObjectIdentifier : ComponentTypeInfo ]()

  
  // MARK: - Init
  
  public init(log: Logger = globalBlocksLog) {
    self.log = log
  }

  public func pushMetaData(_ metaData: MetaDataValues) {
    self.metaData = metaData
  }
  
  /**
   * Create a new context for rendering new Blocks in response to some
   * request processed by other blocks.
   *
   * Keep: caches, surface, log
   * Drop: view, mode
   *
   * - Parameter preserveState:
   *     Whether or not the state dictionary should be copied over. Used if the
   *     same Blocks are rerendered. Not used, if _new_ blocks are rendered.
   */
  public func makeResponseContext(preserveState: Bool) -> BlocksContext {
    // TODO: transfer metadata and such
    let newContext = BlocksContext(log: log)
    
    newContext.surface             = surface
    newContext._componentTypeCache = _componentTypeCache
    newContext.metaData            = metaData
    
    if preserveState {
      newContext.state       = state
      newContext.blockErrors = blockErrors
    }
    
    return newContext
  }
  
  /**
   * Prepare the context for another rendering run.
   */
  public func prepareForMode(_ mode: Mode) {
    assert(currentElementID.isEmpty)
    assert(environments.isEmpty)
    assert(currentBlock   == nil)
    assert(level2Nesting  == .none)
    assert(pendingID      == nil)
    assert(pendingTag     == nil)
    assert(selectionState == nil)

    blocks.removeAll()
    currentElementID = ElementID(components: [])
    rootCallbackID = nil
    currentBlock   = nil
    level2Nesting  = .none
    view           = nil
    pendingID      = nil
    pendingTag     = nil
    selectionState = nil
    self.mode      = mode
    log.trace("preparing for mode: \(mode)")
  }
  
  
  // MARK: - Environment
  
  @usableFromInline
  final class Environments {
    @usableFromInline
    var environmentStack = [ EnvironmentValues.empty ]
    
    @inlinable
    var environment : EnvironmentValues {
      return environmentStack.last ?? EnvironmentValues.empty
    }
    
    var isEmpty: Bool {
      if environmentStack.isEmpty { return true }
      if environmentStack.count == 1 && environmentStack[0].values.isEmpty {
        return true
      }
      return false
    }
  }
  
  @usableFromInline
  var environments = Environments()
  @inlinable
  var environment : EnvironmentValues { return environments.environment }
}

extension BlocksContext: CustomStringConvertible {
  
  public var description: String {
    var ms = "<BlocksCtx:"
    
    switch mode {
      case .render: break
      case .takeValues(let state): ms += " takeValues(#\(state))"
      case .invoke(let invocationType):
        switch invocationType {
          case .submit(.some) : ms += " submit"
          case .submit(.none) : ms += " submit-done"
          case .viewClose     : ms += " view-close"
          case .actions(let actions, .some):
            ms += " actions="
            ms += actions.map { $0.actionID.id }.joined(separator: ",")
          case .actions(let actions, .none):
            ms += " actions-done="
            ms += actions.map { $0.actionID.id }.joined(separator: ",")
        }
    }
    
    if level2Nesting != .none  { ms += " \(level2Nesting)"  }
    
    if let v = pendingID       { ms += " pending-id=\(v)"   }
    if let v = pendingTag      { ms += " pending-tag=\(v)"  }
    if let v = view {
      if let id = v.callbackID { ms += " view=\(id.id)" }
      else                     { ms += " view"          }
    }
    
    switch ( blocks.isEmpty, currentBlock ) {
      case ( true,  .none            ) : ms += " no-blocks"
      case ( true,  .some(let block) ) : ms += " generating=\(block)"
      case ( false, .none            ) :
        if blocks.count == 1 { ms += " block=\(blocks[0])"      }
        else                 { ms += " #blocks=\(blocks.count)" }
      case ( false, .some(let block) ) :
        ms += " generating=\(block)(#\(blocks.count))"
    }
    
    if !currentElementID.isEmpty { ms += " eid=\(currentElementID.webID)" }
    if !state.isEmpty            { ms += " #state=\(state.count)"         }
    if let v = rootCallbackID, v != view?.callbackID { ms += " rootID=\(v.id)" }
    
    switch surface {
      case .homeTab : ms += " home-tab"
      case .modal   : ms += " modal"
      case .message : break
    }
    
    ms += ">"
    return ms
  }
}
