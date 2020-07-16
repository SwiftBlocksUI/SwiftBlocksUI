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

#if canImport(FoundationNetworking)
  import class FoundationNetworking.URLSession
#else
  import class Foundation.URLSession
#endif

/**
 * A tinsy Slack Client object based on URLSession.
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
  
  public let session : URLSession
  public let url     : URL
  public let token   : Token
  
  public
  init(session  : URLSession = .shared,
       endpoint : URL        = URL(string: "https://api.slack.com/api")!,
       token    : Token?     = nil)
  {
    var envToken : Token {
      Token(ProcessInfo.processInfo.environment["SLACK_ACCESS_TOKEN"] ?? "")
    }
    
    self.session = session
    self.url     = endpoint
    self.token   = token ?? envToken
    
    if !self.token.isValid {
      #if DEBUG
        print("Token passed to SlackClient is not valid: '\(self.token.value)'")
        print(ProcessInfo.processInfo.environment)
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
