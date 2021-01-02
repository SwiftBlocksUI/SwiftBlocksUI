//
//  LinkPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block

extension Link: MarkdownTextPrimitive {
  var contentString : String { return title }
}

extension Link: BlocksPrimitive {
  
  // TODO: Check whether we can reduce the duping w/ `Text`. It is a little
  //       different, but maybe we can somehow share the context setup.
  
  enum LinkRenderingError: Swift.Error {
    case internalInconsistency
  }

  func renderIntoHeader(in context: BlocksContext) throws {
    // This has special URL behaviour
    guard case .header(var header) = context.currentBlock else {
      assertionFailure("expected header block, got \(context)")
      throw MarkdownTextPrimitiveRenderingError.internalInconsistency
    }

    context.currentBlock = nil
    if title.isEmpty {
      header.text += destination.absoluteString
    }
    else {
      header.text += "[\(title)](\(destination.absoluteString))"
    }
    context.currentBlock = .header(header)
  }
  
  func renderIntoActions(in context: BlocksContext) throws {
    // This has special URL behaviour
    
    guard case .actions(var actions) = context.currentBlock else {
      assertionFailure("expected actions block, got \(context)")
      throw LinkRenderingError.internalInconsistency
    }
    
    switch context.level2Nesting {
      case .none: // Link in Actions becomes a Button
        try Button(actionID : .auto,
                   title    : title, style: .none, value: nil,
                   content  : Text(title), url: destination, action: nil)
          .render(in: context)
        
      case .field, .accessory, .level2:
        assertionFailure("unexpected Actions nesting: \(context)")
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
          context.endLevelTwo()
          return try renderIntoActions(in: context) // hits the .none branch
        }
        actions.elements.removeLast()
        
        if button.url == nil {
          button.url = destination
          if button.text.isEmpty { button.text = title } // TBD
        }
        else {
          context.log.error(
            "attempt to add link to button w/ link \(button)")
        }

        actions.elements.append(.button(button))
        context.currentBlock = .actions(actions)
    }
  }

  func renderIntoSection(in context: BlocksContext) throws {
    // Special button behaviour
    
    guard case .section(var section) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw LinkRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    defer { context.currentBlock = .section(section) }
    
    switch context.level2Nesting {
      case .none:
        section.text.appendMarkdown(slackMarkdownString)
        
      case .level2, .button, .picker:
        assertionFailure("unexpected section nesting: \(context)")
        section.text.appendMarkdown(slackMarkdownString)
      
      case .accessory:
        if let accessory = section.accessory {
          switch accessory {
            case .button(var button):
              if button.url == nil {
                section.accessory = nil
                button.url = destination
                if button.text.isEmpty { button.text = title } // TBD
                section.accessory = .button(button)
              }
              else {
                context.log.error(
                  "attempt to add link to button w/ link \(accessory)")
              }
              
            case .staticSelect:
              return try renderAsOption(in: context)
            case .checkboxes:
              return try renderAsCheckbox(in: context)

            case .datePicker, .timePicker, .overflowMenu, .image,
                 .channelSelect, .conversationSelect, .externalSelect,
                 .userSelect:
              context.log.error(
                "attempt to add link to unsupported accessory \(accessory)")
          }
        }
        else { // Links in accessory are rendered as buttons
          section.accessory = .button(.init(
            actionID: context.currentActionID(for: .auto),
            text: title, url: destination)
          )
        }
      
      case .field:
        var fieldText = section.fields.isEmpty
                      ? Block.Text("", type: .markdown(verbatim: false))
                      : section.fields.removeLast()
        fieldText.appendMarkdown(slackMarkdownString)
        section.fields.append(fieldText)
    }
  }

  func renderIntoImageBlock(in context: BlocksContext) throws {
    // A Link doesn't make sense in an image, right? There is the URL,
    // but that is non-optional?
    context.closeBlock()
    return try render(in: context)
  }
  
  func renderIntoRichText(in context: BlocksContext) throws {
    guard case .richText(var richText) = context.currentBlock else {
      assertionFailure("expected richtext block, got \(context)")
      throw LinkRenderingError.internalInconsistency
    }
    
    guard case .level2 = context.level2Nesting,
          !richText.elements.isEmpty else
    {
      return try Paragraph(content: { self }).render(in: context)
    }
    
    context.currentBlock = nil
    richText.append(CollectionOfOne(.link(destination, text: title)))
    context.currentBlock = .richText(richText)
  }

  var asBlockText: Block.Text {
    var text  = Block.Text("")
    if isStyled { text.appendMarkdown(style.markdownStyle(title)) }
    else        { text.append        (title)  }
    return text
  }

  func renderAsOption(in context: BlocksContext) throws {
    let option = Option(title: asBlockText, url: destination)
    if context.pendingTag == nil {
      // TBD: use URL as value? Probably makes sense.
      context.pendingTag = destination; defer { context.pendingTag = nil }
      try option.render(in: context)
    }
    else {
      try option.render(in: context)
    }
  }
  func renderAsCheckbox(in context: BlocksContext) throws {
    let checkbox = Checkbox(title: asBlockText, url: destination)
    if context.pendingTag == nil {
      // TBD: use URL as value? Probably makes sense.
      context.pendingTag = destination; defer { context.pendingTag = nil }
      try checkbox.render(in: context)
    }
    else {
      try checkbox.render(in: context)
    }
  }
}
