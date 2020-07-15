//
//  ModelPicker.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.UserID
import struct SlackBlocksModel.ChannelID
import struct SlackBlocksModel.ConversationID

/// Pickers which do not have content
public protocol NoContentPickerSelectionValue {}

extension UserID         : NoContentPickerSelectionValue {}
extension ChannelID      : NoContentPickerSelectionValue {}
extension ConversationID : NoContentPickerSelectionValue {}

public typealias UsersPicker         = Picker<Set<UserID>,         Never>
public typealias ChannelsPicker      = Picker<Set<ChannelID>,      Never>
public typealias ConversationsPicker = Picker<Set<ConversationID>, Never>
public typealias UserPicker          = Picker<UserID?,             Never>
public typealias ChannelPicker       = Picker<ChannelID?,          Never>
public typealias ConversationPicker  = Picker<ConversationID?,     Never>

public extension Picker
         where Selection.SelectionValue : NoContentPickerSelectionValue,
               Content == Never
{
 
  /**
   * Creates a user, channel or conversation picker.
   *
   * Docs:
   * - https://api.slack.com/reference/block-kit/block-elements#channel_multi_select
   * - https://api.slack.com/reference/block-kit/block-elements#conversation_multi_select
   * - https://api.slack.com/reference/block-kit/block-elements#users_multi_select
   */
  @inlinable
  init<S: StringProtocol>(_ title           : S,
                          selection         : Binding<Selection>,
                          maxSelectionCount : Int?    = nil,
                          placeholder       : String? = nil)
  {
    self.init(actionID: .auto, title, selection: selection,
              placeholder: placeholder, maxSelectionCount: maxSelectionCount,
              minQueryLength: nil, action: nil, content: nil)
  }
  
  @inlinable
  init<S: StringProtocol>(_ title           : S,
                          selection         : Binding<Selection>,
                          maxSelectionCount : Int?    = nil,
                          placeholder       : String? = nil,
                          action            : @escaping Action)
  {
    self.init(actionID: .auto, title, selection: selection,
              placeholder: placeholder, maxSelectionCount: maxSelectionCount,
              minQueryLength: nil, action: action, content: nil)
  }
}
