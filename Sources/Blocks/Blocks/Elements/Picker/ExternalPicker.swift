//
//  ExternalPicker.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

// MARK: - External DataSource Select List

public extension Picker where Content == Never {
  
  /**
   * Creates a picker which is driven driven by an external datasource (needs
   * to be configured in the Slack app config).
   *
   * Example:
   *
   *     Picker("Products", $selectedProduct, minQueryLength: 3)
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#external_select
   */
  @inlinable
  init<S: StringProtocol>(_ title           : S,
                          selection         : Binding<Selection>,
                          maxSelectionCount : Int?    = nil,
                          placeholder       : String? = nil,
                          minQueryLength    : Int)
  {
    self.init(actionID: .auto, title, selection: selection,
              placeholder: placeholder, maxSelectionCount: maxSelectionCount,
              minQueryLength: minQueryLength, action: nil, content: nil)
  }
  
  /**
   * Creates a picker which is driven driven by an external datasource (needs
   * to be configured in the Slack app config).
   *
   * Example:
   *
   *     Picker("Products", $selectedProduct, minQueryLength: 3) {
   *         print("user selected:", selectedProduct)
   *     }
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#external_select
   */
  @inlinable
  init<S: StringProtocol>(_ title           : S,
                          selection         : Binding<Selection>,
                          maxSelectionCount : Int?    = nil,
                          placeholder       : String? = nil,
                          minQueryLength    : Int,
                          action            : @escaping Action)
  {
    self.init(actionID: .auto, title, selection: selection,
              placeholder: placeholder, maxSelectionCount: maxSelectionCount,
              minQueryLength: minQueryLength, action: action, content: nil)
  }
}


