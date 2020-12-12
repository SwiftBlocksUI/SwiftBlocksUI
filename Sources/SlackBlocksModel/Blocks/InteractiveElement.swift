//
//  InteractiveElement.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {
   
  /**
   * An interactive element (used within `Actions`).
   */
  enum InteractiveElement: Encodable {
    
    case button            (Button)
    case datePicker        (DatePicker)
    case overflowMenu      (Overflow)
    
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


// MARK: - Description

extension Block.InteractiveElement: CustomStringConvertible {
  
  @inlinable
  public var description: String {
    switch self {
      case .button            (let o): return o.description
      case .datePicker        (let o): return o.description
      case .overflowMenu      (let o): return o.description
  
      case .channelSelect     (let o): return o.description
      case .conversationSelect(let o): return o.description
      case .externalSelect    (let o): return o.description
      case .staticSelect      (let o): return o.description
      case .userSelect        (let o): return o.description
  
      case .checkboxes        (let o): return o.description
    }
  }
}
