//
//  TextFieldPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension TextField: BlocksPrimitive {
  
  private var editableStringValue: String {
    let typedValue = value.getter()
    return formatter?.editingString(for: typedValue)
        ?? formatter?.string(for: typedValue)
        ?? String(describing: typedValue)
  }
  
  /**
   * PlainText Input is really only allowed in Input blocks of modals.
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#input
   */
  public func render(in context: BlocksContext) throws {
    #if DEBUG // hack protect
      if case .globalID(let actionID) = actionID {
        assert(actionID != Block.PlainTextInput.dummyElementActionID)
      }
    #endif
    
    if context.surface != .modal {
      if context.blocks.isEmpty && context.currentBlock == nil {
        // If this is the first block, make it modal and start a View.
        context.surface = .modal
        return try context.render(View { self })
      }
      else {
        // This could happen when reusing views?
        context.log
          .notice("Attempt to use a TextField in a non-modal surface!")
        
        // Render as text
        return try Text(editableStringValue).render(in: context)
      }
    }
    else if context.view == nil { // auto start a View
      return try context.render(View { self })
    }
    
    if let block = context.currentBlock {
      guard case .input(var input) = block else {
        context.log
          .notice("Attempt to use TextField in a non-Input block: \(block)")
        context.closeBlock()
        return try render(in: context) // recurse
      }
      
      // Our non-empty element in API hack
      guard input.containsDummyElement else { // element is taken already
        context.log
          .notice("Attempt to put multiple inputs in an Input block: \(block)")
        context.closeBlock()
        return try render(in: context) // recurse
      }
      
      let actionID  = context.currentActionID(for: self.actionID)
      input.element = .plainText(.init(
        actionID     : actionID,
        placeholder  : placeholder,
        initialValue : editableStringValue,
        multiline    : multiline,
        minLength    : minimumLength, maxLength: maximumLength
      ))
      
      if !title.isEmpty && input.label.isEmpty {
        input.label = title
      }
      context.currentBlock = .input(input)
      
      try takeValues(for: actionID, in: context)
    }
    else { // auto-embed in Input
      try Input(title, hint: nil, optional: false, content: { self })
          .render(in: context)
    }
  }
  
  private func takeValues(for id: Block.ActionID, in context: BlocksContext)
                 throws
  {
    guard case .takeValues(let values) = context.mode else { return }
    
    // TBD:  Maybe we should make the `value` Binding<Value> generic,
    //       instead of using a String. This would allow us to communicate
    //       non-string values much better.
    // Also: Error handling for formatters! This requires us to have a more
    //       specialized binding which has access to the context? Maybe not.
    guard let value = values.valueForActionID(id) else {
      // This even happens in view submissions if a textfield is empty.
      context.log.trace("missing form value for \(id.id) (can be OK!)")
      #if false // only for view submissions!
        self.value.setter("") // hm
      #endif
      return
    }
    
    context.log.trace("got value for '\(id.id)': \(value)")
    if formatter != nil { // if we have a formatter, we always use it
      let inputString = (value as? String) ?? String(describing: value) // hm
      try takeStringValue(inputString, for: id, in: context)
    }
    else if let typedValue = value as? Value {
      self.value.setter(typedValue)
    }
    else {
      let inputString = (value as? String) ?? String(describing: value) // hm
      try takeStringValue(inputString, for: id, in: context)
    }
  }

  private func takeStringValue(_ inputString: String, for id: Block.ActionID,
                               in context: BlocksContext)
                 throws
  {
    var blockID : BlockID? {
      if let block = context.currentBlock { return block.id }
      return context.blocks.last?.id
    }
    func registerDefaultError() {
      if let id = blockID {
        context.addError("Invalid Input", in: .globalID(id))
      }
    }
    
    guard let formatter = formatter else {
      context.log
        .info("failed to parse input \(inputString) to: \(Value.self)")
      return registerDefaultError()
    }
    
    do {
      let value = try formatter.parseValue(inputString, of: Value.self)
      self.value.setter(value)
    }
    catch let error as FormatterError {
      switch error {
        case .formatError(.some(let message)):
          context.log
            .info("failed to format input \(inputString) to: \(Value.self)")
          if let id = blockID {
            context.addError(message, in: .globalID(id))
          }
        case .cannotConvertToFinalType(let value, let type):
          context.log
            .info("failed to format input \(value) to final: \(type)")
          return registerDefaultError()
        default:
          context.log
            .info("failed to format input \(inputString) to: \(Value.self)")
          return registerDefaultError()
      }
    }
    catch {
      context.log
        .info("failed to format input \(inputString) to: \(Value.self)")
      return registerDefaultError()
    }
  }
}
