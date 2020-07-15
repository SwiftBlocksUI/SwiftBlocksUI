//
//  BlocksUIEnvironment.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import protocol Blocks.EnvironmentKey
import struct   Blocks.EnvironmentValues

public enum ClientEnvironmentKey: EnvironmentKey {
  public static var defaultValue : SlackClient { return SlackClient() }
}

public extension EnvironmentValues {
  
  var client : SlackClient {
    set { self[ClientEnvironmentKey.self] = newValue }
    get { return self[ClientEnvironmentKey.self]     }
  }
}
