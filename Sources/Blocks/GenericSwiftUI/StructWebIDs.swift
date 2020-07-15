//
//  StructWebIDs.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.CallbackID
import enum   SlackBlocksModel.Block

extension CallbackID: WebRepresentableIdentifier {
  public var webID: String { id.webID }
}
extension Block.ActionID: WebRepresentableIdentifier {
  public var webID: String { id.webID }
}
