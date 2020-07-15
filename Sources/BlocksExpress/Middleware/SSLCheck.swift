//
//  SSLCheck.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import typealias MacroExpress.Middleware
import class     MacroExpress.Express
import let       MacroExpress.env

/**
 * If Slack public distribution is enabled, Slack will sometimes send the URL a
 * POST w/ the "ssl_check=1" and a token parameter (verification token of the
 * slash command).
 */
public func sslCheck(_ verifyToken: @escaping ( String ) -> Bool) -> Middleware
{
  return { req, res, next in
    guard req.method == "POST", req.body[string: "ssl_check"] == "1" else {
      return next()
    }
    guard verifyToken(req.body[string: "token"]) else {
      return res.sendStatus(401) // TBD
    }
    return res.sendStatus(200)
  }
}

/**
 * Note: returns true in debug mode when SLACK_VERIFICATION_TOKEN is not set.
 */
public func verifyToken(usingEnvironmentVariable name : String
                          = "SLACK_VERIFICATION_TOKEN",
                        allowUnsetInDebug : Bool = true)
            -> ( String ) -> Bool
{
  return { verificationToken in
    if let value = env[name] { // always use if set
      return value == verificationToken
    }
    
    #if DEBUG
      return allowUnsetInDebug
    #else
      return false
    #endif
  }
}
