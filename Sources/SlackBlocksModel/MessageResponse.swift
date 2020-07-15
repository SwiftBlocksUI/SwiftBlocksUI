//
//  StringID.swift
//  MessageResponse
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public struct MessageResponse: Encodable {
  // TODO: make this a generic message with all the supported stuff?
  //       make it a class and preserve the JSON?
  // Should _wrap_ a Message and annotate the extra fields.

  public enum ResponseType: String, Codable { // TODO: better name
    case inConversation = "in_channel"
    case userOnly       = "ephemeral"
  }

  public let responseType    : ResponseType?
  public let replaceOriginal : Bool
  public let text            : String
  public let blocks          : [ Block ]
  
  public init(responseType    : ResponseType? = nil,
              replaceOriginal : Bool          = false,
              text            : String        = "",
              blocks          : [ Block ]     = [])
  {
    self.responseType    = responseType
    self.replaceOriginal = replaceOriginal
    
    if text.isEmpty && !blocks.isEmpty {
      let maxRenderedLength = 4000
      let rendered = blocks.blocksMarkdownString
      if rendered.count > maxRenderedLength {
        let sub = rendered.dropLast()
        self.text = sub + "…"
      }
      else {
        self.text = rendered
      }
    }
    else {
      self.text = text
    }
    self.blocks = blocks
  }

  enum CodingKeys: String, CodingKey {
    case responseType    = "response_type"
    case replaceOriginal = "replace_original"
    case text, blocks
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    if let responseType = responseType {
      try container.encode(responseType, forKey: .responseType)
    }
    try container.encode(text,         forKey: .text)
    try container.encode(blocks,       forKey: .blocks)

    // Yes, we also need to send `false`, otherwise Slack deletes the sending
    // message in some contexts (i.e. require for `push` in message block
    // actions).
    try container.encode(replaceOriginal, forKey: .replaceOriginal)
  }
}
