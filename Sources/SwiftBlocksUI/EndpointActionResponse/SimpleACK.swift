//
//  SimpleACK.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension BlocksEndpointResponse {
  
  // MARK: - Simple ACK
  
  public func end() {
    if sendValidationErrors() { return } // errors sent
    endWithSimpleACK()
  }
}
