//
//  OpenModal.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackClient.SlackClient
import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.View
import enum   SlackBlocksModel.InteractiveRequest
import struct SlackBlocksModel.TriggerID

public extension SlackClient.Views {

  fileprivate struct CouldNotProcessView: Swift.Error {} // FIXME

  // TODO: make it a BlocksBuilder, but figure out how to do the yield.
  // TODO: replace arguments w/ ViewState in Context
  // All this probably belongs into the specific endpoint?
  
  func open<V>(_ view: V, with triggerID: SlackBlocksModel.TriggerID,
               yield: @escaping (SlackClient.APIError?, [String : Any]) -> Void)
       where V: Blocks
  {
    var apiView : SlackBlocksModel.View
    
    do {
      let context = BlocksContext()
      context.surface = .modal
      
      try context.render(view)

      if context.view == nil {
        context.log.warning("no explicit view passed to views.open \(view)")
      }
      context.finishView(defaultTitle: "\(type(of: view))")

      guard let ctxView = context.view else {
        assertionFailure("missing view even after finish ... \(context)")
        return yield(SlackClient.APIError.noValidJSONResponseContent(nil), [:])
      }
      apiView = ctxView
    }
    catch {
      //log.error("Failed to render blocks: \(blocks)\n  error: \(error)")
      //return sendStatus(500)
      assertionFailure("error: \(error)")
      return yield(SlackClient.APIError.noValidJSONResponseContent(nil), [:])
    }
    
    self.open(apiView, with: triggerID, yield: yield)
  }
}
