//
//  Context.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * Displays images and text in a vertical stack in a smaller font.
 *
 * Show some contextual information, visually distinct to the main message
 * content.
 *
 * Example:
 *
 *     Context {
 *       Image("Pin", url: URL(
 *        "https://image.freepik.com/free-photo/red-drawing-pin_1156-445.jpg")!)
 *       Text("Location: ") + Text("Dogpatch").bold()
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/blocks#context
 */
public struct Context<Content: Blocks>: Blocks, TopLevelPrimitiveBlock {
  
  public typealias Body = Never
  
  public            var blockID : BlockIDStyle
  @usableFromInline let content : Content
  
  @inlinable
  public init(id: BlockIDStyle = .auto, @BlocksBuilder content: () -> Content) {
    self.blockID = id
    self.content = content()
  }
}
