//
//  PickerPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.UserID
import struct SlackBlocksModel.ChannelID
import struct SlackBlocksModel.ConversationID

extension Picker: BlocksPrimitive where Content: Blocks {
  
  // Pickers are more complex than plain text fields, because they are
  // allowed in accessories.
  // They can appear in Modal/Input's, Section Accessories and Actions blocks.

  enum PickerRenderingError: Swift.Error {
    case internalInconsistency
  }
  
  public func render(in context: BlocksContext) throws {
    guard let block = context.currentBlock else {
      if context.surface == .modal {
        return try Input(label: title, content: { self })
                     .render(in: context)
      }
      else {
        return try Actions(content: { self }).render(in: context)
      }
    }
    
    switch block {
      case .richText, .image, .context:
        context.log
          .warning("Attempt to use Picker in a unsupported block: \(block)")
        context.closeBlock()
        return try render(in: context) // recurse
      case .divider:
        context.closeBlock()
        return try render(in: context) // recurse
    
      case .section, .actions, .input: break
    }

    switch block {
      case .richText, .image, .context, .divider:
        fatalError("unexpected state")
      
      case .section : try renderIntoSection(in: context)
      case .actions : try renderIntoActions(in: context)
      case .input   : try renderIntoInput  (in: context)
    }
  }
  
  private func buildAPIPicker(with actionID : Block.ActionID,
                              in    context : BlocksContext)
               -> APIPicker
  {
    let allowsMulti       = Selection.allowsMultipleSelection
    let maxSelectionCount = self.maxSelectionCount ?? (allowsMulti ? nil : 1)
    
    if let minQueryLength = minQueryLength { // external
      return .externalSelect(.init(
        actionID         : actionID, placeholder: placeholder ?? title,
        initialOptions   : nil, // no way to specify them?
        minQueryLength   : minQueryLength,
        maxSelectedItems : maxSelectionCount,
        confirm          : context.confirmationDialog)
      )
    }
    
    func getInitialIDs<T: Hashable>(_ type: T.Type) -> [ T ]? {
      guard let selection = selection?.getter().selection else { return nil }
      guard !selection.isEmpty else { return nil }
      assert(selection is Set<T>)
      return Array(selection) as? [ T ]
    }
    
    if Selection.SelectionValue.self == UserID.self {
      return .userSelect(.init(
        actionID         : actionID, placeholder: placeholder ?? title,
        initialUserIDs   : getInitialIDs(UserID.self),
        maxSelectedItems : maxSelectionCount,
        confirm          : context.confirmationDialog
      ))
    }
    else if Selection.SelectionValue.self == ChannelID.self {
      return .channelSelect(.init(
        actionID          : actionID, placeholder: placeholder ?? title,
        initialChannelIDs : getInitialIDs(ChannelID.self),
        maxSelectedItems  : maxSelectionCount,
        confirm           : context.confirmationDialog
      ))
    }
    else if Selection.SelectionValue.self == ConversationID.self {
      return .conversationSelect(.init(
        actionID               : actionID, placeholder: placeholder ?? title,
        initialConversationIDs : getInitialIDs(ConversationID.self),
        maxSelectedItems       : maxSelectionCount,
        confirm                : context.confirmationDialog
      ))
    }
    else {
      return .staticSelect(.init(
        actionID         : actionID, placeholder: placeholder ?? title,
        options          : [], optionGroups: nil,
        initialOptions   : nil, // will be collected during rendering
        maxSelectedItems : maxSelectionCount,
        confirm          : context.confirmationDialog)
      )
    }
  }

  /**
   * Create a SelectionState object for the picker.
   */
  private func setupSelectionState(for actionID : Block.ActionID,
                                   in   context : BlocksContext)
               -> SelectionManagerState<Selection>?
  {
    guard let selection = self.selection else { return nil }
    
    switch context.mode {
      case .invoke:
        return nil
        
      case .render:
        return SelectionManagerState(selection: selection.getter(),
                                     clientValues: [])

      case .takeValues(let formValues):
        var clear = selection.getter()
        clear.deselectAll() // essentially simulate a constructor
        
        if let value = formValues.valueForActionID(actionID) {
          if let value = value as? String {
            return SelectionManagerState(selection: clear,
                                         clientValues: [ value ])
          }
          else if let values = value as? [ String ] {
            return SelectionManagerState(selection: clear,
                                         clientValues: Set(values))
          }
          else if let values = value as? Set<String> {
            return SelectionManagerState(selection: clear,
                                         clientValues: values)
          }
          else {
            context.log.warning("Cannot process Picker value: \(value)")
            assertionFailure("cannot process Picker value: \(value)")
            return SelectionManagerState(selection: clear, clientValues: [])
          }
        }
        else {
          return SelectionManagerState(selection: clear, clientValues: [])
        }
    }
  }
  
