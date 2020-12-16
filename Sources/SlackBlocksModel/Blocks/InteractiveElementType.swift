//
//  InteractiveElementType.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {
  
  /**
   * All interactive element types. Not all may be available in all blocks!
   */
  enum InteractiveElementType: String, Codable {
    
    case button
    case datePicker              = "datepicker"
    case timePicker              = "timepicker"
    case overflowMenu            = "overflow"
    
    case staticSelect            = "static_select"
    case staticMultiSelect       = "multi_static_select"
    case externalSelect          = "external_select"
    case externalMultiSelect     = "multi_external_select"

    case channelSelect           = "channels_select"
    case channelMultiSelect      = "multi_channels_select"
    case conversationSelect      = "conversations_select"
    case conversationMultiSelect = "multi_conversations_select"
    
    case userSelect              = "users_select"
    case userMultiSelect         = "multi_users_select"
    
    case checkboxes              = "checkboxes"
    
    case plainTextInput          = "plain_text_input"
  }
}
