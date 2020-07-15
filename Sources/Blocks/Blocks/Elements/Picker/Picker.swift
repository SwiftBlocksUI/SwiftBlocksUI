//
//  Picker.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

/**
 * Blocks to generate various kinds of pickers.
 *
 * This can generate all kinds of different pickers depending on the
 * `Selection`. The selection both affects the picker type and whether the
 * picker is a multiselect picker.
 *
 * It is different to a SwiftUI Picker, which is single-select, while this one
 * can also do multi selects, similar to a SwiftUI List.
 * This also doesn't support PickerStyles, not much styling in BlockKit anyways.
 *
 * ## Examples
 *
 * Static Options with `.tag`:
 * 
 *     Picker("Importance", selection: $importance,
 *            placeholder: "Select importance")
 *     {
 *         "High 💎💎✨".tag("high")
 *         "Medium 💎"  .tag("medium")
 *         "Low ⚪️"     .tag("low")
 *     }
 *
 * Identifiable objects:
 *
 *     Picker("Pick Order", orders, selection: $order) { order in
 *         "\(order.title)"
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#multi_select
 */
public struct Picker<Selection: SelectionManager, Content> {
  
  @usableFromInline let actionID          : ActionIDStyle
  @usableFromInline let placeholder       : String?
  @usableFromInline let title             : String // the label
  @usableFromInline let selection         : Binding<Selection>?
  @usableFromInline let content           : Content?
  @usableFromInline let maxSelectionCount : Int?

  @usableFromInline let action            : Action?

  /**
   * This is used to trigger the generation of an external-datasource driven
   * select list, i.e. the options of the list will be loaded from a URL which
   * is configured the app configuration.
   *
   * The recommended default value is 3. Once this is hit, the URL will be
   * queried.
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#external_select
   */
  @usableFromInline let minQueryLength    : Int?
}

extension Picker: Blocks where Content: Blocks {
  
  public typealias Body = Never

  @inlinable
  public init<S>(actionID          : ActionIDStyle = .auto,
                 _     title       : S,
                 selection         : Binding<Selection>?,
                 placeholder       : String?,
                 maxSelectionCount : Int?,
                 minQueryLength    : Int?,
                 action            : Action?,
                 content           : Content?)
           where S: StringProtocol
  {
    self.actionID          = actionID
    self.placeholder       = placeholder
    self.title             = String(title)
    self.selection         = selection
    self.maxSelectionCount = maxSelectionCount
    self.minQueryLength    = minQueryLength
    self.action            = action
    self.content           = content
  }
}

extension Picker where Content: Blocks {
  @inlinable
  public init<S>(actionID          : ActionIDStyle = .auto,
                 _     title       : S,
                 selection         : Binding<Selection>?,
                 placeholder       : String?       = nil,
                 maxSelectionCount : Int?          = nil,
                 @BlocksBuilder content: () -> Content)
           where S: StringProtocol
  {
    self.init(actionID: actionID, title, selection: selection,
              placeholder: placeholder, maxSelectionCount: maxSelectionCount,
              minQueryLength: nil, action: nil, content: content())
  }

  @inlinable
  public init<S>(actionID          : ActionIDStyle = .auto,
                 _     title       : S,
                 selection         : Binding<Selection>?,
                 placeholder       : String?       = nil,
                 maxSelectionCount : Int?          = nil,
                 action            : Action?       = nil,
                 @BlocksBuilder content: () -> Content)
           where S: StringProtocol
  {
    self.init(actionID: actionID, title, selection: selection,
              placeholder: placeholder, maxSelectionCount: maxSelectionCount,
              minQueryLength: nil, action: action, content: content())
  }
}

public extension Picker where Selection == Never, Content: Blocks {
  
  @inlinable
  init<S: StringProtocol>(_     title : S,
                          placeholder : String? = nil,
                          action      : Action? = nil,
                          @BlocksBuilder content: () -> Content)
  {
    self.init(actionID: .auto, title, selection: nil,
              placeholder: placeholder, action: action, content: content)
  }
}


// MARK: - Convenience Versions

public extension Picker where Selection == String?, Content: Blocks {
  
  @inlinable
  init<S: StringProtocol>(_     title : S,
                          selection   : Binding<String>,
                          placeholder : String? = nil,
                          action      : Action? = nil,
                          @BlocksBuilder content: () -> Content)
  {
    let binding = Binding<String?>(
      getValue: { selection.getter()         },
      setValue: { selection.setter($0 ?? "") }
    )
    self.init(actionID: .auto, title,
              selection: binding,
              placeholder: placeholder, action: action, content: content)
  }
}
public extension Picker where Selection == Int?, Content: Blocks {
  
  @inlinable
  init<S: StringProtocol>(_     title : S,
                          selection   : Binding<Int>,
                          placeholder : String? = nil,
                          action      : Action? = nil,
                          @BlocksBuilder content: () -> Content)
  {
    let binding = Binding<Int?>(
      getValue: { selection.getter()        },
      setValue: { selection.setter($0 ?? 0) }
    )
    self.init(actionID: .auto, title,
              selection: binding,
              placeholder: placeholder, action: action, content: content)
  }
}



// MARK: - Modifiers

public extension Picker where Content: Blocks { // Direct Modifiers
  
  @inlinable
  func title(_ title: String) -> Self {
    return .init(actionID          : actionID,
                 title, selection  : selection,
                 placeholder       : placeholder,
                 maxSelectionCount : maxSelectionCount,
                 minQueryLength    : minQueryLength,
                 action            : action, content: content)
  }
  
  @inlinable
  func actionID(_ actionID: Block.ActionID) -> Self {
    return .init(actionID          : .globalID(actionID),
                 title, selection  : selection,
                 placeholder       : placeholder,
                 maxSelectionCount : maxSelectionCount,
                 minQueryLength    : minQueryLength,
                 action            : action, content: content)
  }

  @inlinable
  func id(_ relativeID: String) -> Self {
    return .init(actionID          : .rootRelativeID(relativeID),
                 title, selection  : selection,
                 placeholder       : placeholder,
                 maxSelectionCount : maxSelectionCount,
                 minQueryLength    : minQueryLength,
                 action            : action, content: content)
  }
}