  private var hasSubmitAction: Bool {
    return actionID == submitActionID
  }

  /// The proper API picker block is pushed to the context.
  private func afterBlockSetup(for actionID : Block.ActionID,
                               in   context : BlocksContext) throws
  {
    // This is above the takeValues, but is run in a separate (second) phase :-)
    // This can't match the exact action IDs in block action actions, because
    // those will map to the Options, not the picker ID.
    // TBD: Explain again, forgot why :-) The Picker has the actionID,
    //      not the options?
    try context.invokeAction(action, for: self.actionID, id: actionID,
                             prefixMatch: true,
                             in: context)

    // This needs to push a state depending on render/takeValues for the
    // options to process

    let oldState = context.selectionState
    let state    = setupSelectionState(for: actionID, in: context)
    context.selectionState = state
    defer {
      if let state = state {
        assert(context.selectionState === state)
      }
      context.selectionState = oldState
    }

    switch context.mode {
      case .invoke:
        // Picker content cannot have actions
        return
        
      case .render:
        if let content = content { try context.render(content) }
        assert(context.currentBlock != nil)
        if let state = state, context.selectionState === state,
           var block = context.currentBlock
        {
          context.currentBlock = nil
          addInitialOptionsWithClientValues(state.clientValues, to: &block)
          context.currentBlock = block
        }
        
      case .takeValues: // (let state):
        if let content = content { try context.render(content) }
        if let state = state, context.selectionState === state {
          // apply new selection:
          selection?.setter(state.selection)
        }
    }
  }
  
  
  // MARK: - Initial Options
  
  private func addInitialOptionsWithClientValues(_ values: Set<String>,
                                                 to block: inout Block) {
    // TODO: derive initialOptions from state.clientValues
    // TODO: walk over the options and copy the active ones to the block
    guard !values.isEmpty else { return }
    
    switch block {
      case .richText, .image, .context, .divider:
        assertionFailure("unexpected block")
        return
        
      case .input(var input):
        switch input.element {
          case .staticSelect(var staticSelect):
            staticSelect.setInitialOptions(values)
            input.element = .staticSelect(staticSelect)
            block = .input(input)
          default:
            assertionFailure("unexpected element for initial options")
            return globalBlocksLog.error("cannot set initial opts: \(self)")
        }
        
      case .actions(var actions):
        guard !actions.elements.isEmpty else { return }
        var last = actions.elements.removeLast()
        last.setInitialOptions(values)
        actions.elements.append(last)
        block = .actions(actions)
        
      case .section(var section):
        section.accessory?.setInitialOptions(values)
        block = .section(section)
    }
  }
  
  
  // MARK: - Rendering
  
  private func renderIntoInput(in context: BlocksContext) throws {
    guard case .input(var input) = context.currentBlock else {
      assertionFailure("expected input block, got \(context)")
      throw PickerRenderingError.internalInconsistency
    }
    
    // Our non-empty element in API hack
    guard input.containsDummyElement else { // element is taken already
      context.log
        .warning("Attempt to put multiple inputs in an Input block: \(input)")
      context.closeBlock()
      return try render(in: context) // recurse
    }
    
    let actionID  = context.currentActionID(for: self.actionID)
    input.element = buildAPIPicker(with: actionID, in: context).inputElement
    
    if !title.isEmpty && input.label.isEmpty {
      input.label = title
    }
    context.currentBlock = .input(input)
    
    try afterBlockSetup(for: actionID, in: context)
  }
  
