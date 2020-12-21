//
//  ImagePrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension Image: BlocksPrimitive {
  // Note: Slack Markdown (or RichText) cannot contain images. We render images
  //       as Links in those contexts.
  //       Update: Well, contained images seem to be rendered as image
  //               attachments now, with the `alt` text inline.
  
  typealias APIBlock = Block.ImageBlock

  enum ImageRenderingError: Swift.Error {
    case internalInconsistency
  }
  
  public func render(in context: BlocksContext) throws {
    guard let block = context.currentBlock else {
      /* create as an image block */
      context.startBlock(.image(.init(id    : context.blockID(for: self),
                                      url   : url,
                                      alt   : title,
                                      title : label)))
      context.closeBlock()
      return
    }
    
    // All this is a little messy, but we want to render Text differently
    // depending on the target container.
    // Also: Presumably lot's of CoW
    switch block {
      case .divider:
        assertionFailure("open divider block, should never happen")
        context.closeBlock()
        return try render(in: context)
        
      case .richText : return try renderIntoRichText(in: context)
      case .section  : return try renderIntoSection (in: context)
      case .context  : return try renderIntoContext (in: context)

      case .image, .actions, .input, .header:
        context.closeBlock()
        return try render(in: context)
    }
  }
  
  private func renderIntoContext(in context: BlocksContext) throws {
    guard case .context(var ctxBlock) = context.currentBlock else {
      assertionFailure("expected context block, got \(context)")
      throw ImageRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    ctxBlock.elements.append(.image(.init(url: url, alt: title)))
    context.currentBlock = .context(ctxBlock)
  }
  
  private func renderIntoSection(in context: BlocksContext) throws {
    guard case .section(var section) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw ImageRenderingError.internalInconsistency
    }
    
    context.currentBlock = nil
    switch context.level2Nesting {
      case .none:
        if section.accessory == nil { // put into accessory if available
          section.accessory = .image(.init(url: url, alt: title))
        }
        else {
          section.text.appendMarkdown(" " + slackMarkdownString + " ")
        }
        
      case .level2, .button, .picker:
        assertionFailure("unexpected section nesting: \(context)")
        section.text.appendMarkdown(slackMarkdownString)

      case .accessory:
        if let accessory = section.accessory {
          // No accessory can use an Image in a nested way? (Buttons cannot
          // contain images in BlockKit)
          context.log.warning(
            "Attempt to nest Image in another section accessory \(accessory)")
        }
        else {
          section.accessory = .image(.init(url: url, alt: title))
        }
      
      case .field: // TBD, currently title + label
        context.log.notice(
          "Using an Image within a Field won't show an image (but the title)")
        var fieldText = section.fields.isEmpty
                      ? Block.Text("", type: .markdown(verbatim: false))
                      : section.fields.removeLast()
        fieldText.append(title)
        if let l = label, !l.isEmpty {
          if !title.isEmpty { fieldText.append(" ") }
          fieldText.append(l)
        }
        section.fields.append(fieldText)
    }
    context.currentBlock = .section(section)
  }

  private func renderIntoRichText(in context: BlocksContext) throws {
    // TBD: maybe RichText _does_ support level-2 image elements?
    
    guard case .richText(var richText) = context.currentBlock else {
      assertionFailure("expected richtext block, got \(context)")
      throw ImageRenderingError.internalInconsistency
    }
    
    guard case .level2 = context.level2Nesting,
          !richText.elements.isEmpty else
    {
      return try Paragraph(content: { self }).render(in: context)
    }
    
    context.currentBlock = nil
    richText.append(CollectionOfOne(.link(url, text: title)))
    context.currentBlock = .richText(richText)
  }
}
