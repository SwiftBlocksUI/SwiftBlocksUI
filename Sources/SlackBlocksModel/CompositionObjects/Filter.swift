//
//  Filter.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * A Filter object for conversation lists.
   *
   * Docs: https://api.slack.com/reference/block-kit/composition-objects#filter_conversations
   */
  struct Filter: Encodable {
    
    public struct ConversationTypes: OptionSet, Encodable {
      public let rawValue : UInt8
      public init(rawValue: UInt8) { self.rawValue = rawValue }
      
      public static let im        = ConversationTypes(rawValue: 1 << 1)
      public static let mpim      = ConversationTypes(rawValue: 1 << 2)
      public static let `public`  = ConversationTypes(rawValue: 1 << 3)
      public static let `private` = ConversationTypes(rawValue: 1 << 4)
      
      var stringValues : [ String ] {
        var v = [ String ](); v.reserveCapacity(4)
        if contains(.im)        { v.append("im")        }
        if contains(.mpim)      { v.append("mpim")      }
        if contains(.`public`)  { v.append("`public`")  }
        if contains(.`private`) { v.append("`private`") }
        return v
      }
      public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValues)
      }
    }
    
    public var includeConversationTypes      : ConversationTypes?
    public var excludeExternalSharedChannels : Bool?
    public var excludeBotUsers               : Bool?
    
    public init(includeConversationTypes      : ConversationTypes? = nil,
                excludeExternalSharedChannels : Bool? = nil,
                excludeBotUsers               : Bool? = nil)
    {
      self.includeConversationTypes      = includeConversationTypes
      self.excludeExternalSharedChannels = excludeExternalSharedChannels
      self.excludeBotUsers               = excludeBotUsers
    }
    
    // MARK: - Coding
    
    enum CodingKeys: String, CodingKey {
      case includeConversationTypes      = "include"
      case excludeExternalSharedChannels = "exclude_external_shared_channels"
      case excludeBotUsers               = "exclude_bot_users"
    }
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      if let v = includeConversationTypes {
        try container.encode(v.stringValues, forKey: .includeConversationTypes)
      }
      if let v = excludeExternalSharedChannels {
        try container.encode(v, forKey: .excludeExternalSharedChannels)
      }
      if let v = excludeBotUsers {
        try container.encode(v, forKey: .excludeBotUsers)
      }
    }
  }
}
