//
//  Section.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * A section block.
   *
   * A section block can be composed of those things:
   * - a main Text (max 3k characters)
   * - field Texts (2 column layout, max 10 fields, max 2k chars per field)
   * - accessory (an accessory element shown in the upper right, for example
   *   a date picker)
   *
   * vertically stacked paragraphs.
   */
  struct Section: Encodable {
    
    public static let validInSurfaces : [ BlockSurfaceSet ]
                                      = [ .modals, .messages, .homeTabs ]

    public var id        : BlockID
    public var text      : Text
    public var fields    : [ Text ]
    public var accessory : Accessory?

    public init(id: BlockID, text: Text, fields: [ Text ] = [],
                accessory: Accessory? = nil)
    {
      self.id        = id
      self.text      = text
      self.fields    = fields
      self.accessory = accessory
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case id = "block_id"
      case type, text, fields, accessory
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("section", forKey: .type)
      try container.encode(id,        forKey: .id)
      try container.encode(text,      forKey: .text)
      if !fields.isEmpty { try container.encode(fields,  forKey: .fields) }
      if let accessory = accessory {
        try container.encode(accessory, forKey: .accessory)
      }
    }
  }
  
  /**
   * An interactive element within a Section. Shown at the upper right.
   *
   * NOTE: PlainText Input's are indeed invalid here!
   */
  enum Accessory: Encodable {
    
    case button            (Button)
    case datePicker        (DatePicker)
    case overflowMenu      (Overflow)
    case image             (ImageElement)
    
    case channelSelect     (MultiChannelsSelect)
    case conversationSelect(MultiConversationsSelect)
    case externalSelect    (MultiExternalSelect)
    case staticSelect      (MultiStaticSelect)
    case userSelect        (MultiUsersSelect)

    case checkboxes        (Checkboxes)

    public func encode(to encoder: Encoder) throws {
      switch self {
        case .button            (let element): try element.encode(to: encoder)
        case .datePicker        (let element): try element.encode(to: encoder)
        case .overflowMenu      (let element): try element.encode(to: encoder)
        case .image             (let element): try element.encode(to: encoder)
        case .channelSelect     (let element): try element.encode(to: encoder)
        case .conversationSelect(let element): try element.encode(to: encoder)
        case .externalSelect    (let element): try element.encode(to: encoder)
        case .staticSelect      (let element): try element.encode(to: encoder)
        case .userSelect        (let element): try element.encode(to: encoder)
        case .checkboxes        (let element): try element.encode(to: encoder)
      }
    }
  }
}


// MARK: - Markdown

public extension Block.Section {

  /// Render Section as Markdown (as well as possible)
  @inlinable
  var blocksMarkdownString : String {
    var ms = text.blocksMarkdownString
    
    if !fields.isEmpty {
      if !ms.hasSuffix("\n") { ms += "\n" }
      for field in fields {
        ms += "\n"
        ms += field.blocksMarkdownString
      }
    }
    return ms
  }
}


// MARK: - Description

extension Block.Section: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<Section[\(id.id)]:"
    if !text.isEmpty     { ms += " " + text.description }
    if !fields.isEmpty   { ms += " fields=\(fields)"    }
    if let v = accessory { ms += " accessory=\(v)"      }
    ms += ">"
    return ms
  }
}
