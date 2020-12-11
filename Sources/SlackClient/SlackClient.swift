//
//  SlackClient.swift
//  SlackClient
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import class  Foundation.ProcessInfo
import struct SlackBlocksModel.Token

/**
 * A tinsy Slack Client object based on `http.Agent`.
 *
 * There should usually be only one instance of the client object.
 * 
 * The required token (`xoxp-xyz...`) can either be provided using the
 * `token` parameter, or the `SLACK_ACCESS_TOKEN` variable can be set
 * in the environment.
 *
 * Example:
 *
 *     let client = SlackClient()
 *     client.views.open(MyView(), with: action.triggerID) { error, json in
 *         ...
 *     }
 *     
 */
public struct SlackClient {
  // TBD: maybe build a HTTP client into MacroCore? Ideally AsyncHTTPClient.
  // This is to get going.
  
  public let url   : URL
  public let token : Token
  
  public
  init(endpoint : URL    = URL(string: "https://api.slack.com/api")!,
       token    : Token? = nil)
  {
    var envToken : Token {
      let pi = ProcessInfo.processInfo
      let s = pi.environment["SLACK_ACCESS_TOKEN"]?
                .trimmingCharacters(in: .whitespacesAndNewlines)
      return Token(s ?? "")
    }
    
    self.url     = endpoint
    self.token   = token ?? envToken
    
    if !self.token.isValid {
      #if DEBUG
        print("Token passed to SlackClient is not valid: '\(self.token.value)'")
      #else
        print("Token passed to SlackClient is not valid!")
      #endif
    }
    #if false
      // this is especially OK during development, we may not have set this yet
      assert(self.token.isValid, "no valid Slack client token given!")
    #endif
  }
}
