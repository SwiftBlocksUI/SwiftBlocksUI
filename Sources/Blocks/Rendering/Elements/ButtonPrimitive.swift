//
//  ButtonPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension Button: BlocksPrimitive {
  
  typealias APIBlock = Block.Button
  
  private func buildAPIButton(in context: BlocksContext) -> Block.Button {
    return Block.Button(
      actionID : context.currentActionID(for: actionID),
      text     : title,
      url      : url,
      value    : value,
      style    : style,
      confirm  : context.confirmationDialog
    )
  }

  private func afterBlockSetup(for actionID : Block.ActionID,
                               in   context : BlocksContext) throws {
    try context.invokeAction(action, for: self.actionID, id: actionID,
                             in: context)
    
    // TBD: Necessary in invoke/submit? Maybe, because it may affect the
    //      structure
    if let content = content { try context.render(content) }
  }
  
  public func render(in context: BlocksContext) throws {
    // TODO: split it up
    // valid in section (accessory) & actions
    
    if let block = context.currentBlock {
      if case .section(var section) = block,
         context.level2Nesting == .accessory,
         section.accessory == nil
      {
        let api = buildAPIButton(in: context)
        context.currentBlock = nil
        section.accessory    = .button(api)
        context.currentBlock = .section(section)
        try afterBlockSetup(for: api.actionID, in: context)
      }
      else if case .actions(var actions) = block {
        if context.level2Nesting != .none {
          context.log.warning(
            "Attempt to add nested Button to Actions, please fix the nesting!")
          context.endLevelTwo()
        }
        
        context.startLevelTwo(.button)
        defer { context.endLevelTwo() }
        
        let api = buildAPIButton(in: context)
        context.currentBlock = nil
        actions.elements.append(.button(api))
        context.currentBlock = .actions(actions)
        try afterBlockSetup(for: api.actionID, in: context)
      }
      else { // auto-open Actions
        try context.render(Actions(content: { return self }))
      }
    }
    else if case .actions = context.blocks.last {
      // If the last block was actions, add to it.
      context.log.warning(
        "Adding Button to last Actions block, please fix the nesting!")
      assert(context.currentBlock == nil)
      _ = context.reopenLastBlock()
      try render(in: context)
    }
    else { // there is no current block, and the last block is not an Actions
      assert(context.currentBlock == nil)
      
      // Auto-open Actions. Why? Because there has to be a current block with
      // the Button attached, so that nested elements can render into it.
      try context.render(Actions(content: { return self }))
      
      
      // Post process, generate Submit/Cancel for Views (imperfect)
      // This is kinda too late, e.g. the API Button already has an actionID
      // assigned.
      // But we also want to have the nested rendering.
      
      func isInactiveButton(_ button: Block.Button) -> Bool {
        // Hm, actionID is non-optional here
        return button.url      == nil
            && button.value    == nil
            && button.confirm  == nil
      }
      
      assert(context.currentBlock == nil)
      if var view = context.view,
         case .actions(let actions) = context.blocks.last,
         actions.elements.count == 1,
         case .button (let button) = actions.elements.first,
         button.style    != .none,
         isInactiveButton(button)
      {
        assert(actions.elements.count == 1)
        
        if button.style == .primary && (view.submitTitle?.isEmpty ?? true) {
          context.view = nil
          context.dropLastBlock()
          view.submitTitle = button.text
          context.view = view
        }
        else if button.style == .danger && (view.closeTitle?.isEmpty ?? true) {
          context.view = nil
          context.dropLastBlock()
          view.closeTitle = button.text
          context.view = view
        }
      }
    }
  }
}
