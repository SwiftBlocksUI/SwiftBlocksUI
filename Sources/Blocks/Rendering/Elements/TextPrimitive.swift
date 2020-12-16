//
//  TextPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Logging.Logger
import enum   SlackBlocksModel.Block

extension Text {
  
  var blocksMarkdown : String {
    if isStyled { return runs.lazy.map { $0.asTargetRun }.blocksMarkdownString }
    else { return contentString }
  }
}

extension Text: BlocksPrimitive {
  
  enum TextRenderingError: Swift.Error {
    case internalInconsistency
  }
  
  public func render(in context: BlocksContext) throws {
    guard let block = context.currentBlock else {
      return try RichText { Paragraph(content: { self }) }
                   .render(in: context)
    }
    
    // All this is a little messy, but we want to render Text differently
    // depending on the target container.
    // Also: Presumably lot's of CoW
    switch block {
      case .divider:
        assertionFailure("open divider block, should never happen")
        context.closeBlock()
        return try render(in: context)
        
      case .richText : return try renderIntoRichText  (in: context)
      case .section  : return try renderIntoSection   (in: context)
      case .actions  : return try renderIntoActions   (in: context)
      case .image    : return try renderIntoImageBlock(in: context)
      case .context  : return try renderIntoContext   (in: context)
      case .input    : return try renderIntoInput   (in: context)
    }
  }

  private func renderIntoInput(in context: BlocksContext) throws {
    guard case .input(let input) = context.currentBlock else {
      assertionFailure("expected input block, got \(context)")
      throw TextRenderingError.internalInconsistency
    }
    
    guard !input.containsDummyElement else {
      // I guess we could use a leading Text as the Input hint?
      assertionFailure("unexpected Input nesting: \(context)")
      context.log.error("attempt to embed Text in Input: \(context)")
      return
    }
    
    guard case .staticSelect = input.element else {
      assertionFailure("unexpected Input nesting: \(context)")
      return context.log.error(
        "attempt to embed \(self) in \(input.element): \(context)")
    }
    
    try renderAsOption(in: context)
  }

  private func renderIntoActions(in context: BlocksContext) throws {
    guard case .actions(var actions) = context.currentBlock else {
      assertionFailure("expected actions block, got \(context)")
      throw TextRenderingError.internalInconsistency
    }
    
    switch context.level2Nesting {
      case .none: // Link in Actions becomes a Button
        context.log.error("attempt to render text into top-level Actions")
        return
      case .field, .accessory, .level2:
        assertionFailure("unexpected Actions nesting: \(context)")
        context.log.error("unexpected Actions nesting: \(context)")
        return

      case .picker:
        guard case .staticSelect = actions.elements.last else {
          context.log.error(
            "unexpected Actions nesting (expected static select Picker)")
          return
        }
        try renderAsOption(in: context)

      case .button:
        guard case .button(var button) = actions.elements.last else {
          assertionFailure("button nesting, but no button available?!")
          context.log.error("unexpected Actions nesting: \(context)")
          return
        }
        actions.elements.removeLast()
        
        button.text += contentString
        actions.elements.append(.button(button))
        context.currentBlock = .actions(actions)
    }
  }

  private func renderIntoContext(in context: BlocksContext) throws {
    guard case .context(var ctxBlock) = context.currentBlock else {
      assertionFailure("expected context block, got \(context)")
      throw TextRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    ctxBlock.elements.append(.text(
      isStyled ? .init(slackMarkdownString, type: .markdown(verbatim: false))
               : .init(contentString,       type: .plain(encodeEmoji: false))
    ))
    context.currentBlock = .context(ctxBlock)
  }

  private func renderIntoImageBlock(in context: BlocksContext) throws {
    guard case .image(var image) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw TextRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    if image.alt.isEmpty { // first Text goes into `alt` if that is empty
      image.alt = contentString
    }
    else { // alt is not empty, add to title
      if let title = image.title { image.title = title + contentString }
      else                       { image.title = contentString }
    }
    context.currentBlock = .image(image)
  }

  private func renderIntoSection(in context: BlocksContext) throws {
    guard case .section(var section) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw TextRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    defer { context.currentBlock = .section(section) }
    
    switch context.level2Nesting {
    
      case .none:
        if isStyled { section.text.appendMarkdown(blocksMarkdown) }
        else        { section.text.append        (contentString)  }
        
      case .level2, .button, .picker:
        assertionFailure("unexpected section nesting: \(context)")
      
      case .accessory:
        if let accessory = section.accessory {
          switch accessory {
            case .button(var button):
              section.accessory = nil
              button.text += contentString
              section.accessory = .button(button)
              
            case .image(var image):
              section.accessory = nil
              image.alt += contentString
              section.accessory = .image(image)
              
            case .staticSelect:
              return try renderAsOption(in: context)
            case .checkboxes:
              return try renderAsCheckbox(in: context)

            case .datePicker, .timePicker, .overflowMenu,
                 .channelSelect, .conversationSelect, .externalSelect,
                 .userSelect:
              // Could be placeholder, but that should be done in a more
              // explicit way I think. Not Text automagically becoming the
              // placeholder.
              context.log.error(
                "attempt to add text to unsupported accessory \(accessory)")
          }
        }
        else {
          context.log.error("attempt to add text to missing accessory")
          assertionFailure("level2 is accessory, but there is none?!")
        }
      
      case .field:
        var fieldText = section.fields.isEmpty
                      ? Block.Text("")
                      : section.fields.removeLast()
        
        if isStyled { fieldText.appendMarkdown(blocksMarkdown) }
        else        { fieldText.append        (contentString)  }
        
        section.fields.append(fieldText)
    }
  }

  private func renderIntoRichText(in context: BlocksContext) throws {
    guard case .richText(var richText) = context.currentBlock else {
      assertionFailure("expected richtext block, got \(context)")
      throw TextRenderingError.internalInconsistency
    }
    
    guard case .level2 = context.level2Nesting,
          !richText.elements.isEmpty else
    {
      return try Paragraph(content: { self }).render(in: context)
    }

    context.currentBlock = nil
    richText.append(self.runs.lazy.map { $0.asTargetRun })
    context.currentBlock = .richText(richText)
  }
  
  private var asBlockText: Block.Text {
    var text  = Block.Text("")
    if isStyled { text.appendMarkdown(blocksMarkdown) }
    else        { text.append        (contentString)  }
    return text
  }

  private func renderAsOption(in context: BlocksContext) throws {
    let text   = asBlockText
    let option = Option(title: text)
    
    if context.pendingTag == nil {
      context.pendingTag = text.value; defer { context.pendingTag = nil }
      return try option.render(in: context)
    }
    else {
      return try option.render(in: context)
    }
  }

  private func renderAsCheckbox(in context: BlocksContext) throws {
    let text     = asBlockText
    let checkbox = Checkbox(title: text)
    
    if context.pendingTag == nil {
      context.pendingTag = text.value; defer { context.pendingTag = nil }
      return try checkbox.render(in: context)
    }
    else {
      return try checkbox.render(in: context)
    }
  }
}
