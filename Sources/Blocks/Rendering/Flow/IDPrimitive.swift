//
//  IDPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension IDModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    let old = context.pendingID
    context.pendingID = id
    
    defer {
      if let pendingID = context.pendingID {
        assert(pendingID == AnyHashable(id))
        context.log.trace("unused .id(\(pendingID): \(self)")
      }
      context.pendingID = old
    }
    
    try context.render(content)
  }
}

extension TagModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    let old = context.pendingTag
    context.pendingTag = tag
    
    defer {
      if let pendingTag = context.pendingTag {
        assert(pendingTag == AnyHashable(tag))
        context.log.trace("unused .tag(\(pendingTag): \(self)")
      }
      context.pendingTag = old
    }
    
    try context.render(content)
  }
}
