//
//  Overflow.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * This is a button w/ a dropdown menu.
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#overflow
   */
  struct Overflow: InteractiveBlockElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .actions ]
                 
    public let actionID : ActionID
    public let options  : [ Option ]
    public let confirm  : ConfirmationDialog?
    
    public init(actionID : ActionID,
                options  : [ Option ],
                confirm  : ConfirmationDialog? = nil)
    {
      self.actionID = actionID
      self.options  = options
      self.confirm  = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, options, confirm
      case actionID = "action_id"
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("overflow", forKey: .type)
      try container.encode(actionID,   forKey: .actionID)
      try container.encode(options,    forKey: .options)
      if let v = confirm { try container.encode(v, forKey: .confirm) }
    }
  }
}


// MARK: - Description

extension Block.Overflow: CustomStringConvertible {

  @inlinable
  public var description: String {
    var ms = "<Overflow[\(actionID.id)]:"
    
    if      options.isEmpty    { ms += " EMPTY"      }
    else if options.count == 1 { ms += " single-option=\(options[0])" }
    else                       { ms += " \(options)" }
    
    if let v = confirm     { ms += " \(v)"               }
    ms += ">"
    return ms
  }
}
