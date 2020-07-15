//
//  DividerPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension Divider: BlocksPrimitive {
  
  public func render(in context: BlocksContext) throws {
    // TODO: This could try to be more clever and draw an own divider string
    //       when used within paragraphs and such? Well, probably not a good
    //       idea :-)
    context.startBlock(.divider)
    context.closeBlock()
  }
}
