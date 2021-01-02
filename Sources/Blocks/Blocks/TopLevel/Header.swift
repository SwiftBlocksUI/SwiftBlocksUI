//
//  Header.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A simple header text. Very similar to an HTML `H1` tag.
 *
 * The `Header` block only supports a plaintext value!
 *
 * Example:
 *
 *     Header {
 *       Text("Good news everyone!")
 *     }
 * 
 * Docs: https://api.slack.com/reference/block-kit/blocks#header
 */
public struct Header<Content: Blocks>: Blocks, TopLevelPrimitiveBlock {
  
  public typealias Body = Never
  
  public            var blockID : BlockIDStyle
  @usableFromInline let content : Content
  
  @inlinable
  public init(id: BlockIDStyle = .auto, @BlocksBuilder content: () -> Content) {
    self.blockID = id
    self.content = content()
  }
}

public extension Text {
  // TBD: This is a little funky :-) It isn't perfectly clean because it
  //      elevates the `Text` into a `Block` (the header), which might be
  //      unexpected to the user.
  
  enum Font: Equatable {
    case title, regular
  }
  
  @inlinable
  func font(_ font: Font) -> some Blocks {
    Group {
      switch font {
        case .regular : self
        case .title   : Header { self }
      }
    }
  }
}

public extension Header where Content == Text {
  
  @inlinable
  init<S>(id: BlockIDStyle = .auto, _ title: S) where S: StringProtocol {
    self.init(id: id) { Text(title) }
  }
}
