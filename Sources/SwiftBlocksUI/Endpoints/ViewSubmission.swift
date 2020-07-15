//
//  ViewSubmission.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class    MacroApp.ServerResponse
import protocol MacroApp.Endpoints
import protocol MacroApp.RouteKeeper
import enum     SlackBlocksModel.InteractiveRequest
import BlocksExpress

public struct ViewSubmission: Endpoints {
  
  public typealias Handler =
    ( InteractiveRequest.ViewSubmission, ServerResponse ) throws -> Void
  
  public let id      : String?
  public let handler : Handler
  
  @inlinable
  public init(id: String? = nil, _ execute : @escaping Handler) {
    self.id      = id
    self.handler = execute
  }
  
  @inlinable
  public func attachToRouter(_ router: RouteKeeper) throws {
    router.viewSubmission(id: id, handler)
  }
}
