//
//  MarkdownTextPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

/**
 * A mixin to render various Markdown content elements into the various blocks.
 *
 * It is used by:
 * - `Text`
 * - `Markdown`
 * - `Link`
 */
protocol MarkdownTextPrimitive : Blocks, BlocksPrimitive {
    
  var  slackMarkdownString : String { get }
  var  blocksMarkdown      : String { get }
  var  contentString       : String { get }

  func render(in context: BlocksContext) throws
  
  func renderIntoInput     (in context: BlocksContext) throws
  func renderIntoActions   (in context: BlocksContext) throws
  func renderIntoImageBlock(in context: BlocksContext) throws
  func renderIntoContext   (in context: BlocksContext) throws
  func renderIntoSection   (in context: BlocksContext) throws
  func renderIntoRichText  (in context: BlocksContext) throws

  func renderAsOption      (in context: BlocksContext) throws
  func renderAsCheckbox    (in context: BlocksContext) throws
}

enum MarkdownTextPrimitiveRenderingError: Swift.Error {
  case internalInconsistency
}

extension MarkdownTextPrimitive {

  // Text overrides this, not sure it is really needed
  var blocksMarkdown: String { return slackMarkdownString  }

  /// Used in options and checkboxes. Styled element Blocks (like Text) may
  /// do this differently!
  var asBlockText: Block.Text {
    var text  = Block.Text("")
    text.appendMarkdown(blocksMarkdown)
    return text
  }
}

extension MarkdownTextPrimitive {
  
  public func render(in context: BlocksContext) throws {
    // This implements the BlocksPrimitive entry point in a more granular way
    
    guard let block = context.currentBlock else {
      return try RichText { Paragraph(content: { self }) }
                   .render(in: context)
    }
    
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
      case .input    : return try renderIntoInput     (in: context)
    }
  }
}

extension MarkdownTextPrimitive {

  func renderIntoInput(in context: BlocksContext) throws {
    guard case .input(let input) = context.currentBlock else {
      assertionFailure("expected input block, got \(context)")
      throw MarkdownTextPrimitiveRenderingError.internalInconsistency
    }
    
    guard !input.containsDummyElement else {
      // I guess we could use a leading Text as the Input hint?
      assertionFailure("unexpected Input nesting: \(context)")
      return context.log.error("attempt to embed Link in Input: \(context)")
    }
    
    guard case .staticSelect = input.element else {
      assertionFailure("unexpected Input nesting: \(context)")
      return context.log.error(
        "attempt to embed \(self) in \(input.element): \(context)")
    }

    try renderAsOption(in: context)
  }

  func renderIntoActions(in context: BlocksContext) throws {
    guard case .actions(var actions) = context.currentBlock else {
      assertionFailure("expected actions block, got \(context)")
      throw MarkdownTextPrimitiveRenderingError.internalInconsistency
    }
    
    switch context.level2Nesting {
      case .none:
        // Note: Link in Actions becomes a Button
        context.log.error("attempt to render Text into top-level Actions")
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
          context.log.error("unexpected Actions nesting: \(context)")
          assertionFailure("button nesting, but no button available?!")
          return
        }
        actions.elements.removeLast()

        if self is Markdown {
          context.log
            .warning("rendering Markdown into Button, use Text: \(context)")
        }
        button.text += contentString
        actions.elements.append(.button(button))
        context.currentBlock = .actions(actions)
    }
  }

  func renderIntoImageBlock(in context: BlocksContext) throws {
    guard case .image(var image) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw MarkdownTextPrimitiveRenderingError.internalInconsistency
    }
    
    if self is Markdown || self is Link {
      context.log.warning("rendering into Image, use Text: \(context) \(self)")
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

  func renderIntoContext(in context: BlocksContext) throws {
    guard case .context(var ctxBlock) = context.currentBlock else {
      assertionFailure("expected context block, got \(context)")
      throw MarkdownTextPrimitiveRenderingError.internalInconsistency
    }

    context.currentBlock = nil
    ctxBlock.elements.append(
      .text(.init(slackMarkdownString, type: .markdown(verbatim: false)))
    )
    context.currentBlock = .context(ctxBlock)
  }
  
  func renderIntoSection(in context: BlocksContext) throws {
    guard case .section(var section) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw MarkdownTextPrimitiveRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    defer { context.currentBlock = .section(section) }
    
    switch context.level2Nesting {
      case .none:
        section.text.appendMarkdown(blocksMarkdown)
        
      case .level2, .button, .picker:
        assertionFailure("unexpected section nesting: \(context)")
        section.text.appendMarkdown(slackMarkdownString)
      
      case .accessory:
        if let accessory = section.accessory {
          switch accessory {
            case .button(var button):
              section.accessory = nil
              context.log.warning(
                "rendering Markdown into accessory Button, use Text!")
              button.text += contentString
              section.accessory = .button(button)
              
            case .image(var image):
              section.accessory = nil
              context.log.warning(
                "rendering Markdown into accessory Image, use Text!")
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
        fieldText.appendMarkdown(blocksMarkdown)
        section.fields.append(fieldText)
    }
  }

  func renderIntoRichText(in context: BlocksContext) throws {
    context.log.warning("attempt to use \(self) in RichText: \(context)")
    return try Section { self }
                 .render(in: context)
  }


  func renderAsOption(in context: BlocksContext) throws {
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

  func renderAsCheckbox(in context: BlocksContext) throws {
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
