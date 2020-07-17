//
//  Section.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A very flexible top-level block that can contain formatted text,
 * fields and an interactive accessory view.
 *
 * The core structure of this block is the main text which can contain
 * markdown styled content.
 * As an extra this can show an image or an interactive element (e.g. a
 * datepicker in the upper right).
 *
 * Finally it can contain "fields", which is textual content that will be
 * layed out in a two column grid below the main text.
 *
 * Example:
 *
 *     Section {
 *       Text("Hello World!")
 *         .bold()
 *
 *       Field {
 *         Text("Style:").bold()
 *       }
 *       Field {
 *         Text("Bold)
 *       }
 *     }
 *
 * With Accessory:
 *
 *     Section {
 *       "Hello World!"
 *       Accessory {
 *         Image("A cute kitten",
 *               url: URL("http://placekitten.com/128/128")!)
 *       }
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/blocks#section
 */
public struct Section<Content: Blocks>: Blocks, TopLevelPrimitiveBlock {
  
  public typealias Body = Never
  
  public            var blockID : BlockIDStyle
  @usableFromInline let content : Content
  
  @inlinable
  public init(id: BlockIDStyle = .auto, @BlocksBuilder content: () -> Content) {
    self.blockID = id
    self.content = content()
  }
}

/**
 * Encode a section "field". Fields are shown in a two column layout.
 *
 * Example:
 *
 *     Section {
 *       Text("Hello World!")
 *       Field {
 *         Text("Style:").bold()
 *       }
 *       Field {
 *         Text("Bold)
 *       }
 *     }
 *     
 * Docs: https://api.slack.com/reference/block-kit/blocks#section
 */
public struct Field<Content: Blocks>: Blocks {
  
  public typealias Body = Never
  
  @usableFromInline let content : Content
  
  @inlinable
  public init(@BlocksBuilder content: () -> Content) {
    self.content = content()
  }
}

/**
 * An `Accessory` is shown in the upper right of a `Section` block.
 *
 * There can only be one `Accessory` and the available types are limited to:
 * - Images
 * - Buttons, DatePickers, Pickers, CheckboxGroups
 * - overflow menus (not yet available as Blocks)
 *
 * Example:
 *
 *     Section {
 *       "Hello World!"
 *       Accessory {
 *         Image("A cute kitten",
 *               url: URL("http://placekitten.com/128/128")!)
 *       }
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/blocks#section
 */
public struct Accessory<Content: Blocks>: Blocks {

  public typealias Body = Never

  @usableFromInline let content : Content

  @inlinable
  public init(@BlocksBuilder content: () -> Content) {
    self.content = content()
  }
}
