//
//  Submit.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

@usableFromInline let submitActionID = ActionIDStyle.globalID(.init("submit"))
@usableFromInline let cancelActionID = ActionIDStyle.globalID(.init("cancel"))

/**
 * A Button suitable to submit a View.
 */
@inlinable
public func Submit(_ title: String = "") -> Button<Never> {
  return Button(actionID : submitActionID,
                title    : title, style: .primary,
                value    : nil, content: nil, url: nil, action: nil)
}

/**
 * A Button suitable to submit a View. This one takes an Action block
 * when the Blocks are used as an endpoint.
 */
@inlinable
public func Submit(_ title: String = "", action: @escaping Action)
            -> Button<Never>
{
  return Button(actionID : submitActionID,
                title    : title, style: .primary,
                value    : nil, content: nil, url: nil,
                action   : action)
}

/**
 * A Button suitable to submit a View. This one takes an Action block
 * when the Blocks are used as an endpoint.
 */
@inlinable
public func Submit(_ title: String = "", action: @escaping SyncAction)
            -> Button<Never>
{
  return Button(actionID : submitActionID,
                title    : title, style: .primary,
                value    : nil, content: nil, url: nil,
                action   : { response in try action(); response.end() })
}

/**
 * A Button suitable to cancel a View.
 */
@inlinable
public func Cancel(_ title: String = "") -> Button<Never> {
  return Button(actionID : cancelActionID,
                title    : title, style: .danger,
                value    : nil, content: nil, url: nil, action: nil)
}
