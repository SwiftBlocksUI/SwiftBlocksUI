//
//  TextPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Logging.Logger
import enum   SlackBlocksModel.Block

extension Text: MarkdownTextPrimitive {
  
  var blocksMarkdown : String {
    if isStyled { return runs.lazy.map { $0.asTargetRun }.blocksMarkdownString }
    else { return contentString }
  }
}

extension Text: BlocksPrimitive {
  
  enum TextRenderingError: Swift.Error {
    case internalInconsistency
  }

  func renderIntoContext(in context: BlocksContext) throws {
    guard case .context(var ctxBlock) = context.currentBlock else {
      assertionFailure("expected context block, got \(context)")
      throw MarkdownTextPrimitiveRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    ctxBlock.elements.append(.text(
      isStyled ? .init(slackMarkdownString, type: .markdown(verbatim: false))
               : .init(contentString,       type: .plain(encodeEmoji: false))
    ))
    context.currentBlock = .context(ctxBlock)
  }

  func renderIntoSection(in context: BlocksContext) throws {
    // This has different styling generation
    
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

  func renderIntoRichText(in context: BlocksContext) throws {
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
  
  var asBlockText: Block.Text {
    var text  = Block.Text("")
    if isStyled { text.appendMarkdown(blocksMarkdown) }
    else        { text.append        (contentString)  }
    return text
  }
}
