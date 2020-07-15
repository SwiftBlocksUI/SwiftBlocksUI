//
//  RichTextAppends.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

internal extension Block.RichText {
  
  mutating func append(_ newString: String) {
    guard !newString.isEmpty else { return }
    
    if elements.isEmpty {
      elements.append(.section([ .text(newString, style: [])]))
      return
    }
    
    var element = elements.removeLast()
    
    switch element {
      
      case .section(var runs):
        runs.append(.text(newString, style: []))
        element = .section(runs)
      
      case .quote(var runs):
        runs.append(.text(newString, style: []))
        element = .quote(runs)
      
      case .preformatted(let string):
        element = .preformatted(string + newString)
    }
    
    elements.append(element)
  }

  mutating func append<S: Collection>(_ addRuns: S)
                  where S.Element == Block.RichTextElement.Run
  {
    if elements.isEmpty { elements.append(.section([])) }
    var element = elements.removeLast()
    
    switch element {
      
      case .section(var runs):
        runs.append(contentsOf: addRuns)
        element = .section(runs)
      
      case .quote(var runs):
        runs.append(contentsOf: addRuns)
        element = .quote(runs)
      
      case .preformatted(let string):
        element = .preformatted(string + addRuns.blocksMarkdownString)
    }
    
    elements.append(element)
  }
}
