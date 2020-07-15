//
//  ConfirmationDialogModifier.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

public typealias ConfirmationDialog = Block.ConfirmationDialog

public struct ConfirmationDialogModifier<Content: Blocks>: Blocks {
  // TODO: We could build the dialog using modifiers as well, later.

  public typealias Body = Never
  
  public let dialog  : ConfirmationDialog
  public let content : Content

  @inlinable
  public init(_ dialog: ConfirmationDialog, content: Content) {
    self.dialog  = dialog
    self.content = content
  }
}

public extension Blocks {

  @inlinable
  func confirm(_ dialog: ConfirmationDialog)
       -> ConfirmationDialogModifier<Self>
  {
    return ConfirmationDialogModifier(dialog, content: self)
  }
}

public extension Blocks {
  
  @inlinable
  func confirm(title         : String = "Perform Action?",
               message       : String,
               confirmButton : String = "OK",
               cancelButton  : String = "Cancel",
               style         : ConfirmationDialog.Style = .none)
       -> ConfirmationDialogModifier<Self>
  {
    return confirm(ConfirmationDialog(
      title: title, text: Block.Text(message),
      confirm: confirmButton, deny: cancelButton,
      style: style)
    )
  }
}

extension ConfirmationDialogModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    let old = context.confirmationDialog
    context.confirmationDialog = dialog
    defer { context.confirmationDialog = old }
    
    if let old = old {
      context.log.notice(
        "nested confirmation dialogs inner will apply, not using \(old)")
    }
    
    try context.render(content)
  }
}
