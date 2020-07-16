//
//  CheckboxGroupPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension CheckboxGroup: BlocksPrimitive {
  
  enum CheckboxRenderingError: Swift.Error {
    case internalInconsistency
  }
  
  public func render(in context: BlocksContext) throws {
    guard let block = context.currentBlock else {
      switch context.surface {
        case .modal:
          return try Input(title, content: { self })
                      .render(in: context)
        case .homeTab:
          return try Actions(content: { self }).render(in: context)
          
        case .message: // FIXME: need to make this an optional
          return try Input(title, content: { self })
                      .render(in: context)

      }
    }
    
    switch block {
      case .richText, .image, .context:
        context.log
          .warning("CheckboxGroup in an unsupported block: \(block)")
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
  
  private func buildAPICheckboxes(with actionID : Block.ActionID,
                                  in    context : BlocksContext)
               -> Block.Checkboxes
  {
    #if false
    func getInitialIDs<T: Hashable>(_ type: T.Type) -> [ T ]? {
      guard let selection = selection?.getter().selection else { return nil }
      guard !selection.isEmpty else { return nil }
      assert(selection is Set<T>)
      return Array(selection) as? [ T ]
    }
    #endif
    return .init(actionID: actionID, options: [],
                 initialOptions: [], confirm: context.confirmationDialog)
  }

  /**
   * Create a SelectionState object for the checkboxes.
   */
  private func setupSelectionState(for actionID : Block.ActionID,
                                   in   context : BlocksContext)
               -> ClientOnlyState?
  {
    switch context.mode {
      case .invoke:
        return nil
        
      case .render:
        return ClientOnlyState(clientValues: [])

      case .takeValues(let formValues):
        if let value = formValues.valueForActionID(actionID) {
          if let value = value as? String {
            return ClientOnlyState(clientValues: [ value ])
          }
          else if let values = value as? [ String ] {
            return ClientOnlyState(clientValues: Set(values))
          }
          else if let values = value as? Set<String> {
            return ClientOnlyState(clientValues: values)
          }
          else {
            context.log.warning("Cannot process Checkboxes value: \(value)")
            assertionFailure("cannot process Checkboxes value: \(value)")
            return ClientOnlyState(clientValues: [])
          }
        }
        else {
          return ClientOnlyState(clientValues: [])
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
    // those will map to the Options, not the checkboxes ID.
    // TBD: Explain again, forgot why :-) The Checkboxes have the actionID,
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
        try context.render(content)
        assert(context.currentBlock != nil)
        if let state = state, context.selectionState === state,
           var block = context.currentBlock
        {
          context.currentBlock = nil
          addInitialOptionsWithClientValues(state.clientValues, to: &block)
          context.currentBlock = block
        }
        
      case .takeValues:
        try context.render(content)
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
          case .checkboxes(var checkboxes):
            checkboxes.setInitialOptions(values)
            input.element = .checkboxes(checkboxes)
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
      throw CheckboxRenderingError.internalInconsistency
    }
    
    // Our non-empty element in API hack
    guard input.containsDummyElement else { // element is taken already
      context.log
        .warning("Attempt to put multiple inputs in an Input block: \(input)")
      context.closeBlock()
      return try render(in: context) // recurse
    }
    
    let actionID  = context.currentActionID(for: self.actionID)
    input.element = buildAPICheckboxes(with: actionID, in: context).inputElement
    
    if !title.isEmpty && input.label.isEmpty {
      input.label = title
    }
    context.currentBlock = .input(input)
    
    try afterBlockSetup(for: actionID, in: context)
  }
  
  private func renderIntoActions(in context: BlocksContext) throws {
    guard case .actions(var actions) = context.currentBlock else {
      assertionFailure("expected actions block, got \(context)")
      throw CheckboxRenderingError.internalInconsistency
    }

    if context.level2Nesting != .none {
      context.log.warning(
        "Attempt to add nested Checkboxes to Actions, please fix the nesting!")
      context.endLevelTwo()
    }

    context.startLevelTwo(.picker)
    defer { context.endLevelTwo() }

    let actionID = context.currentActionID(for: self.actionID)
    let element  = buildAPICheckboxes(with: actionID, in: context)
                   .interactiveElement
    
    context.currentBlock = nil
    actions.elements.append(element)
    context.currentBlock = .actions(actions)

    try afterBlockSetup(for: actionID, in: context)
  }
  
  private func renderIntoSection(in context: BlocksContext) throws {
    guard case .section(var section) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw CheckboxRenderingError.internalInconsistency
    }
    
    guard section.accessory == nil else {
      context.log.error(
        "Attempt to add Checkboxes to Section which already has an accessory!")
      return // TBD: throw? (more throwing in general?)
    }
        
    context.currentBlock = nil
    
    let actionID = context.currentActionID(for: self.actionID)
    section.accessory = buildAPICheckboxes(with: actionID, in: context)
                        .accessory
    context.currentBlock = .section(section)
    
    try afterBlockSetup(for: actionID, in: context)
  }
}

fileprivate extension Block.Checkboxes {
  
  var accessory          : Block.Accessory          { return .checkboxes(self) }
  var interactiveElement : Block.InteractiveElement { return .checkboxes(self) }
  var inputElement       : Block.Input.Element      { return .checkboxes(self) }
}

// MARK: - SelectionManager based SelectionState object

fileprivate final class ClientOnlyState: SelectionState, CustomStringConvertible
{
  /// Those are the client side values (the value in the API Option element).
  var clientValues : Set<String>
  
  var description: String {
    var ms = "<ClientSelState:"
    if clientValues.isEmpty { ms += " val-empty" }
    else { ms += " values=" + clientValues.joined(separator: ",") }
    ms += ">"
    return ms
  }
  
  init(clientValues: Set<String>) {
    self.clientValues = clientValues
  }
  func select<Tag: Hashable>(_ tag: Tag) {
    globalBlocksLog
      .error("attempt to select tag \(tag) in client-only state ...")
    assertionFailure("attempt to select tag \(tag) in client-only state ...")
  }
  func isSelected<Tag: Hashable>(_ tag: Tag) -> Bool {
    globalBlocksLog
      .error("attempt to check tag \(tag) selection in client-only state ...")
    assertionFailure(
      "attempt to check select tag \(tag) in client-only state ...")
    return false
  }
}
