//
//  SelectionState.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * A helper object to handle selection state in the BlocksContext.
 *
 * During the takeValues phase, this is prefilled with the clientValues within
 * the view submission.
 * The Option blocks inspect this, and if it matches their `id`, they
 * add their `tag` to the selection.
 *
 * During the rendering phase the Options blocks check whether their `tag` is
 * included in the selection, if so, they add their `id` to the clientValues.
 */
protocol SelectionState : AnyObject {

  // MARK: - Client side representation
  
  var clientValues : Set<String> { get set }

  // MARK: - Server side representation
  
  func select    <Tag: Hashable>(_ tag: Tag)
  func isSelected<Tag: Hashable>(_ tag: Tag) -> Bool
}
