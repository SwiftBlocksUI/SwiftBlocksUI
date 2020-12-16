//
//  ParseInteractiveRequest.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import typealias MacroExpress.Middleware
import typealias MacroExpress.Next
import class     MacroExpress.IncomingMessage
import class     MacroExpress.ServerResponse
import enum      MacroExpress.bodyParser
import class     MacroExpress.Route
import func      MacroExpress.typeIs
import enum      SlackBlocksModel.InteractiveRequest

public extension bodyParser {

  /**
   * Middleware which parses `InteractiveRequest` objects into the
   * respective `IncomingRequest` field (and an error in an error property):
   *
   * IncomingMessage properties:
   * - interactiveRequest
   * - interactiveRequestError
   *
   * Example:
   *
   *     app.post(bodyParser.interactiveRequest())
   *     app.post { req, res, next in
   *       console.log("interactive request:", req.interactiveRequest)
   *     }
   *
   */
  @inlinable
  static func interactiveRequest() -> Middleware {
    return Route(id: nil, pattern: nil, method: .POST, middleware: [
      bodyParser.urlencoded(), // make sure this has run
      { req, res, next in
        try parseInteractiveRequest(req: req, res: res)
        next()
      }
    ])
    .middleware
  }

  @inlinable
  static func parseInteractiveRequest(req  : IncomingMessage,
                                      res  : ServerResponse) throws
  {
    guard req.interactiveRequest == nil
       && req.interactiveRequestError == nil else { return } // parsed
    
    guard typeIs(req, [ "application/x-www-form-urlencoded" ]) != nil else {
      return
    }
    
    // Skip Slash commands
    guard req.body[string: "command"].isEmpty else { return }
    
    // But we need a payload
    // TBD: further validate payload by pre-parsing the JSON? Depends
    //       whether we have further endpoints I guess.
    let payload = req.body[string: "payload"]
    guard !payload.isEmpty else { return }
    
    let request : InteractiveRequest
    do {
      request = try InteractiveRequest.from(json: payload)
      req.interactiveRequest = request
    }
    catch {
      req.interactiveRequestError = error
      req.log.error(
        "failed to parse payload: \(req.body[string: "payload"]) \(error)")
      throw error
    }
  }
}

@usableFromInline
let irRequestKey = "macro.slick.interactive-request"
@usableFromInline
let irErrorKey   = "macro.slick.interactive-request-error"

public extension IncomingMessage {

  @inlinable
  var interactiveRequestError: Swift.Error? {
    set { extra[irErrorKey] = newValue }
    get { return extra[irErrorKey] as? Swift.Error }
  }
}

public extension IncomingMessage {
  
  @inlinable
  var interactiveRequest: InteractiveRequest? {
    set { extra[irRequestKey] = newValue }
    get {
      guard let value   = extra[irRequestKey] else { return nil }
      guard let request = value as? InteractiveRequest else {
        log.error("interactiveRequest extra contains a foreign value: \(value)")
        assertionFailure("incorrect value in interactiveRequest extra")
        return nil
      }
      return request
    }
  }
}
