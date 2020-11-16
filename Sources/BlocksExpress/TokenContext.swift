//
//  TokenContext.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class     Foundation.ProcessInfo
import class     MacroExpress.IncomingMessage
import struct    SlackBlocksModel.Token

fileprivate let tokenKey = "macro.slick.slack.access-token"

fileprivate let environmentToken : Token = {
  let pi = ProcessInfo.processInfo
  let s = pi.environment["SLACK_ACCESS_TOKEN"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
  return Token(s ?? "")
}()

public extension IncomingMessage {

  /**
   * Returns or sets the slack access token associated with the message.
   *
   * If none is provided, it looks up the token using the `SLACK_ACCESS_TOKEN`
   * environment variable (consider `dotenv.config()` to configure it).
   */
  var slackAccessToken: Token {
    set { extra[tokenKey] = newValue }
    get { return (extra[tokenKey] as? Token) ?? environmentToken }
  }
}
