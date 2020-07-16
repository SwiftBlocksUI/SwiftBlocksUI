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
    
    for (idx, element) in data.enumerated() {
      let id = elementToID(element)
      if let id = id {
        context.enterForEachElement(with: id)
      }
      else {
        context.enterForEachElement(with: idx)
      }
      defer {
        if let id = id {
          context.leaveForEachElement(with: id)
        }
        else {
          context.leaveForEachElement(with: idx)
        }
      }
      
      try context.render(content(element))
    }
  }
}
