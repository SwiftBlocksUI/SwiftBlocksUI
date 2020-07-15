//
//  SlashIt.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import http
import connect
import express
import struct SlackBlocksModel.SlashRequest

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
             _ execute : @escaping
                         ( SlashRequest, ServerResponse ) throws -> Void)
       -> Self
  {
    let cleanCommand = command?.dropPrefix("/")
    
    add(route: Route(id: id, pattern: nil, method: .POST, middleware: [
      bodyParser.urlencoded(), // make sure this has run
      
      { req, res, next in
        
        guard typeIs(req, [ "application/x-www-form-urlencoded" ]) != nil else {
          return next()
        }
        
        // Check whether there is a `command` value in the body, required for
        // slash commands.
        let actualCommand = req.body[string: "command"]
        guard !actualCommand.isEmpty else { return next() }
        
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

        try execute(slashRequest, res)
      }
    ]))
    return self
  }
}

fileprivate extension String {
  
  func dropPrefix(_ prefix: Character) -> Substring {
    if let c0 = self.first, c0 == prefix { return dropFirst() }
    return self[...]
  }
}
