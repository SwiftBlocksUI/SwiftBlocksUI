//
//  RichTextPrimitives.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

extension RichText: BlocksPrimitive {

  typealias APIBlock = Block.RichText

  public func render(in context: BlocksContext) throws {
    context.startBlock(.richText(.init(id: context.blockID(for: self),
                                       elements: [])))
    defer { context.closeBlock() }
    
    try context.render(content)
  }
}

extension BlocksContext {
  
  func renderInRichTextElement<B>(_ element: Block.RichTextElement, content: B)
         throws
         where B: Blocks
  {
    guard let block = currentBlock else {
      startBlock(.richText(.init(id: currentBlockID(for: .auto), elements: [])))
      defer { closeBlock() }
      
      try renderInRichTextElement(element, content: content)
      return
    }
      
    switch block {
      case .richText(var richText):
        startLevelTwo(.level2); defer { endLevelTwo() }
        currentBlock = nil // CoW ARC
        richText.elements.append(element)
        currentBlock = .richText(richText)
        
        try render(content)

      case .section(var section):
        currentBlock = nil // CoW ARC
        
        switch element {
          case .section(let runs):
            assert(runs.isEmpty)
            section.text.startParagraph()
            section.text.appendMarkdown(runs.blocksMarkdownString) // empty
            currentBlock = .section(section)
            try render(content)
            
          case .quote(let runs):
            assert(runs.isEmpty)
            section.text.beginOnNewline()
            section.text.appendQuoted(runs.blocksMarkdownString) // empty
            let prefixText = section.text
            section.text.value = ""
            currentBlock = .section(section)
            
            try render(content)
            if case .section(var section) = currentBlock {
              let textToQuote = section.text
              section.text = prefixText
              section.text.appendQuoted(textToQuote.value)
              section.text.beginOnNewline()
              currentBlock = .section(section)
            }
            else {
              assertionFailure("unexpected section setup \(self)")
            }

          case .preformatted(let code):
            assert(code.isEmpty)
            let start = code.hasPrefix("\n") ? "```"   : "```\n"
            let end   = code.hasSuffix("\n") ? "```\n" : "\n```\n"
            section.text.appendMarkdown(start + code)
            currentBlock = .section(section)
            
            try render(content)
            
            if case .section(var section) = currentBlock {
              section.text.appendMarkdown(end)
              currentBlock = .section(section)
            }
        }

      default:
        closeBlock()
        try renderInRichTextElement(element, content: content)
    }
  }
}

extension Preformatted: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    try context.renderInRichTextElement(.preformatted(""), content: content)
  }
}
extension Paragraph: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    try context.renderInRichTextElement(.section([]), content: content)
  }
}
extension Quote: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    try context.renderInRichTextElement(.quote([]), content: content)
  }
}
