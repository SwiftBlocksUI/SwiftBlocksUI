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
