//
//  Views.swift
//  SlackClient
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.View
import struct SlackBlocksModel.TriggerID
import struct SlackBlocksModel.ViewID
import struct SlackBlocksModel.UserID

public extension SlackClient {

  var views : Views { Views(client: self) }

  struct Views {
    
    public let client : SlackClient
    
    /**
     * https://api.slack.com/methods/views.open
     * Tier: 4
     *
     * Example:
     *
     *     let client = SlackClient()
     *     client.views.open(MyView(), with: action.triggerID) { error, json in
     *         ...
     *     }
     */
    public
    func open(_         view : View,
              with triggerID : TriggerID,
              yield          : @escaping ResponseHandler)
    {
      // The response has som extra data:
      // - state (values: [])
      // - hash
      // - root_view_id, app_id, bot_id
      struct Call: Encodable {
        let trigger_id : TriggerID
        let view       : View
      }
      let call = Call(trigger_id: triggerID, view: view)
      client.post(call, to: "views.open", yield: yield)
    }

    /**
     * https://api.slack.com/methods/views.publish
     * Tier: 4
     *
     * Example:
     *
     *     let client = SlackClient()
     *     client.views.publish(MyView(), userID: userID) {
     *         error, json in
     *         ...
     *     }
     */
    public
    func publish(_         view : View,
                 userID         : UserID,
                 hash           : String? = nil,
                 yield          : @escaping ResponseHandler)
    {
      // The response has som extra data:
      // - state (values: [])
      // - hash
      // - root_view_id, app_id, bot_id
      struct Call: Encodable {
        let user_id    : UserID
        let hash       : String?
        let view       : View
      }
      let call = Call(user_id: userID, hash: hash, view: view)
      client.post(call, to: "views.publish", yield: yield)
    }
    
    /**
     * https://api.slack.com/methods/views.update
     */
    public func update(_ view: View, with viewID: ViewID, hash: String? = nil,
                       yield: @escaping ResponseHandler)
    {
      // Note: either viewID or externalID is technically fine
      struct Call: Encodable {
        let view_id : ViewID
        let hash    : String?
        let view    : View
      }
      let call = Call(view_id: viewID, hash: hash, view: view)
      client.post(call, to: "views.update", yield: yield)
    }
    
    /**
     * https://api.slack.com/methods/views.push
     */
    public func push(_ view: View, with triggerID: TriggerID,
                       yield: @escaping ResponseHandler)
    {
      struct Call: Encodable {
        let trigger_id : TriggerID
        let view       : View
      }
      let call = Call(trigger_id: triggerID, view: view)
      client.post(call, to: "views.push", yield: yield)
    }
  }
}
