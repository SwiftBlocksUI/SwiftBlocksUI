//
//  Option.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {
  
  /**
   * An Option object:
   *
   * Docs: https://api.slack.com/reference/block-kit/composition-objects#option
   */
  struct Option: Encodable {
    
    public var text     : Text    // max 75 chars
    public var value    : String  // max 75 chars
    public var infoText : String? // max 75 chars, description
    public var url      : URL?    // max 3k chars
    
    public init(text: Text, value: String,
                infoText: String? = nil, url: URL? = nil)
    {
      self.text     = text
      self.value    = value
      self.infoText = infoText
      self.url      = url
    }
    
    // MARK: - Coding
    
    enum CodingKeys: String, CodingKey {
      case text, value, description, url
    }
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(text,  forKey: .text)
      try container.encode(value, forKey: .value)
      if let v = infoText {
        try container.encode(Text(v), forKey: .description)
      }
      if let v = url { try container.encode(v, forKey: .url) }
    }
  }
  
  /**
   * An OptionGroup object:
   *
   * Docs: https://api.slack.com/reference/block-kit/composition-objects#option_group
   */
  struct OptionGroup: Encodable {
    
    public let label   : String // max 85 chars
    public var options : [ Option ]
    
    public init(label: String, options: [ Option ]) {
      self.label   = label
      self.options = options
    }
    
    // MARK: - Coding
    
    enum CodingKeys: String, CodingKey {
      case label, options
    }
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(Text(label), forKey: .label)
      try container.encode(options,     forKey: .options)
    }
  }
}


// MARK: - Description

extension Block.Option: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<Option[\(value)]: \"\(text)\""
    if let v = infoText { ms += " info=\"\(v)\"" }
    if let v = url?.absoluteURL { ms += " \(v)"  }
    ms += ">"
    return ms
  }
}
