//
//  BlockAction.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension InteractiveRequest {

  struct BlockAction: Decodable {
    
    public typealias Value = InteractiveRequest.View.State.Value
      // should be OK, this has some extra but should otherwise match
    
    public let actionID        : Block.ActionID
    public let blockID         : Block.BlockID
    public let actionTimestamp : String
    public let elementType     : Block.InteractiveElementType
    public let value           : Value? // e.g. don't parse button values
    
    enum CodingKeys: String, CodingKey {
      case actionID        = "action_id"
      case blockID         = "block_id"
      case actionTimestamp = "action_ts"
      case elementType     = "type"
    }

    public init(from decoder: Decoder) throws {
      typealias ElementType = Block.InteractiveElementType
      typealias ActionID    = Block.ActionID
      typealias BlockID     = Block.BlockID
      typealias Error       = InteractiveRequest.DecodingError

      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      actionID = try container.decode(ActionID.self, forKey: .actionID)
      blockID  = try container.decode(BlockID.self,  forKey: .blockID)
      actionTimestamp =
        try container.decode(String.self, forKey: .actionTimestamp)
      elementType =
        try container.decode(ElementType.self, forKey: .elementType)

      value = try? Value(from: decoder)
    }
  }
}

extension InteractiveRequest.BlockAction: CustomStringConvertible {

  public var description: String {
    var ms = "<BlockAction[\(actionID.id)]:"
    ms += " block=\(blockID.id)"
    ms += " type=\(elementType.rawValue)"
    ms += ">"
    return ms
  }
}
