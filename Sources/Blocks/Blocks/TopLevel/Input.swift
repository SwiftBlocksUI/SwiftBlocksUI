//
//  Input.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * Embeds its contents in an Input block.
 *
 * Input blocks are only valid in modals. Unlike you might expect, an
 * Input only holds a single element (e.g. a `TextField`, a `DatePicker`
 * or one of the menus!
 * It annotates that `TextField` with required extra information like a label
 * and a hint.
 *
 * Quite often you don't explicitly need to specify an `Input` in your Blocks,
 * just using a `TextField` will automatically wrap the Input around.
 *
 * Example:
 *
 *     View {
 *       Input(hint: "Hello World!") {
 *         TextField("Title", text:$title)
 *       }
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/blocks#input
 */
public struct Input<Content: Blocks>: Blocks, TopLevelPrimitiveBlock {
  
  public typealias Body = Never
  
  public            var blockID  : BlockIDStyle
  @usableFromInline let label    : String  // max 2k characters
  @usableFromInline let hint     : String? // max 2k characters
  @usableFromInline let optional : Bool
  @usableFromInline let content  : Content
  
  @inlinable
  public init(id       : BlockIDStyle = .auto,
              label    : String       = "",
              hint     : String?      = nil,
              optional : Bool         = false,
              @BlocksBuilder content: () -> Content)
  {
    self.blockID  = id
    self.label    = label
    self.hint     = hint
    self.optional = optional
    self.content  = content()
  }
}
