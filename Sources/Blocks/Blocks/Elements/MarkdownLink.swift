//
//  MarkdownLink.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import struct SlackBlocksModel.UserID
import struct SlackBlocksModel.ConversationID
import struct SlackBlocksModel.ChannelID

public extension Markdown {

  @inlinable
  init(user id: String, fallback: String? = nil) {
    assert(id.hasPrefix("U") || id.hasPrefix("B"),
           "doesn't look like a user ID: \(id)")
    if let fallback = fallback?.stringByEscapingFallbackMarkdown() {
      self.init("<@\(id)|\(fallback)>")
    }
    else {
      self.init("<@\(id)>")
    }
  }
  
  @inlinable
  init(_ id: UserID, fallback: String? = nil) {
    self.init(user: id.id, fallback: fallback)
  }
}

public extension Markdown {

  @inlinable
  init(conversation id: String, fallback: String? = nil) {
    assert(!id.hasPrefix("U") && !id.hasPrefix("B"),
           "doesn't look like a conversation ID: \(id)")
    if let fallback = fallback?.stringByEscapingFallbackMarkdown() {
      self.init("<#\(id)|\(fallback)>")
    }
    else {
      self.init("<#\(id)>")
    }
  }
  
  @inlinable
  init(_ id: ConversationID, fallback: String? = nil) {
    self.init(conversation: id.id, fallback: fallback)
  }
  @inlinable
  init(_ id: ChannelID, fallback: String? = nil) {
    self.init(conversation: id.id, fallback: fallback)
  }
}

public extension Markdown {

  @inlinable
  init(link url: URL, title: String? = nil) {
    // TBD: escaping
    let s = url.absoluteString
    assert(!s.contains("<") && !s.contains(">") && !s.contains("|"))
    if let title = title?.stringByEscapingFallbackMarkdown() {
      assert(!title.contains(">"))
      self.init("<\(s)|\(title)>")
    }
    else {
      self.init("<\(s)>")
    }
  }
}


// MARK: - Link Modifiers

public extension Markdown {
  
  @inlinable
  func link(to url: URL?) -> Markdown {
    guard let url = url else { return Markdown(slackMarkdownString) }
    return Markdown(link: url, title: slackMarkdownString)
  }

  @inlinable
  func link(to userID: UserID) -> Markdown {
    return Markdown(userID, fallback: slackMarkdownString)
  }
  
  @inlinable
  func link(to conversationID: ConversationID) -> Markdown {
    return Markdown(conversationID, fallback: slackMarkdownString)
  }
  
  @inlinable
  func link(to channelID: ChannelID) -> Markdown {
    return Markdown(channelID, fallback: slackMarkdownString)
  }
}

public extension Text {
  
  @inlinable
  func link(to url: URL?) -> Markdown {
    guard let url = url else { return Markdown(slackMarkdownString) }
    return Markdown(link: url, title: slackMarkdownString)
  }

  @inlinable
  func link(to userID: UserID) -> Markdown {
    return Markdown(userID, fallback: slackMarkdownString)
  }
  
  @inlinable
  func link(to conversationID: ConversationID) -> Markdown {
    return Markdown(conversationID, fallback: slackMarkdownString)
  }
  
  @inlinable
  func link(to channelID: ChannelID) -> Markdown {
    return Markdown(channelID, fallback: slackMarkdownString)
  }
}
