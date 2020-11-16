//
//  RequestView.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension InteractiveRequest {
  
  /**
   * The information an interactive request transmits about an associated View,
   * i.e. as part of a view submission or close.
   *
   * There is also the `View` struct, which is currently used just for
   * rendering. Both are very similar, but this one carries extra
   * information.
   */
  struct ViewInfo: Decodable, CustomStringConvertible {
    // Note: callback_id is empty when part of a view_submission, bug or
    //       feature? Would be useful.
    // TODO: this should _wrap_ SlackBlocksModel.View <===

    public let type               : SlackBlocksModel.View.ViewType
    public let id                 : ViewID // V016A2QTB8A
    public let applicationID      : ApplicationID
    public let teamID             : TeamID
    public let appInstalledTeamID : TeamID
    public let botID              : UserID // TBD
    public let externalID         : String
    public let privateMetaData    : String
    public let hash               : String // 1593521011.2f58e1f7
    public let state              : State?
    
    public let rootViewID         : ViewID
    public let previousViewID     : ViewID?
    
    // ignore: title,clear/notify_on_close,close,submit
    enum CodingKeys: String, CodingKey {
      case type, id, hash, state
      case botID              = "bot_id"
      case teamID             = "team_id"
      case privateMetaData    = "private_metadata"
      case previousViewID     = "previous_view_id"
      case rootViewID         = "root_view_id"
      case applicationID      = "app_id"
      case externalID         = "external_id"
      case appInstalledTeamID = "app_installed_team_id"
    }

    public var description: String {
      var ms = "<ViewInfo[\(id.id)]: \(type.rawValue)"
      if !externalID     .isEmpty { ms += " ext-id='\(externalID)'" }
      if let id = previousViewID  { ms += " previous=\(id.id)"      }
      if id != rootViewID         { ms += " root=\(rootViewID.id)"  }
      if !privateMetaData.isEmpty { ms += " meta='\(privateMetaData)'" }
      
      if let state = state {
        ms += " state=\(state)"
      }
      
      if hash.isEmpty { ms += " no-hash" }
      ms += ">"
      return ms
    }
  }
}

public extension InteractiveRequest.ViewInfo {

  struct State: Decodable {
    public typealias BlockID  = Block.BlockID
    public typealias ActionID = Block.ActionID
    
    public let values : [ BlockID : [ ActionID : Value ] ]
    
    enum CodingKeys: String, CodingKey {
      case values
    }
    
    struct StringCodingKey: CodingKey {
      let stringValue : String
      var intValue    : Int? { Int(stringValue) }
      init?(stringValue : String) { self.stringValue = stringValue      }
      init?(intValue    : Int)    { self.stringValue = String(intValue) }
    }

    public init(from decoder: Decoder) throws {
      // not sure why this is necessary, faults in an array error
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let map = try container.decode(BlockMap.self, forKey: .values)
      self.values = map.values
    }
    
    // MARK: - Some Collection Operations
    
    public var isEmpty : Bool {
      guard !values.isEmpty else { return true }
      // TODO: scan the arrays?
      return false
    }
    
    public subscript(_ blockID: BlockID) -> [ ActionID : Value ] {
      return values[blockID] ?? [:]
    }
    
    
    // MARK: - Decoding Support
    
    struct BlockMap: Decodable {
      let values : [ BlockID : [ ActionID : Value ] ]

      public init(from decoder: Decoder) throws {
        // not sure why this is necessary, faults in an array error
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        var values = [ BlockID : [ ActionID : Value ] ]()
        for key in container.allKeys {
          let id  = BlockID(key.stringValue)
          let map = try container.decode(ActionMap.self, forKey: key)
          assert(values[id] == nil)
          values[id] = map.values
        }
        
        self.values = values
      }
    }
    struct ActionMap: Decodable {
      let values : [ ActionID : Value ]

      public init(from decoder: Decoder) throws {
        // not sure why this is necessary, faults in an array error
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        var values = [ ActionID : Value ]()
        for key in container.allKeys {
          let id    = ActionID(key.stringValue)
          let value = try container.decode(Value.self, forKey: key)
          assert(values[id] == nil)
          values[id] = value
        }
        
        self.values = values
      }
    }

    public typealias Value = InteractiveRequest.FormValue
  }
}
