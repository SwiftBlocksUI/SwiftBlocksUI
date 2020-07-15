//
//  ForEachPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension ForEach: BlocksPrimitive where Content: Blocks {
  
  public func render(in context: BlocksContext) throws {
    guard !data.isEmpty else { return }

    context.enterForEach(count: data.count)
    defer { context.leaveForEach() }
    
    for element in data {
      let id = elementToID(element)
      context.enterForEachElement(with: id)
      defer { context.leaveForEachElement(with: id) }
      
      try context.render(content(element))
    }
  }
}
