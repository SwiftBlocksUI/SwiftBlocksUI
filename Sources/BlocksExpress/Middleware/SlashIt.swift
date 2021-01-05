//
//  SlashIt.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct   Logging.Logger
import class    http.IncomingMessage
import class    http.ServerResponse
import enum     connect.bodyParser
import class    express.Route
import protocol express.RouteKeeper
import struct   SlackBlocksModel.SlashRequest
import protocol SlackBlocksModel.StringID

public extension RouteKeeper {

  /**
   * Add a handler for a Slash command.
   *
   * Note that those are not middleware handlers, i.e. they do not receive a
   * `next` closure. Instead they MUST end in finishing the server response
   * (i.e. eventually call `end` on it).
   *
   * Slash handlers have 3 seconds to respond to the request, afterwards the
   * client will timeout.
   * What they can do is send a 200 immediately, and more content later on.
   *
   * Docs: https://api.slack.com/interactivity/slash-commands
   */
  @discardableResult
  func slash(id        : String? = nil,
             _ command : String? = nil,
             execute   : @escaping
                         ( SlashRequest, IncomingMessage, ServerResponse )
                           throws -> Void)
       -> Self
  {
    let cleanCommand = command?.dropPrefix("/")
    
    add(route: Route(id: id, pattern: nil, method: .POST, middleware: [
      bodyParser.urlencoded(), // make sure this has run
      
      { req, res, next in
        
        guard req.is("application/x-www-form-urlencoded") else {
          return next()
        }
        
        // Check whether there is a `command` value in the body, required for
        // slash commands.
        let actualCommand = req.body[string: "command"]
        guard !actualCommand.isEmpty else { return next() }
        req.log[metadataKey: "slash-command"] = .string(actualCommand)

        // If the user specified a command name, make sure it is the same
        if let cleanCommand = cleanCommand,
           actualCommand.dropPrefix("/") != cleanCommand
        {
          return next()
        }
        
        // OK, we consider it a matching Slash request, take it
        guard let slashRequest = SlashRequest(req.body) else {
          req.log.error("failed to parse Slash request: \(req.body)")
          return res.sendStatus(400)
        }
        
        slashRequest.addInfoToLogger(&req.log)
        slashRequest.addInfoToLogger(&res.log)
        try execute(slashRequest, req, res)
      }
    ]))
    return self
  }

  /**
   * Add a handler for a Slash command.
   *
   * Note that those are not middleware handlers, i.e. they do not receive a
   * `next` closure. Instead they MUST end in finishing the server response
   * (i.e. eventually call `end` on it).
   *
   * Slash handlers have 3 seconds to respond to the request, afterwards the
   * client will timeout.
   * What they can do is send a 200 immediately, and more content later on.
   *
   * Docs: https://api.slack.com/interactivity/slash-commands
   */
  @discardableResult
  func slash(id        : String? = nil,
             _ command : String? = nil,
             execute   : @escaping
                         ( SlashRequest, ServerResponse ) throws -> Void)
       -> Self
  {
    return slash(id: id, command, execute: { slash, _, res in
      try execute(slash, res)
    })
  }
}

extension SlashRequest {
  
  @usableFromInline
  func addInfoToLogger(_ logger: inout Logger) {
    func add<V: StringID>(_ key: String, _ value: V?) {
      guard let value = value else { return }
      logger[metadataKey: key] = .string(value.id)
    }
    
    add("slack-user-id"       , user.id)
    add("slack-team-id"       , team.id)
    add("slack-enterprise-id" , enterprise?.id)
    add("slack-channel-id"    , conversation.id)
    add("slack-trigger-id"    , triggerID)
    logger[metadataKey: "slash-command"] = .string(command)
  }
}

fileprivate extension String {
  
  func dropPrefix(_ prefix: Character) -> Substring {
    if let c0 = self.first, c0 == prefix { return dropFirst() }
    return self[...]
  }
}
