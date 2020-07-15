//
//  BlockElement.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public protocol BlockElement: Encodable {
  
  static var validInBlockTypes : [ Block.BlockTypeSet ] { get }
}

public protocol InteractiveBlockElement: BlockElement {
  
  var actionID : Block.ActionID            { get }
  var confirm  : Block.ConfirmationDialog? { get }
}

public protocol SelectElement: InteractiveBlockElement {
  
  var placeholder       : String { get } // max 150 chars
  var maxSelectedItems  : Int?   { get }
}

extension SelectElement {
  
  var isSingle : Bool { return maxSelectedItems == 1 }
}
