//
//  BlockActions.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension InteractiveRequest {
  
  /**
   * Block actions are sent when form elements change their values, e.g. if
   * a button is pressed or a date is selected in a date picker.
   *
   * Note that components contained in `input` blocks do NOT trigger block
   * actions.
   *
   * Docs: https://api.slack.com/reference/interaction-payloads/block-actions
   */
  struct BlockActions: Decodable {
    
    /**
     * The container from which the message was triggered, either a view
     * or a message.
     */
    public enum Container {
      
      case view   (id: ViewID, view: ViewInfo?)
      
      case message       (messageID      : MessageID,
                          conversationID : ConversationID,
                          isEphemeral    : Bool)
      
      /// This is a context where something acts upon a different message
      /// (vs the source being the message itself) I.e. a messageAction.
      case contextMessage(messageID      : MessageID,
                          conversationID : ConversationID,
                          isEphemeral    : Bool)
    }

    public let verificationToken : String        // Du123456789123456789123o
    public let applicationID     : ApplicationID // A016N12345C
    public let triggerID         : TriggerID     // 1211234558162.4....176a..e7
    public let team              : Team
    public let user              : User
    public let actions           : [ BlockAction ]
    public let container         : Container
    public let responseURL       : URL? // for message containers
    public let state             : ViewInfo.State

    // MARK: - Decoding
    
    enum CodingKeys: String, CodingKey {
      case team, user, view, actions, container, state
      case verificationToken = "token"
      case applicationID     = "api_app_id"
      case triggerID         = "trigger_id"
      case responseURL       = "response_url"
    }
    
    private struct ContainerTypeHolder: Codable {
      enum ContainerType: String, Codable {
        case view
        case message
      }
      
      let type           : ContainerType
      let viewID         : ViewID? // V016Q9M11HT
      let messageID      : MessageID?
      let conversationID : ConversationID?
      let isEphemeral    : Bool?
      
      enum CodingKeys: String, CodingKey {
        case type
        case viewID         = "view_id"
        case messageID      = "message_ts"
        case conversationID = "channel_id"
        case isEphemeral    = "is_ephemeral"
      }
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      verificationToken =
        try container.decode(String.self, forKey: .verificationToken)
      applicationID =
        try container.decode(ApplicationID.self, forKey: .applicationID)
      
      triggerID   = try container.decode(TriggerID.self, forKey: .triggerID)

      // Optional doesn't work here? Codable roxx.
      responseURL = try? container.decode(URL     .self, forKey: .responseURL)
      
      team        = try container.decode(Team           .self, forKey: .team)
      user        = try container.decode(User           .self, forKey: .user)
      actions     = try container.decode([ BlockAction ].self, forKey: .actions)
      
      // New starting 2020-09-29:
      state       = (try? container.decode(ViewInfo.State.self, forKey: .state))
                 ?? ViewInfo.State()

      
      // decode the action container (not the Decodable container :-)
      let containerType =
        try container.decode(ContainerTypeHolder.self, forKey: .container)
      switch containerType.type {
      
        case .view:
          guard let id = containerType.viewID else {
            throw DecodingError.missingID
          }
          let viewInfo = try container.decode(ViewInfo?.self, forKey: .view)
          self.container = .view(id: id, view: viewInfo)
          
        case .message:
          guard let messageID = containerType.messageID else {
            throw DecodingError.missingID
          }
          guard let conversationID = containerType.conversationID else {
            throw DecodingError.missingID
          }
          self.container = .message(messageID      : messageID,
                                    conversationID : conversationID,
                                    isEphemeral:
                                        containerType.isEphemeral ?? false)
      }
    }
  }
}

extension InteractiveRequest.BlockActions: CustomStringConvertible {

  public var description: String {
    var ms = "<BlockActions:"
    ms += " @\(user.id.id)(\(user.username))"
    ms += " \(container)"
    ms += " \(actions)"
    if verificationToken.isEmpty { ms += " no-token"      }
    if triggerID.id     .isEmpty { ms += " no-trigger-id" }
    ms += ">"
    return ms
  }
}

extension InteractiveRequest.BlockActions.Container: CustomStringConvertible {

  public var description: String {
    switch self {
      case .view(let id, _):
        return "<View: \(id.id)>"
    
      case .message(let mid, let cid, let isEphemeral):
        return "<Msg[#\(cid.id):\(mid.id)]\(isEphemeral ? " ephemeral" : "")>"
        
      case .contextMessage(let mid, let cid, let isEphemeral):
        return "<OnMsg[#\(cid.id):\(mid.id)]\(isEphemeral ? " ephemeral" : "")>"
    }
  }
}
