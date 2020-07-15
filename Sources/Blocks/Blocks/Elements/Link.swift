//
//  Link.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.Block

/**
 * Renders or attaches a hyperlink to a Block or element.
 *
 * In regular or rich text, this creates a Link run.
 * When used within `Button`s, the button's URL is filled with the link.
 * When used as a `Section` accessory or as a top-level `Actions` block child,
 * it becomes a `Button` with the link's URL.
 *
 * `Actions` Example:
 *
 *     Actions {
 *       Link("Visit ZZ", destination: URL("https://zeezide.de/")!)
 *     }
 *
 * `Section` Example:
 *
 *     Section {
 *       Accessory {
 *         Link("Visit ZZ", destination: URL("https://zeezide.de/")!)
 *       }
 *     }
 *
 * `Button` Example:
 *
 *    Button {
 *      Link("Visit ZZ", destination: URL("https://zeezide.de/")!)
 *    }
 */
public struct Link {
  // The SwiftUI link can have images and such as a body (<a><img></a>),
  // but I think we can't do that in BlockKit?

  public typealias FontStyle = Block.RichTextElement.Run.FontStyle

  let destination : URL
  let title       : String
  let style       : FontStyle
  
  public init(_ title: String = "", destination: URL, style: FontStyle = []) {
    self.title       = title
    self.destination = destination
    self.style       = style
  }
  
  var isStyled : Bool { return !style.isEmpty }
}

extension Link: Blocks {
  public typealias Body = Never
}

public extension Link {
  
  private func adding(_ modifier: FontStyle) -> Link {
    if style.contains(modifier) { return self }
    return Link(title, destination: destination, style: style.union(modifier))
  }
  func bold()   -> Link { return adding(.bold)   }
  func italic() -> Link { return adding(.italic) }
  func code()   -> Link { return adding(.code)   }
  func strike() -> Link { return adding(.strike) }
}

public extension Link {
  
  var slackMarkdownString: String {
    // TBD: escaping
    var ms = "<\(destination.absoluteString)"
    if !title.isEmpty { ms += "|\(title)" }
    ms += ">"
    return style.markdownStyle(ms)
  }
}
