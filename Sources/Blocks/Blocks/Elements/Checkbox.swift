//
//  Checkbox.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block

public typealias Toggle = Checkbox

/**
 * Blocks to generate a single `Checkbox`.
 *
 * Technically `Checkbox` elements generate API "options" just like `Picker`
 * `Option`'s.
 * But they have different semantics at the Blocks level, e.g. an explicit
 * binding (while the `Picker` itself maintains the selection.
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
 * Example targetting an OptionSet:
 *
 *     CheckboxGroup("Please select desirable restaurants:") {
 *       Checkbox("Café Macs",   selection: $restaurants, .macs)
 *       Checkbox("Chez TJ",     selection: $restaurants, .chez)
 *       Checkbox("Alexander's", selection: $restaurants, .alex)
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#checkboxes
 */
public struct Checkbox: Blocks {
  // Could be enhanced to support nested Text/Links (as "Labels")
  // TBD: maybe this could have an optional `Selection` binding?

  public typealias Body = Never
  
  public typealias CheckboxIDStyle = Option.OptionIDStyle
  
  @usableFromInline var optionID : CheckboxIDStyle
  @usableFromInline let title    : Block.Text
  @usableFromInline var infoText : String?
  @usableFromInline let url      : URL?
  @usableFromInline let isOn     : Binding<Bool>?

  @inlinable
  init(optionID : CheckboxIDStyle = .auto,
       title    : Block.Text,
       isOn     : Binding<Bool>?  = nil,
       infoText : String?         = nil,
       url      : URL?            = nil)
  {
    self.optionID = optionID
    self.title    = title
    self.infoText = infoText
    self.url      = url
    self.isOn     = isOn
  }
}

public extension Checkbox {
  @inlinable
  init(optionID : CheckboxIDStyle = .auto,
       _ title  : String,
       isOn     : Binding<Bool>?  = nil,
       infoText : String?         = nil,
       url      : URL?            = nil)
  {
    self.init(optionID: optionID, title: .init(title),
              isOn: isOn, infoText: infoText, url: url)
  }
}

public extension Checkbox {

  /**
   * Bind checkbox using a value stored in a Set (e.g. an OptionSet).
   *
   * Example:
   *
   *     CheckboxGroup("Please select desirable restaurants:") {
   *       Checkbox("Café Macs",   selection: $restaurants, .macs)
   *       Checkbox("Chez TJ",     selection: $restaurants, .chez)
   *       Checkbox("Alexander's", selection: $restaurants, .alex)
   *     }
   */
  @inlinable
  init<O: SetAlgebra>(optionID  : CheckboxIDStyle = .auto,
                      _ title   : String,
                      selection : Binding<O>,
                      _ value   : O.Element,
                      infoText  : String?         = nil,
                      url       : URL?            = nil)
  {
    // TODO: Make a variant where the group keeps the selection. But this
    //       can't be done using a simple Binding.
    
    let wrappedBinding = Binding<Bool>(
      getValue: {
        return selection.getter().contains(value)
      },
      setValue: { flag in
        var existing = selection.getter()
        if flag { existing.insert(value) }
        else    { existing.remove(value) }
        selection.setter(existing)
      }
    )
    self.init(optionID: optionID, title: .init(title),
              isOn: wrappedBinding, infoText: infoText, url: url)
  }
}

// MARK: - Direct Modifiers

public extension Checkbox {

  @inlinable
  func id(_ value: String) -> Self {
    var option = self
    option.optionID = .value(value)
    return option
  }
  
  @inlinable
  func infoText(_ text: String) -> Self {
    var option = self
    option.infoText = text
    return option
  }
}
