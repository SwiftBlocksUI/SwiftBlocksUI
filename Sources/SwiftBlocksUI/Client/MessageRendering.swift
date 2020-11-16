//
//  MessageRendering.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Blocks
import enum SlackBlocksModel.Block

internal func renderMessage<B: Blocks>(_ message: B, supportsRichText: Bool)
                throws -> ( scope  : MessageResponse.ResponseType?,
                            blocks : [ Block ] )
{
  
  // TODO: Provide a proper environment?! Maybe even copy stuff from the
  //       BlocksEndpointResponse?
  let context = BlocksContext()
  context.surface = .message

  try context.render(message)
  
  let blocks : [ Block ]
  if let view = context.view {
    context.log.warning("a view was passed chat.sendMessage \(view)")
    blocks = view.blocks + context.blocks
  }
  else {
    blocks = context.blocks
  }
  
  return ( scope  : context.messageResponseScope,
           blocks : supportsRichText ? blocks : blocks.replacingRichText() )
}
