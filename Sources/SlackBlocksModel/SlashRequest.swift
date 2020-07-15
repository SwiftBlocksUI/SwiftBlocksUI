//
//  SlashRequest.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public struct SlashRequest {
  // TODO: make it a CoW struct
  
  // Consolidate the API a little
  public typealias User         = InteractiveRequest.User
  public typealias Team         = InteractiveRequest.Team
  public typealias Enterprise   = InteractiveRequest.Enterprise
  public typealias Conversation = InteractiveRequest.Conversation

  /**
   * Deprecated, use signed secrets instead.
   *
   * This is the verification token available in the app credentials section.
   */
  public let verificationToken : String // D1234567899JB123456789Yo
  
  public let triggerID         : TriggerID // 1xxx8.4yyy8.azz4 (longer)
  public let responseURL       : URL       // https://hooks.slack/commands/Tx/12
  
  public let team              : Team         // TC1234568, zeezide
  public let conversation      : Conversation // GD1234563, "privategroup"
  public let user              : User         // UCD123456, "slack1"
  public let enterprise        : Enterprise?

  public let command           : String // "/vaca"
  public let text              : String // "moon"
  
  public init(verificationToken : String,
              triggerID         : TriggerID,
              responseURL       : URL,
              team              : Team,
              conversation      : Conversation,
              user              : User,
              enterprise        : Enterprise?,
              command           : String,
              text              : String)
  {
    self.verificationToken = verificationToken
    self.triggerID         = triggerID
    self.responseURL       = responseURL
    self.team              = team
    self.conversation      = conversation
    self.user              = user
    self.enterprise        = enterprise
    self.command           = command
    self.text              = text
  }
}
