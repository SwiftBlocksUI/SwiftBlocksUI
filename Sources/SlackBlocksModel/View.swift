//
//  View.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A Slack API View (either a modal or a home tab)
 *
 * There is also `InteractiveRequest.ViewInfo`.
 */
public struct View: Encodable {
  // TBD: is this correct?
 
  public enum ViewType: String, Codable {
    case modal, home
  }
  
  public var type            : ViewType
  public var callbackID      : CallbackID?
  public var externalID      : ExternalViewID?
  
  public var title           : String {// max 24 chars
    didSet { assert(isValid) }
  }
  public var closeTitle      : String? // max 24 chars
  public var submitTitle     : String? // max 24 chars
  public var clearOnClose    : Bool    // modal only
  public var notifyOnClose   : Bool    // modal only

  public var blocks          : [ Block ]
  
  public var privateMetaData : String? // max 3k chars
  
  public init(type            : ViewType        = .modal,
              callbackID      : CallbackID?     = nil,
              externalID      : ExternalViewID? = nil,
              title           : String,
              closeTitle      : String?         = nil,
              submitTitle     : String?         = nil,
              clearOnClose    : Bool            = false,
              notifyOnClose   : Bool            = false,
              blocks          : [ Block ]       = [],
              privateMetaData : String?         = nil)
  {
    self.type            = type
    self.callbackID      = callbackID
    self.externalID      = externalID
    self.title           = title
    self.closeTitle      = closeTitle
    self.submitTitle     = submitTitle
    self.clearOnClose    = clearOnClose
    self.notifyOnClose   = notifyOnClose
    self.blocks          = blocks
    self.privateMetaData = privateMetaData
  }
  
  
  // MARK: - Validate
  
  public var isValid : Bool {
    guard title.count < 25 else { return false }
    return true
  }

  
  // MARK: - Encoding
  
  enum CodingKeys: String, CodingKey {
    case type, title, blocks
    case closeTitle      = "close"
    case submitTitle     = "submit"
    case privateMetaData = "private_metadata"
    case callbackID      = "callback_id"
    case clearOnClose    = "clear_on_close"
    case notifyOnClose   = "notify_on_close"
    case externalID      = "external_id"
  }
  
  public func encode(to encoder: Encoder) throws {
    typealias Text = Block.Text
    
    assert(isValid)
    
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type,        forKey: .type)
    try container.encode(Text(title), forKey: .title) // What in Home tabs?
    try container.encode(blocks,      forKey: .blocks)
    
    if let v = callbackID { try container.encode(v, forKey: .callbackID) }
    if let v = externalID { try container.encode(v, forKey: .externalID) }

    if let v = privateMetaData, !v.isEmpty {
      try container.encode(v, forKey: .privateMetaData)
    }

    if type == .modal {
      if clearOnClose  { try container.encode(true, forKey: .clearOnClose)  }
      if notifyOnClose { try container.encode(true, forKey: .notifyOnClose) }

      if let v = closeTitle {
        try container.encode(Text(v), forKey: .closeTitle)
      }
      if let v = submitTitle {
        try container.encode(Text(v), forKey: .submitTitle)
      }
    }
    else {
      assert(!clearOnClose      && !notifyOnClose &&
              closeTitle == nil &&  submitTitle == nil)
    }
  }
}
