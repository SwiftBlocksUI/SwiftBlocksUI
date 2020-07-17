//
//  InputPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension Input: BlocksPrimitive {

  typealias APIBlock = Block.Input

  public func render(in context: BlocksContext) throws {
    if context.surface != .modal {
      if context.blocks.isEmpty && context.currentBlock == nil {
        // If this is the first block, make it modal and start a View.
        context.surface = .modal
        return try context.render(View { self })
      }
      else {
        context.log
          .notice("Attempt to use an Input in a non-modal surface!")
        
        // TBD: Makes sense?
        return try Section(content: { self.content }).render(in: context)
      }
    }
    else if context.view == nil { // auto start a View
      return try context.render(View { self })
    }
    
    // This is a little hacky, because the element in the API is required.
    // So we setup a fake plaintext element and use that as a placeholder.
    let blockID = context.blockID(for: self)
    context.startBlock(.input(.init(id       : blockID,
                                    label    : label, hint: hint,
                                    optional : optional,
                                    element  : .plainText(.emptyElement))))
    defer {
      if let block = context.currentBlock, case .input(let input) = block,
         input.containsDummyElement
      {
        context.log
          .notice("Blocks contains an empty Input, omitting \(block)")
        context.dropCurrentBlock()
      }
      else {
        if let block = context.currentBlock, case .input(var input) = block,
           input.label.isEmpty
        {
          assignDefaultLabel(to: &input)
          context.currentBlock = .input(input)
        }
        context.closeBlock()
      }
    }
    
    try context.render(content)
  }
  
  private func assignDefaultLabel(to input: inout Block.Input) {
    // FIXME: Do something sensible, e.g. check whether there is just one option
    //        inside and use the label of those, etc.
    input.label = "Input"
  }
}

extension Block.PlainTextInput { // hacky, but well
  static let dummyElementActionID : Block.ActionID = "$$DUMMY$$"
  fileprivate static let emptyElement =
    Block.PlainTextInput(actionID: dummyElementActionID)
}
extension Block.Input {
  
  var containsDummyElement: Bool {
    guard case .plainText(let plainText) = element else { return false }
    guard plainText.actionID == Block.PlainTextInput.dummyElementActionID else {
      return false
    }
    return true
  }
}
