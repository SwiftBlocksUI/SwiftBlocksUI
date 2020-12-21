//
//  BlockTextAppends.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

internal extension Block.Text {
  
  /**
   * If the `Text` is still empty, this turns it into a plain text with
   * the given content.
   *
   * If the `Text` already has content, the `newString` is added to the
   * content (currently w/o escaping if it is Markdown already).
   */
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

  /**
   * If the `Text` is still empty, this turns it into a Markdown text with
   * the given content.
   *
   * If the `Text` already has content, the result is still a markdown `Text`,
   * but with the existing content prepended (currently w/o escaping if it was
   * plain content).
   */
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

  /**
   * Prepends each line of the given `text` with a `>`.
   * If the `text` didn't end in a newline, one will be added.
   */
  mutating func appendQuoted(_ text: String) {
    guard !text.isEmpty else { return }
    for line in text.lazy.split(separator: "\n") {
      appendMarkdown("> \(String(line))\n")
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
