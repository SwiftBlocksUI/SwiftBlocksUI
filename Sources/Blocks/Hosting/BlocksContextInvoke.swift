//
//  BlocksContextInvoke.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block
import enum SlackBlocksModel.InteractiveRequest

extension BlocksContext {
  
  @inlinable
  func invokeAction(_        action : Action?,
                    for actionStyle : ActionIDStyle,
                    id              : Block.ActionID,
                    prefixMatch     : Bool = false,
                    in      context : BlocksContext)
         throws
  {
    // Note: This is going to gain more parameters, i.e. the actionID?
    
    switch context.mode {
      case .render, .takeValues:
        break
        
      case .invoke(let invocationType):
        switch invocationType {
          
          case .submit(.none), .actions(_, .none):
            break // already processed
          
          case .submit(.some(let done)):
            guard let action = action, actionStyle == submitActionID else {
              return
            }
            context.mode = .invoke(.submit(nil))
            try action(done)
            
          case .actions(let blockActions, .some(let done)):
            guard let action = action else { return }
            
            func match(_ action: InteractiveRequest.BlockAction) -> Bool {
              if action.actionID == id { return true }
              if prefixMatch {
                if action.actionID.id.hasPrefix(id.id) { return true }
              }
              return false
            }
            
            if blockActions.contains(where: match) {
              context.mode = .invoke(.actions(blockActions, nil))
              try action(done)
            }
            
          case .viewClose:
            break // directly handled by View
        }
    }
  }
}
