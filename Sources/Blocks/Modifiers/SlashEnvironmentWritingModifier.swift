//
//  SlashEnvironmentWritingModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.SlashRequest

public struct SlashEnvironmentWritingModifier<Content: Blocks>: Blocks {
  // Optimization over just using tons of `.environment()`,
  // avoids all the CoW copying by using just one View for
  // all those keys.

  public typealias Body = Never
  
  public let request : SlashRequest
  public let content : Content

  @inlinable
  public init(_ request: SlashRequest, content: Content) {
    self.request = request
    self.content = content
  }
}
extension SlashEnvironmentWritingModifier
            : CallbackIDTransparentModifier, CallbackBlock
{}

public extension Blocks {
  
  @inlinable
  func slashEnvironment(_ request: SlashRequest)
       -> SlashEnvironmentWritingModifier<Self>
  {
    return SlashEnvironmentWritingModifier(request, content: self)
  }
}

extension SlashEnvironmentWritingModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    try context.environments._inModifiedEnvironment(
      execute: { try context.render(content) })
    {
      $0[keyPath: \.slashRequest] = request
      $0[keyPath: \.user]         = request.user
      $0[keyPath: \.team]         = request.team
      $0[keyPath: \.conversation] = request.conversation
      $0[keyPath: \.enterprise]   = request.enterprise
      $0[keyPath: \.slashCommand] = request.command
      $0[keyPath: \.messageText]  = request.text
      $0[keyPath: \.triggerID]    = request.triggerID
      $0[keyPath: \.responseURL]  = request.responseURL
    }
  }
}
