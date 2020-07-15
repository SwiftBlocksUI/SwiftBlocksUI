//
//  ExpressEnvironment.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import protocol Blocks.EnvironmentKey
import struct   Blocks.EnvironmentValues
import struct   Logging.Logger

public enum LogEnvironmentKey: EnvironmentKey {
  public static var defaultValue : Logger { Logger(label: "μ.blocks") }
}

public extension EnvironmentValues {
  
  var log : Logger {
    set { self[LogEnvironmentKey.self] = newValue }
    get { return self[LogEnvironmentKey.self]     }
  }
}
