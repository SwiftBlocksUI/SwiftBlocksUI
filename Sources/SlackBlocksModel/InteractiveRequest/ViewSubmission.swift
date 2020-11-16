//
//  ViewSubmission.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension InteractiveRequest {

  struct ViewSubmission: Decodable, CustomStringConvertible {
    
    public let verificationToken : String        // Du123456789123456789123o
    public let applicationID     : ApplicationID // A016N12345C
    public let triggerID         : TriggerID     // 1211234558162.4....176a..e7
    public let responseURLs      : [ URL ]
    public let team              : Team
    public let user              : User
    public let view              : ViewInfo
    
    enum CodingKeys: String, CodingKey {
      case team, user, view
      case verificationToken = "token"
      case applicationID     = "api_app_id"
      case triggerID         = "trigger_id"
      case responseURLs      = "response_urls"
    }

    public var description: String {
      var ms = "<ViewSubmission:"
      ms += " @\(user.id.id)(\(user.username))"
      ms += " \(view)"
      if !responseURLs    .isEmpty { ms += " urls=\(responseURLs)" }
      if verificationToken.isEmpty { ms += " no-token"      }
      if triggerID.id     .isEmpty { ms += " no-trigger-id" }
      ms += ">"
      return ms
    }
  }
}

public extension InteractiveRequest.ViewSubmission {

  @inlinable
  var container : InteractiveRequest.Container? {
    return .view(id: view.id, view: view)
  }
}
