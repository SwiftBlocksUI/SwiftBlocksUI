//
//  BlocksEnvironment.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import enum   SlackBlocksModel.InteractiveRequest
import struct SlackBlocksModel.TriggerID
import struct SlackBlocksModel.TeamID
import struct SlackBlocksModel.UserID
import struct SlackBlocksModel.ConversationID
import struct SlackBlocksModel.CallbackID
import struct SlackBlocksModel.SlashRequest


// This is a little fishy, but making everything optional is inconvenient
// for environment keys.

extension InteractiveRequest.Team {
  static let none = Self.init(id: TeamID(""), domain: "")
}
extension InteractiveRequest.User {
  static let none = Self.init(id: UserID(""), username: "", teamID: TeamID(""))
}
extension InteractiveRequest.Conversation {
  static let none = Self.init(id: ConversationID(""), name: "")
}
extension CallbackID { static let none = CallbackID("") }
extension TriggerID  { static let none = TriggerID ("") }


// MARK: - Environment Key Types

public enum TeamEnvironmentKey: EnvironmentKey {
  public static var defaultValue : InteractiveRequest.Team { .none }
}
public enum UserEnvironmentKey: EnvironmentKey {
  public static var defaultValue : InteractiveRequest.User { .none }
}
public enum ConversationEnvironmentKey: EnvironmentKey {
  public static var defaultValue : InteractiveRequest.Conversation { .none }
}

public enum EnterpriseEnvironmentKey: EnvironmentKey {
  public static var defaultValue : InteractiveRequest.Enterprise? { .none }
}

public enum SlashCommandEnvironmentKey: EnvironmentKey {
  public static var defaultValue = ""
}
public enum CallbackIDEnvironmentKey: EnvironmentKey {
  public static var defaultValue : CallbackID { .none }
}
public enum TriggerIDEnvironmentKey: EnvironmentKey {
  public static var defaultValue : TriggerID { .none }
}
public enum ResponseURLEnvironmentKey: EnvironmentKey {
  public static var defaultValue : URL? { nil }
}

public enum MessageTextEnvironmentKey: EnvironmentKey {
  public static var defaultValue : String { "" }
}

public enum InfoTextEnvironmentKey: EnvironmentKey {
  public static var defaultValue : String? { nil }
}

public enum SlashEnvironmentKey: EnvironmentKey {
  public static var defaultValue: SlashRequest? { .none }
}


// MARK: - EnvironmentKey Value Access

public extension EnvironmentValues {
  
  @inlinable var team : InteractiveRequest.Team {
    set { self[TeamEnvironmentKey.self] = newValue }
    get { return self[TeamEnvironmentKey.self]     }
  }

  @inlinable var user : InteractiveRequest.User {
    set { self[UserEnvironmentKey.self] = newValue }
    get { return self[UserEnvironmentKey.self]     }
  }

  @inlinable var conversation : InteractiveRequest.Conversation {
    set { self[ConversationEnvironmentKey.self] = newValue }
    get { return self[ConversationEnvironmentKey.self]     }
  }
  @inlinable var channel : InteractiveRequest.Conversation {
    set { conversation = newValue }
    get { return conversation     }
  }

  @inlinable var enterprise : InteractiveRequest.Enterprise? {
    set { self[EnterpriseEnvironmentKey.self] = newValue }
    get { return self[EnterpriseEnvironmentKey.self]     }
  }
}

public extension EnvironmentValues {

  @inlinable var slashCommand : String {
    set {
      self[SlashCommandEnvironmentKey.self] =
        newValue.hasPrefix("/")
        ? String(newValue.dropFirst())
        : newValue
    }
    get { return self[SlashCommandEnvironmentKey.self]     }
  }
}

public extension EnvironmentValues {

  @inlinable var messageText : String {
    set { self[MessageTextEnvironmentKey.self] = newValue }
    get { return self[MessageTextEnvironmentKey.self]     }
  }
}

public extension EnvironmentValues {
  
  @inlinable var callbackID : CallbackID {
    set { self[CallbackIDEnvironmentKey.self] = newValue }
    get { return self[CallbackIDEnvironmentKey.self]     }
  }
  @inlinable var triggerID : TriggerID {
    set { self[TriggerIDEnvironmentKey.self] = newValue }
    get { return self[TriggerIDEnvironmentKey.self]     }
  }
  
  @inlinable var responseURL : URL? {
    set { self[ResponseURLEnvironmentKey.self] = newValue }
    get { return self[ResponseURLEnvironmentKey.self]     }
  }
}

public extension EnvironmentValues {

  @inlinable var infoText : String? {
    set { self[InfoTextEnvironmentKey.self] = newValue }
    get { return self[InfoTextEnvironmentKey.self]     }
  }
}

public extension EnvironmentValues {
  
  @inlinable var slashRequest: SlashRequest? {
    set { self[SlashEnvironmentKey.self] = newValue }
    get { return self[SlashEnvironmentKey.self]     }
  }
}
