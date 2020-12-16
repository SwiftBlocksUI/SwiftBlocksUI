//
//  TextField.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class Foundation.Formatter
import class Foundation.Bundle
import enum  SlackBlocksModel.Block

/**
 * A Plain-text input element
 *
 * `TextField`'s are only valid in modals, within `Input` blocks!
 * I.e. they can't be used within `Actions` or as a `Section` accessory.
 *
 * `Formatter` objects can be used to format, parse and validate values. If a
 * formatter fails to parse a value, and error will be returned for the
 * view submission (and shown to the user by the client).
 *
 * Example with implicit Input:
 *
 *     View {
 *       TextField("Lastname", text: $person.lastName)
 *     }
 *
 * Example with explicit Input:
 *
 *     View {
 *       Input(hint: "Hello World!", optional: true) {
 *         TextField("Lastname", text: $person.lastName)
 *       }
 *     }
 *
 * Example with Formatter:
 *
 *     TextField("Amount", value: $amount,
 *               formatter: NumberFormatter())
 *
 * TextField with a specific length:
 *
 *     TextField("Password", text: $person.lastName)
 *       .length(3...10)
 * 
 * Docs: https://api.slack.com/reference/block-kit/block-elements#input
 */
public struct TextField<Value> {
  // Note: A little different to the SwiftUI TextField, which has Label
  //       Blocks (it is generic over it). We only allow a plain String here.
  
  @usableFromInline let actionID      : ActionIDStyle
  @usableFromInline let placeholder   : String?
  @usableFromInline let multiline     : Bool
  @usableFromInline let minimumLength : Int?
  @usableFromInline let maximumLength : Int?

  @usableFromInline let title         : String // the label
  @usableFromInline let value         : Binding<Value>
  @usableFromInline let formatter     : Formatter?

  @inlinable
  public init<S>(actionID      : ActionIDStyle = .auto,
                 _     title   : S,
                 value         : Binding<Value>,
                 formatter     : Formatter?,
                 placeholder   : String?,
                 multiline     : Bool,
                 minimumLength : Int?,
                 maximumLength : Int?)
           where S: StringProtocol
  {
    self.actionID      = actionID
    self.placeholder   = placeholder
    self.multiline     = multiline
    self.title         = String(title)
    self.value         = value
    self.formatter     = formatter
    self.minimumLength = minimumLength
    self.maximumLength = maximumLength
  }
}

/**
 * A multiline TextField.
 */
@inlinable
public func TextEditor(_ title: String, text: Binding<String>,
                       placeholder   : String? = nil,
                       minimumLength : Int?    = nil,
                       maximumLength : Int?    = nil)
            -> TextField<String>
{
  return TextField(title, value: text, formatter: nil,
                   placeholder   : placeholder, multiline: true,
                   minimumLength : minimumLength,
                   maximumLength : maximumLength)
}

public extension TextField where Value == String {

  @inlinable
  init<S>(actionID      : ActionIDStyle = .auto,
          _     title   : S,
          text          : Binding<String>, // aka value
          placeholder   : String? = nil,
          multiline     : Bool    = false,
          minimumLength : Int?    = nil,
          maximumLength : Int?    = nil)
    where S: StringProtocol
  {
    self.init(actionID: actionID, title, value: text, formatter: nil,
              placeholder: placeholder, multiline: multiline,
              minimumLength: minimumLength, maximumLength: maximumLength)
  }
}

public extension TextField where Value == String {

  @inlinable
  init(_   title : LocalizedStringKey,
       text      : Binding<String>,
       multiline : Bool               = false)
  {
    let key = title.value
    self.init(actionID: .auto,
              Bundle.main.localizedString(forKey: key, value: key, table: nil),
              value: text, formatter: nil,
              placeholder: nil, multiline: multiline,
              minimumLength: nil, maximumLength: nil)
  }
  @inlinable
  init(_   title : LocalizedStringKey,
       text      : String,
       multiline : Bool               = false)
  {
    let key = title.value
    self.init(actionID: .auto,
              Bundle.main.localizedString(forKey: key, value: key, table: nil),
              value: .constant(text), formatter: nil,
              placeholder: nil, multiline: multiline,
              minimumLength: nil, maximumLength: nil)
  }
}

public extension TextField {
  
  @inlinable
  init(_   title : String,
       value     : Binding<Value>,
       formatter : Formatter,
       multiline : Bool = false)
  {
    self.init(actionID    : .auto, title,
              value       : value, formatter: formatter,
              placeholder : nil,
              multiline   : multiline, minimumLength: nil, maximumLength: nil)
  }
  
  #if false // this one makes it ambiguous (Binding vs regular)
  @inlinable
  init(_   title : String,
       value     : Value,
       formatter : Formatter,
       multiline : Bool      = false)
  {
    self.init(actionID    : .auto, title,
              value       : Binding.constant(value), formatter: formatter,
              placeholder : nil,
              multiline   : multiline, minimumLength: nil, maximumLength: nil)
  }
  #endif
}

public extension TextField where Value == String {
  
  @inlinable
  init<V>(_   title : String,
          value     : Binding<V?>,
          formatter : Formatter,
          nilString : String,
          multiline : Bool      = false)
  {
    self.init(actionID: .auto, title,
              text: value.formatter(formatter, nilString: nilString),
              placeholder: nil,
              multiline: multiline, minimumLength: nil, maximumLength: nil)
  }
  @inlinable
  init<V>(_   title : String,
          value     : V?,
          formatter : Formatter,
          nilString : String,
          multiline : Bool      = false)
  {
    self.init(actionID: .auto, title,
              text: Binding.constant(value)
                           .formatter(formatter, nilString: nilString),
              placeholder: nil,
              multiline: multiline, minimumLength: nil, maximumLength: nil)
  }
}

public extension TextField { // Direct Modifiers
  
  @inlinable
  func title(_ title: String) -> Self {
    return .init(actionID      : actionID, title,
                 value         : value, formatter: formatter,
                 placeholder   : placeholder, multiline: multiline,
                 minimumLength : minimumLength, maximumLength: maximumLength)
  }
  
  @inlinable
  func actionID(_ actionID: Block.ActionID) -> Self {
    return .init(actionID      : .globalID(actionID), title,
                 value         : value, formatter: formatter,
                 placeholder   : placeholder, multiline: multiline,
                 minimumLength : minimumLength, maximumLength: maximumLength)
  }
  @inlinable
  func id(_ relativeID: String) -> Self {
    return .init(actionID      : .rootRelativeID(relativeID), title,
                 value         : value, formatter: formatter,
                 placeholder   : placeholder, multiline: multiline,
                 minimumLength : minimumLength, maximumLength: maximumLength)
  }

  @inlinable
  func length(_ range: ClosedRange<Int>) -> Self {
    return .init(actionID      : actionID, title,
                 value         : value, formatter: formatter,
                 placeholder   : placeholder, multiline: multiline,
                 minimumLength : range.lowerBound,
                 maximumLength : range.upperBound)
  }
  
  @inlinable
  func length(_ range: Range<Int>) -> Self {
    return .init(actionID      : actionID, title,
                 value         : value, formatter: formatter,
                 placeholder   : placeholder, multiline: multiline,
                 minimumLength : range.lowerBound,
                 maximumLength : range.upperBound - 1)
  }
}

extension TextField: Blocks {
  public typealias Body = Never
}
