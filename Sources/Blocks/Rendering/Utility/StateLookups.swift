//
//  StateLookups.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block
import enum SlackBlocksModel.InteractiveRequest

extension Dictionary where Key   == Block.BlockID,
                           Value == [ Block.ActionID
                                    : InteractiveRequest.View.State.Value ]
{

  @usableFromInline
  func valueForActionID(_ id: Block.ActionID) -> Any? {
    for state in self.values {
      if let value = state[id] {
        return value.value
      }
    }
    return nil
  }
}
