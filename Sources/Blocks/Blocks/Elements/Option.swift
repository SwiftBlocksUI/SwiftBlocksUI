//
//  Option.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block

/**
 * Blocks to generate a single option for a `Picker`.
 *
 * Options do not have to be provided explicitly, one can also use `Link`s
 * or `Text`s as options within a Picker.
 *
 * Checkout `Picker` for more information.
 *
 * Example:
 *
 *     Picker("Importance", selection: $importance,
 *            placeholder: "Select importance")
 *     {
 *         Option("High 💎💎✨").tag("high")
 *         Option("Medium 💎")  .tag("medium")
 *         Option("Low ⚪️")     .tag("low")
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#multi_select
 */
public struct Option: Blocks {
  // Could be enhanced to support nested Text/Links

  public typealias Body = Never
  
  public enum OptionIDStyle {
    case auto
    case elementID
    case value(String)
  }
  
  @usableFromInline var optionID : OptionIDStyle
  @usableFromInline let title    : Block.Text
  @usableFromInline var infoText : String?
  @usableFromInline let url      : URL?
  
  @inlinable
  init(optionID : OptionIDStyle = .auto,
       title    : Block.Text,
       infoText : String?       = nil,
       url      : URL?          = nil)
  {
    self.optionID = optionID
    self.title    = title
    self.infoText = infoText
    self.url      = url
  }
}

extension Option {
  
  @inlinable
  public init<S>(optionID : OptionIDStyle = .auto,
                 _  title : S,
                 infoText : String? = nil, url: URL? = nil)
           where S: StringProtocol
  {
    self.init(optionID : optionID, title: .init(String(title)),
              infoText : infoText, url: url)
  }
}


// MARK: - Direct Modifiers

public extension Option {

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
