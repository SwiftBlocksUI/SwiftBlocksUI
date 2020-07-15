//
//  ViewClosed.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension InteractiveRequest {

  struct ViewClosed: Decodable, CustomStringConvertible {
    
    public let verificationToken : String        // Du123456789123456789123o
    public let applicationID     : ApplicationID // A016N12345C
    public let isCleared         : Bool
    public let team              : Team
    public let user              : User
    public let view              : ViewInfo
    
    enum CodingKeys: String, CodingKey {
      case verificationToken = "token"
      case team, user, view
      case applicationID = "api_app_id"
      case isCleared     = "is_cleared"
    }
    
    public var description: String {
      var ms = "<ViewClosed:"
      ms += " @\(user.id.id)(\(user.username)"
      ms += " \(view)"
      if verificationToken.isEmpty { ms += " no-token" }
      ms += ">"
      return ms
    }
  }
}

public extension InteractiveRequest.ViewClosed {

  @inlinable
  var container : InteractiveRequest.Container? {
    return .view(id: view.id, view: view)
  }
}
