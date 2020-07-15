//
//  Action.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * An Action can respond to the client in various ways. This objects lets the
 * Action trigger the desired response.
 *
 * Possible responses:
 * - `end`     (no specific action, close the View)
 * - `update`  (re-render the same Blocks into the originating view or message)
 * - `replace` (replace the view/message w/ completely new blocks)
 * - `push`    (push a new view to the open modal, or send a message)
 * - `clear`   (close the whole modal, or _delete_ the interactive message)
 *
 * IMPORTANT: Actions are given 3 seconds to call `end` (or a different result),
 *            otherwise the client will show an error.
 */
public protocol ActionResponse : AnyObject {

  /**
   * Close the `View` or do nothing if the action was triggered by a message.
   * If it is a `View`, it will "pop" the view, not necessarily close the whole
   * modal. Use `clear` for that.
   */
  func end()
  
  /// Re-render the same root view / message again.
  func update()
  
  /// Replace the originating view or message with the given blocks.
  func replace<B: Blocks>(@BlocksBuilder with blocks: () -> B)

  /**
   * If the request is coming from a modal, this pushes a new View to the modal.
   * If the source was a message, this will send a message to the same
   * container.
   */
  func push<B: Blocks>(@BlocksBuilder _ blocks: () -> B)
  
  /**
   * This closes the whole modal or _deletes_ the originating message.
   * 
   * Note that modals can only be closed in response to a view submit (there
   * is no views.close/clear API method).
   */
  func clear()
}

public extension ActionResponse { // aliases

  /**
   * If the request is coming from a modal, this pushes a new View to the modal.
   * If the source was a message, this will send a message to the same
   * container.
   *
   * This is just a different name for `push`, more suitable for message
   * contexts.
   */
  func send<B: Blocks>(@BlocksBuilder _ blocks: () -> B) {
    push(blocks)
  }

  /**
   * This closes the whole modal or _deletes_ the originating message.
   *
   * This is just a different name for `clear`, more suitable for message
   * contexts.
   */
  func delete() {
    clear()
  }
}

/**
 * An action block which can be triggered by interactive elements in Blocks,
 * like Buttons.
 *
 * An `Action` can be asynchronous, it MUST call an `ActionResponse` method
 * once it completed.
 *
 * IMPORTANT: Actions are given 3 seconds to call `end` (or a different result),
 *            otherwise the client will show an error.
 */
public typealias Action = ( _ completion: ActionResponse ) throws -> Void

/**
 * An (synchronous) action block which can be triggered by interactive elements
 * in Blocks, like Buttons.
 *
 * IMPORTANT: Actions are given 3 seconds to complete, otherwise the client will
 *            show an error.
 *
 * This version can't return a specific response:
 * - If the view triggered the action, the view will close after the action
 * - If a message triggered the action, no extra thing is going to happen
 *
 * Note that while the Action itself runs synchronous, it can send out messages
 * etc. It can even use `setTimeout` or `nextTick` to send something later on.
 *
 * Most elements also support the asynchronous `Action` variant.
 */
public typealias SyncAction = () throws -> Void
