//
//  CheckboxGroup.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block

public typealias Checkboxes = CheckboxGroup

/**
 * Blocks to group a set of `Checkbox`es. The group can have a title which
 * is displayed above in bold.
 *
 * At the JSON API level this is very similar to a `Picker`, but the semantics
 * in BlocksUI are different.
 *
 * Checkout `Checkbox` for more information.
 * 
 * Important: Modal / Hometab only (within Views), not in messages!
 *
 * Example:
 *
 *     CheckboxGroup("Please select desirable restaurants:") {
 *       Checkbox("Café Macs",   isOn: $restaurants.macs)
 *       Checkbox("Chez TJ",     isOn: $restaurants.chez)
 *       Checkbox("Alexander's", isOn: $restaurants.alex)
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#checkboxes
 */
public struct CheckboxGroup<Content: Blocks>: Blocks {

  public typealias Body = Never

  @usableFromInline let actionID : ActionIDStyle
  @usableFromInline let title    : String // the (Input) label
  @usableFromInline let required : Bool
  @usableFromInline let action   : Action?
  @usableFromInline let content  : Content

  public init(actionID : ActionIDStyle = .auto,
              _  title : String        = "",
              required : Bool          = false,
              action   : Action?       = nil,
              @BlocksBuilder content: () -> Content)
  {
    self.actionID = actionID
    self.title    = title
    self.required = required
    self.action   = action
    self.content  = content()
  }
}
