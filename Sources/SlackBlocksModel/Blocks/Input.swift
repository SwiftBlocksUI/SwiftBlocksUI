//
//  Input.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  struct Input: Encodable {
    public static let validInSurfaces = BlockSurfaceSet.modals
    
    public enum Element: Encodable, CustomStringConvertible {
      
      case plainText         (PlainTextInput)
      case datePicker        (DatePicker)

      case channelSelect     (MultiChannelsSelect)
      case conversationSelect(MultiConversationsSelect)
      case externalSelect    (MultiExternalSelect)
      case staticSelect      (MultiStaticSelect)
      case userSelect        (MultiUsersSelect)

      case checkboxes        (Checkboxes)

      public func encode(to encoder: Encoder) throws {
        switch self {
          case .plainText         (let element): try element.encode(to: encoder)
          case .datePicker        (let element): try element.encode(to: encoder)
          case .channelSelect     (let element): try element.encode(to: encoder)
          case .conversationSelect(let element): try element.encode(to: encoder)
          case .externalSelect    (let element): try element.encode(to: encoder)
          case .staticSelect      (let element): try element.encode(to: encoder)
          case .userSelect        (let element): try element.encode(to: encoder)
          case .checkboxes        (let element): try element.encode(to: encoder)
        }
      }
      
      public var description : String {
        switch self {
          case .plainText         (let element): return "\(element)"
          case .datePicker        (let element): return "\(element)"
          case .channelSelect     (let element): return "\(element)"
          case .conversationSelect(let element): return "\(element)"
          case .externalSelect    (let element): return "\(element)"
          case .staticSelect      (let element): return "\(element)"
          case .userSelect        (let element): return "\(element)"
          case .checkboxes        (let element): return "\(element)"
        }
      }
    }

    public var id       : BlockID
    public var label    : String  // max 2k characters
    public var hint     : String? // max 2k characters
    public var optional : Bool
    public var element  : Element
    
    public init(id: BlockID, label: String, hint: String? = nil,
                optional: Bool = false, element: Element)
    {
      self.id       = id
      self.label    = label
      self.hint     = hint
      self.optional = optional
      self.element  = element
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case id  = "block_id"
      case type, label, hint, optional, element
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("input",     forKey: .type)
      try container.encode(id,          forKey: .id)
      try container.encode(Text(label), forKey: .label)
      try container.encode(element,     forKey: .element)
      if let v = hint { try container.encode(Text(v), forKey: .hint)     }
      if optional     { try container.encode(true,    forKey: .optional) }
    }
  }
}

extension Block.Input: CustomStringConvertible {
  
  public var description : String {
    var ms = "<Input[\(id.id)]:"
    if !label.isEmpty           { ms += " '\(label)'" }
    if let v = hint, !v.isEmpty { ms += " hint" }
    if optional                 { ms += " optional" }
    ms += " \(element)"
    ms += ">"
    return ms
  }
}

public extension Block.Input {
  
  @inlinable
  var blocksMarkdownString : String {
    return "[Input \(label) not visible on this client]"
  }
}
