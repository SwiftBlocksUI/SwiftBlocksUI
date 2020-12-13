//
//  BlocksRequest.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class http.IncomingMessage
import SlackBlocksModel
import express

public extension bodyParser {

  /**
   * Middleware which parses `BlocksEnvironment` objects into the
   * respective `IncomingRequest` field (`req.blocksEnvironment`).
   *
   * The blocks environment contains: user, team, conversation.
   * It is common for interactive request and slash commands.
   *
   * Example:
   *
   *     app.post(bodyParser.parseBlocksEnvironment())
   *     app.post { req, res, next in
   *       console.log("A user interacted w/ app:", req.blocksEnvironment.user)
   *     }
   *
   */
  @inlinable
  static func parseBlocksEnvironment() -> Middleware {
    // This is the middleware equivalent to the Blocks `InteractiveEnvironment`
    // environment keys.
    // It is particularily useful for setup middleware (e.g. to setup an app
    // home for a user).
    
    return Route(id: nil, pattern: nil, method: .POST, middleware: [
      interactiveRequest(), // make sure this has run
      
      { req, res, next in
        if req.extra[didParseBlocksEnvironmentKey] != nil { return }
        req.extra[didParseBlocksEnvironmentKey] = true
              
        if let request = req.interactiveRequest {
          switch request {
            case .shortcut(let request):
              req.blocksEnvironment = .init(
                user         : request.user,
                team         : request.team,
                conversation : nil
              )
              
            case .messageAction(let request):
              req.blocksEnvironment = .init(
                user         : request.user,
                team         : request.team,
                conversation : request.conversation
              )
              
            case .blockActions(let request):
              // conversation might be sometimes available, depending on the
              // container.
              req.blocksEnvironment = .init(
                user         : request.user,
                team         : request.team,
                conversation : nil // request.conversation
              )

            case .viewSubmission(let request):
              req.blocksEnvironment = .init(
                user         : request.user,
                team         : request.team,
                conversation : nil
              )

            case .viewClosed(let request):
              req.blocksEnvironment = .init(
                user         : request.user,
                team         : request.team,
                conversation : nil
              )
          }
        }
        else if !req.body[string: "command"].isEmpty,
                typeIs(req, [ "application/x-www-form-urlencoded" ]) != nil,
                let request = SlashRequest(req.body)
        {
          req.blocksEnvironment = .init(
            user         : request.user,
            team         : request.team,
            conversation : request.conversation
          )
        }
        else {
          req.blocksEnvironment = .empty
        }

        next()
      }
    ])
    .middleware
  }
}

@usableFromInline
let blocksEnvironmentKey = "macro.slick.blocks-environment"
@usableFromInline
let didParseBlocksEnvironmentKey = "macro.slick.blocks-environment.parsed"

public extension IncomingMessage {
  
  /**
   * Common environment variables for a Slack interactive or Slash
   * request.
   */
  struct BlocksEnvironment {
    
    public let user         : InteractiveRequest.User?
    public let team         : InteractiveRequest.Team?
    public let conversation : InteractiveRequest.Conversation?
    
    @inlinable
    public init(user         : InteractiveRequest.User?,
                team         : InteractiveRequest.Team?,
                conversation : InteractiveRequest.Conversation?)
    {
      self.user         = user
      self.team         = team
      self.conversation = conversation
    }
    
    public static let empty =
                 BlocksEnvironment(user: nil, team: nil, conversation: nil)
  }

  @inlinable
  var blocksEnvironment: BlocksEnvironment {
    set { extra[blocksEnvironmentKey] = newValue }
    get {
      guard let value = extra[blocksEnvironmentKey] else { return .empty }
      guard let env   = value as? BlocksEnvironment else {
        log.error("blocksEnvironment extra contains a foreign value: \(value)")
        assertionFailure("incorrect value in blocksEnvironment extra")
        return .empty
      }
      return env
    }
  }
}
