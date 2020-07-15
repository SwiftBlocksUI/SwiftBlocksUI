//
//  EnvironmentKey.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2020 ZeeZide GmbH. All rights reserved.
//

public protocol EnvironmentKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
}
