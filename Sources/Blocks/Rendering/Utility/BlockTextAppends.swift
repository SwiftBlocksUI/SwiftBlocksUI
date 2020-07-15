//
//  BlockTextAppends.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

internal extension Block.Text {
  
  mutating func append(_ newString: String, encodeEmoji: Bool = false) {
    guard !newString.isEmpty else { return }
    if isEmpty {
      type  = .plain(encodeEmoji: encodeEmoji)
      value = newString
    }
    else { // a little fishy, would need to escape the markdown
      value += newString
    }
  }

  mutating func appendMarkdown(_ newString: String, verbatim: Bool = false) {
    guard !newString.isEmpty else { return }
    if isEmpty {
      type  = .markdown(verbatim: verbatim)
      value = newString
    }
    else {
      if case .markdown = type {}
      else { // a little fishy, would need to escape the existing markdown
        type  = .markdown(verbatim: verbatim)
      }
      self.value += newString
    }
  }
}

extension Block.Text {

  mutating func startParagraph() {
    guard !value.isEmpty && !value.hasSuffix("\n\n") else { return }
    value += value.hasSuffix("\n") ? "\n" : "\n\n"
  }

  mutating func beginOnNewline() {
    guard !value.isEmpty && !value.hasSuffix("\n") else { return }
    value += "\n"
  }

  mutating func appendQuoted(_ text: String) {
    guard !text.isEmpty else { return }
    for line in text.lazy.split(separator: "\n") {
      appendMarkdown("> \(line)\n")
    }
  }
}

extension Text.Run {
  
  var asTargetRun : Block.RichTextElement.Run {
    switch self {
      case .verbatim(let text)          : return .text(text, style: [])
      case .styled(let text, let style) : return .text(text, style: style)
    }
  }
}
