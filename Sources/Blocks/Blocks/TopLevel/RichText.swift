//
//  RichText.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A block containing formatted and styled content.
 *
 * Depending on your needs, you might rather want to use a `Section`.
 *
 * Note: `RichText` blocks do not seem to be supported with bot tokens,
 *       they get converted to `Section`s automagically.
 *
 * Those are vertically stacked paragraphs containing formatted Text elements.
 *
 * Example:
 *
 *     RichText {
 *       Paragraph {
 *         "Hello"
 *         Text("World")
 *           .bold()
 *       }
 *       Preformatted {
 *         """
 *         let a = 10
 *         """
 *       }
 *     }
 *
 */
public struct RichText<Content: Blocks>: Blocks, TopLevelPrimitiveBlock {
  
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
 * Preformatted ("triple-quote") content within a `RichText` block.
 *
 * If it isn't nested in a `RichText`, it'll automatically create one.
 *
 * Example:
 *
 *     Preformatted {
 *       """
 *       let a = 10
 *       """
 *     }
 *
 */
public struct Preformatted<Content: Blocks>: Blocks {
  public typealias Body = Never
  
  @usableFromInline let content : Content
  
  @inlinable
  public init(@BlocksBuilder content: () -> Content) {
    self.content = content()
  }
}

/**
 * Styled content within a `RichText` block.
 *
 * If it isn't nested in a `RichText`, it'll automatically create one.
 *
 * Example:
 *
 *     RichText {
 *       Paragraph {
 *         "Hello"
 *         Text("World")
 *           .bold()
 *       }
 *     }
 *
 */
public struct Paragraph<Content: Blocks>: Blocks {
  public typealias Body = Never
  
  @usableFromInline let content : Content
  
  @inlinable
  public init(@BlocksBuilder content: () -> Content) {
    self.content = content()
  }
}

/**
 * Quoted content within a `RichText` block.
 *
 * If it isn't nested in a `RichText`, it'll automatically create one.
 *
 * Example:
 *
 *     RichText {
 *       Quote {
 *         """
 *         Nobdy can complain that Catalyst doesn't look like macOS
 *         if macOS doesn't look like macOS
 *         """
 *         Link("@terhechte",
 *              destination:
 *              URL("https://twitter.com/terhechte/status/1275129345590341636")
 *           .italic()
 *       }
 *     }
 *
 */
public struct Quote<Content: Blocks>: Blocks {
  public typealias Body = Never
  
  @usableFromInline let content : Content
  
  @inlinable
  public init(@BlocksBuilder content: () -> Content) {
    self.content = content()
  }
}
