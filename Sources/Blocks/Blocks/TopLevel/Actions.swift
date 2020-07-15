//
//  Actions.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * An block which can contain interactive elements (buttons, select menus,
 * date pickers).
 *
 * Example:
 *
 *     Actions {
 *       Button(.primary, value: "123") {
 *         Text("Approve")
 *       }
 *     }
 *
 * Docs: https://api.slack.com/reference/block-kit/blocks#actions
 */
public struct Actions<Content: Blocks>: Blocks, TopLevelPrimitiveBlock {
  
  public typealias Body = Never
  
  public            var blockID : BlockIDStyle
  @usableFromInline let content : Content
  
  @inlinable
  public init(id: BlockIDStyle = .auto, @BlocksBuilder content: () -> Content) {
    self.blockID = id
    self.content = content()
  }
}
