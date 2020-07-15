//
//  ViewPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum   SlackBlocksModel.Block
import struct SlackBlocksModel.View
import struct SlackBlocksModel.ExternalViewID

extension View: BlocksPrimitive {

  typealias APIBlock = SlackBlocksModel.View

  public func render(in context: BlocksContext) throws {
    // Only one View can be rendered in a context!
    guard context.view == nil else {
      context.log.warning(
        "detected multiple Views in a single context \(self)")
      assert(context.view == nil, "multiple views in context \(context)")
      return
    }
    
    let viewType  : SlackBlocksModel.View.ViewType
    switch context.surface {
      case .homeTab : viewType = .home
      case .modal   : viewType = .modal
      case .message:
        viewType        = .modal
        context.surface = .modal
    }
    
    if !context.blocks.isEmpty || context.currentBlock != nil {
      context.log.warning("starting view but blocks exist already?!")
      assertionFailure("starting view but blocks exist already \(context)")
    }

    // Note: we also render the view ID into the externalID.
    context.view = SlackBlocksModel.View(
      type          : viewType,
      callbackID    : id,
      externalID    : id.flatMap { ExternalViewID($0.id) },
      title         : title, closeTitle: nil, submitTitle: nil,
      clearOnClose  : false,
      notifyOnClose : closeAction != nil,
      blocks        : [], privateMetaData: nil
    )
    
    if context.surface == .message {
      context.surface = .modal
    }
    
    defer { _ = context.finishView(defaultTitle: title) }
    
    if case .invoke(.viewClose(let done)) = context.mode {
      guard let action = closeAction else {
        return context.log.notice(
          "invoked viewClose, but View doesn't have an action for that \(self)")
      }
      guard let done = done else {
        return context.log.trace("view close already processed")
      }
      try action(done)
      context.mode = .invoke(.viewClose(.none))
    }
    else {
      try context.render(content)
    }
  }
}
