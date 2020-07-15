//
//  InteractiveRequestEnvironmentWritingModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.InteractiveRequest

public struct InteractiveRequestEnvironmentWritingModifier<Content: Blocks>
              : Blocks
{
  // Optimization over just using tons of `.environment()`,
  // avoids all the CoW copying by using just one View for
  // all those keys.

  public typealias Body = Never
  
  public let request : InteractiveRequest
  public let content : Content

  @inlinable
  public init(_ request: InteractiveRequest, content: Content) {
    self.request = request
    self.content = content
  }
}

public extension Blocks {
  
  @inlinable
  func interactiveEnvironment(_ request: InteractiveRequest)
       -> InteractiveRequestEnvironmentWritingModifier<Self>
  {
    return InteractiveRequestEnvironmentWritingModifier(request, content: self)
  }
  
  @inlinable
  func shortcutEnvironment(_ request: InteractiveRequest.Shortcut)
       -> InteractiveRequestEnvironmentWritingModifier<Self>
  {
    return interactiveEnvironment(.shortcut(request))
  }
  
  @inlinable
  func messageActionEnvironment(_ request: InteractiveRequest.MessageAction)
       -> InteractiveRequestEnvironmentWritingModifier<Self>
  {
    return interactiveEnvironment(.messageAction(request))
  }
  
  @inlinable
  func viewSubmissionEnvironment(_ request: InteractiveRequest.ViewSubmission)
       -> InteractiveRequestEnvironmentWritingModifier<Self>
  {
    return interactiveEnvironment(.viewSubmission(request))
  }
}

extension InteractiveRequestEnvironmentWritingModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    try context.environments._inModifiedEnvironment(
      execute: { try context.render(content) })
    {
      // TODO: check this
      switch request {
        case .shortcut(let request):
          // TBD: token, actionTS
          $0[keyPath: \.user]         = request.user
          $0[keyPath: \.team]         = request.team
          $0[keyPath: \.callbackID]   = request.callbackID
          $0[keyPath: \.triggerID]    = request.triggerID
          
        case .messageAction(let request):
          // TBD: token, actionTS, message (blocks etc)
          $0[keyPath: \.user]         = request.user
          $0[keyPath: \.team]         = request.team
          $0[keyPath: \.conversation] = request.conversation
          $0[keyPath: \.callbackID]   = request.callbackID
          $0[keyPath: \.triggerID]    = request.triggerID
          $0[keyPath: \.responseURL]  = request.responseURL
          $0[keyPath: \.messageText]  = request.message.text
          
        case .blockActions(let request):
          $0[keyPath: \.user]         = request.user
          $0[keyPath: \.team]         = request.team
          $0[keyPath: \.triggerID]    = request.triggerID
          #if false // it might have more info in the `container`
          $0[keyPath: \.conversation] = request.conversation
          $0[keyPath: \.messageText]  = request.message.text
          #endif

        case .viewSubmission(let request):
          // TBD: token, applicationID, view
          // TODO: What View Info do we actually need?
          // - id, botID?, externalID?, privateMetaData?, hash?, state?
          // - rootViewID, previousViewID
          $0[keyPath: \.user]         = request.user
          $0[keyPath: \.team]         = request.team
          $0[keyPath: \.triggerID]    = request.triggerID
          $0[keyPath: \.responseURL]  = request.responseURLs.first // TBD

        case .viewClosed(let request):
          // TBD: token, applicationID, view
          $0[keyPath: \.user]         = request.user
          $0[keyPath: \.team]         = request.team
      }
    }
  }
}
