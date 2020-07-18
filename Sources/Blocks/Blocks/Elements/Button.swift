//
//  Button.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block

/**
 * Encode a "button" element.
 *
 * Buttons come in many forms and styles. They can have an `Action` attached
 * if the Blocks are used as an Endpoint.
 *
 * There are also special-purpose buttons: `Submit` and `Cancel` which are
 * used in combination w/ View Submissions.
 *
 * Example:
 *
 *     Actions {
 *       Button("Approve", .primary, value: "123")
 *     }
 *
 * Example with nested Text:
 *
 *     Actions {
 *       Button(.primary, value: "123") {
 *         Text("Approve")
 *       }
 *     }
 *
 * Example with Link:
 *
 *     Actions {
 *       Button(.primary, value: "123") {
 *         Link("Apple.com", destination: URL("https://apple.com")!)
 *       }
 *     }
 *
 * Example with Confirmation:
 *     
 *     Actions {
 *       Button(.primary, value: "123") {
 *         Link("Apple.com", destination: URL("https://apple.com")!)
 *       }
 *       .confirm(message: "Do you really want to go to Apple.com?!",
 *                style: .danger)
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/block-elements#button
 */
public struct Button<Content: Blocks>: Blocks {
  // TBD: Directly attaching handlers is not impossible if we do WO style
  //      event handling, but lets go with the easy stuff first.
  // TODO: needs support for confirmation children!
  
  public typealias Body   = Never
  public typealias Style  = Block.Button.Style // primary, danger, none
  
  @usableFromInline let actionID : ActionIDStyle
  @usableFromInline let content  : Content?
  @usableFromInline let title    : String
  @usableFromInline let value    : String?
  @usableFromInline let style    : Style
  @usableFromInline let url      : URL?
  
  @usableFromInline let action   : Action?

  // Note: The content can carry the Confirmation object builder

  @inlinable
  public init(actionID : ActionIDStyle,
              title    : String,
              style    : Style,
              value    : String?,
              content  : Content?,
              url      : URL?,
              action   : Action?)
  {
    self.actionID = actionID
    self.title    = title
    self.value    = value
    self.style    = style
    self.content  = content
    self.url      = url
    self.action   = action
  }
}


extension Button {
  
  @inlinable
  public init(_ title : String  = "",
              _ style : Style   = .none,
              value   : String? = nil,
              action  : Action? = nil,
              @BlocksBuilder content: () -> Content)
  {
    // This also has a title, because the content might be a `Link` yielding
    // the URL.
    self.init(actionID : .auto,
              title    : title, style: style, value: value, content: content(),
              url      : nil, action: action)
  }

  @inlinable
  public init(_ title : String  = "",
              _ style : Style   = .none,
              value   : String? = nil,
              action  : @escaping SyncAction,
              @BlocksBuilder content: () -> Content)
  {
    // This also has a title, because the content might be a `Link` yielding
    // the URL.
    self.init(actionID : .auto,
              title    : title, style: style, value: value, content: content(),
              url      : nil,
              action   : { response in try action(); response.end() })
  }
}

extension Button where Content == Never {
  
  @inlinable
  public init(_ title: String, _ style: Style = .none, value: String? = nil) {
    self.init(actionID : .auto,
              title    : title, style: style, value: value, content: nil,
              url      : nil, action: nil)
  }

  @inlinable
  public init(_ title: String, _ style: Style = .none, value: String? = nil,
              action: @escaping Action)
  {
    self.init(actionID : .auto,
              title    : title, style: style, value: value, content: nil,
              url      : nil,
              action   : action)
  }

  @inlinable
  public init(_ title: String, _ style: Style = .none, value: String? = nil,
              action: @escaping SyncAction)
  {
    self.init(actionID : .auto,
              title    : title, style: style, value: value, content: nil,
              url      : nil,
              action   : { response in try action(); response.end() })
  }
}


// MARK: - Modifiers

public extension Button { // Direct Modifiers
  
  @inlinable
  func title(_ title: String) -> Self {
    return .init(actionID: actionID, title: title, style: style,
                 value: value, content: content, url: url, action: action)
  }
  
  @inlinable
  func actionID(_ actionID: Block.ActionID) -> Self {
    return .init(actionID: .globalID(actionID), title: title, style: style,
                 value: value, content: content, url: url, action: action)
  }

  @inlinable
  func id(_ relativeID: String) -> Self {
    return .init(actionID: .rootRelativeID(relativeID),
                 title: title, style: style,
                 value: value, content: content, url: url, action: action)
  }
}
  
public extension Button { // Direct Modifiers, style
  // TBD: are there better standard SwiftUI modifiers for this?
  
  @inlinable
  func primary() -> Self {
    return .init(actionID: actionID, title: title, style: .primary,
                 value: value, content: content, url: url, action: action)
  }
  @inlinable
  func danger() -> Self {
    return .init(actionID: actionID, title: title, style: .danger,
                 value: value, content: content, url: url, action: action)
  }
}
