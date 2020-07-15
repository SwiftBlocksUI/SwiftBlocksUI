//
//  ResponseScopeModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.MessageResponse

public struct ResponseScopeModifier<Content: Blocks>: Blocks {

  public typealias Body = Never
  
  public let scope   : MessageResponse.ResponseType
  public let content : Content

  @inlinable
  public init(_ scope : MessageResponse.ResponseType,
              content: Content)
  {
    self.scope   = scope
    self.content = content
  }
}
extension ResponseScopeModifier
            : CallbackIDTransparentModifier, CallbackBlock
{}

public extension Blocks {
  
  @inlinable
  func responseScope(_ scope: MessageResponse.ResponseType)
       -> ResponseScopeModifier<Self>
  {
    return ResponseScopeModifier(scope, content: self)
  }
}

extension ResponseScopeModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    if let existingScope = context.messageResponseScope {
      if existingScope != scope {
        context.log.warning(
          "a different response scope is already set: \(existingScope)")
      }
      return try context.render(content)
    }
    else {
      context.messageResponseScope = scope
      return try context.render(content)
    }
  }
}