  private func renderIntoActions(in context: BlocksContext) throws {
    guard case .actions(var actions) = context.currentBlock else {
      assertionFailure("expected actions block, got \(context)")
      throw PickerRenderingError.internalInconsistency
    }

    if context.level2Nesting != .none {
      context.log.warning(
        "Attempt to add nested Picker to Actions, please fix the nesting!")
      context.endLevelTwo()
    }

    context.startLevelTwo(.picker)
    defer { context.endLevelTwo() }

    let actionID = context.currentActionID(for: self.actionID)
    let element  = buildAPIPicker(with: actionID, in: context)
                   .interactiveElement
    
    context.currentBlock = nil
    actions.elements.append(element)
    context.currentBlock = .actions(actions)

    try afterBlockSetup(for: actionID, in: context)
  }
  
  private func renderIntoSection(in context: BlocksContext) throws {
    guard case .section(var section) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw PickerRenderingError.internalInconsistency
    }
    
    guard section.accessory == nil else {
      context.log.error(
        "Attempt to add Picker to Section which already has an accessory!")
      return // TBD: throw? (more throwing in general?)
    }
        
    context.currentBlock = nil
    
    let actionID = context.currentActionID(for: self.actionID)
    section.accessory = buildAPIPicker(with: actionID, in: context)
                        .accessory
    context.currentBlock = .section(section)
    
    try afterBlockSetup(for: actionID, in: context)
  }
}


// MARK: - API Picker

fileprivate enum APIPicker {
  
  case channelSelect     (Block.MultiChannelsSelect)
  case conversationSelect(Block.MultiConversationsSelect)
  case externalSelect    (Block.MultiExternalSelect)
  case staticSelect      (Block.MultiStaticSelect)
  case userSelect        (Block.MultiUsersSelect)

  // you gotta love static typing
  var interactiveElement : Block.InteractiveElement {
    switch self {
      case .channelSelect     (let v): return .channelSelect     (v)
      case .conversationSelect(let v): return .conversationSelect(v)
      case .externalSelect    (let v): return .externalSelect    (v)
      case .staticSelect      (let v): return .staticSelect      (v)
      case .userSelect        (let v): return .userSelect        (v)
    }
  }
  var inputElement : Block.Input.Element {
    switch self {
      case .channelSelect     (let v): return .channelSelect     (v)
      case .conversationSelect(let v): return .conversationSelect(v)
      case .externalSelect    (let v): return .externalSelect    (v)
      case .staticSelect      (let v): return .staticSelect      (v)
      case .userSelect        (let v): return .userSelect        (v)
    }
  }
  var accessory : Block.Accessory {
    switch self {
      case .channelSelect     (let v): return .channelSelect     (v)
      case .conversationSelect(let v): return .conversationSelect(v)
      case .externalSelect    (let v): return .externalSelect    (v)
      case .staticSelect      (let v): return .staticSelect      (v)
      case .userSelect        (let v): return .userSelect        (v)
    }
  }
}


// MARK: - SelectionManager based SelectionState object

fileprivate final class SelectionManagerState<M: SelectionManager>
                        : SelectionState, CustomStringConvertible
{
  // TBD: This is not quite what I want for selection. I'd prefer to get
  //      actual model objects in the selection, not their ID.

  /// Those are the server-side tags representing the selection
  var selection    : M
  
  /// Those are the client side values (the value in the API Option element).
  var clientValues : Set<String>
  
  var description: String {
    var ms = "<SelState:"
    if selection.selection.isEmpty { ms += " sel-empty" }
    else { ms += " selection=\(selection)" }
    if clientValues.isEmpty { ms += " val-empty" }
    else { ms += " values=" + clientValues.joined(separator: ",") }
    ms += ">"
    return ms
  }
  
  init(selection: M, clientValues: Set<String>) {
    self.selection    = selection
    self.clientValues = clientValues
  }

  func select(_ tag: M.SelectionValue) {
    selection.select(tag)
  }
  func isSelected(_ tag: M.SelectionValue) -> Bool {
    return selection.isSelected(tag)
  }

  func isSelected<Tag: Hashable>(_ tag: Tag) -> Bool {
    guard let typedTag = tag as? M.SelectionValue else {
      globalBlocksLog.notice(
        "attempt to check tag of different type \(tag) in \(self)")
      return false
    }
    return isSelected(typedTag)
  }
  func select<Tag: Hashable>(_ tag: Tag) {
    guard let typedTag = tag as? M.SelectionValue else {
      globalBlocksLog.warning(
        "Could not select tag of different type \(tag) in \(self)")
      return
    }
    select(typedTag)
  }
}
