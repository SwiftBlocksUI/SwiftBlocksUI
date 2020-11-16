//
//  IDs.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

// Static typing for IDs, make sure the proper stuff gets passed around.
// TODO: add some validation to the init's. Cheap.

public struct MessageID : StringID {
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct CallbackID : StringID {
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct TriggerID : StringID { // 12xxx8.4xxx8.bdxx22
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct ViewID : StringID { // V016A2QTB8A
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct UserID : StringID { // UCDK12345
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct ConversationID : StringID {
  public let id : String
  public init(_ id: String) { self.id = id }

  public var channelID : ChannelID? {
    return id.hasPrefix("C") ? .init(id) : nil
  }
}
public struct ChannelID : StringID { // yes, some contexts only allow channels!
  public let id : String
  public init(_ id: String) { self.id = id }
  
  public var conversationID : ConversationID { return .init(id) }
}

public struct TeamID : StringID { // TCDR12345
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct EnterpriseID : StringID {
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct UserGroupID : StringID {
  public let id : String
  public init(_ id: String) { self.id = id }
}

public struct ApplicationID : StringID { // A016NQ12345
  public let id : String
  public init(_ id: String) { self.id = id }
}

/**
 * A custom identifier that must be unique for all views in a workspace.
 */
public struct ExternalViewID : StringID {
  // TBD: For all views of the same app? Or for all-all views? Why does Slack
  //      care if it is external?
  public let id : String
  public init(_ id: String) { self.id = id }
}


// MARK: - Descriptions

extension ChannelID: CustomStringConvertible {
  public var description: String { return "<ChID:\(id)>" }
}
extension ConversationID: CustomStringConvertible {
  public var description: String { return "<ConvID:\(id)>" }
}
extension MessageID: CustomStringConvertible {
  public var description: String { return "<MID:\(id)>" }
}
extension UserID: CustomStringConvertible {
  public var description: String { return "<UID:\(id)>" }
}
extension ApplicationID: CustomStringConvertible {
  public var description: String { return "<App:\(id)>" }
}
