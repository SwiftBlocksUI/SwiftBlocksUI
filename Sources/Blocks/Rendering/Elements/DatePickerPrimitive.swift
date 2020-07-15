//
//  DatePickerPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.DateComponents
import struct Foundation.TimeInterval
import enum   SlackBlocksModel.Block

extension DatePicker: BlocksPrimitive {

  enum PickerRenderingError: Swift.Error {
    case internalInconsistency
  }
  
  public func render(in context: BlocksContext) throws {
    guard let block = context.currentBlock else {
      if context.surface == .modal {
        return try Input(label: title, content: { self })
                     .render(in: context)
      }
      else {
        return try Actions(content: { self }).render(in: context)
      }
    }
    
    switch block {
      case .richText, .image, .context:
        context.log
          .warning("Attempt to use DatePicker in a unsupported block: \(block)")
        context.closeBlock()
        return try render(in: context) // recurse
      case .divider:
        context.closeBlock()
        return try render(in: context) // recurse
    
      case .section, .actions, .input: break
    }

    switch block {
      case .richText, .image, .context, .divider:
        fatalError("unexpected state")
      
      case .section : try renderIntoSection(in: context)
      case .actions : try renderIntoActions(in: context)
      case .input   : try renderIntoInput  (in: context)
    }
  }
  
  private func buildAPIPicker(with actionID : Block.ActionID,
                              in    context : BlocksContext)
               -> Block.DatePicker
  {
    return .init(
      actionID    : actionID,
      placeholder : placeholder ?? title,
      initialDate : selection?.getter(),
      confirm     : context.confirmationDialog
    )
  }
  
  private var hasSubmitAction: Bool {
    return actionID == submitActionID
  }

  /// The proper API picker block is pushed to the context.
  private func afterBlockSetup(for actionID : Block.ActionID,
                               in   context : BlocksContext) throws
  {
    try context.invokeAction(action, for: self.actionID, id: actionID,
                             prefixMatch: false,
                             in: context)

    switch context.mode {
      case .invoke, .render:
        return
      case .takeValues: // (let state):
        try takeValues(for: actionID, in: context)
    }
  }
  
  
  // MARK: - Rendering
  
  private func renderIntoInput(in context: BlocksContext) throws {
    guard case .input(var input) = context.currentBlock else {
      assertionFailure("expected input block, got \(context)")
      throw PickerRenderingError.internalInconsistency
    }
    
    if action != nil {
      context.log.info(
        "DatePicker in Input/View w/ action, won't run (submit)")
    }
    
    // Our non-empty element in API hack
    guard input.containsDummyElement else { // element is taken already
      context.log
        .warning("Attempt to put multiple inputs in an Input block: \(input)")
      context.closeBlock()
      return try render(in: context) // recurse
    }
    
    let actionID  = context.currentActionID(for: self.actionID)
    input.element = .datePicker(buildAPIPicker(with: actionID, in: context))
    
    if !title.isEmpty && input.label.isEmpty {
      input.label = title
    }
    context.currentBlock = .input(input)
    
    try afterBlockSetup(for: actionID, in: context)
  }
  
  private func renderIntoActions(in context: BlocksContext) throws {
    guard case .actions(var actions) = context.currentBlock else {
      assertionFailure("expected actions block, got \(context)")
      throw PickerRenderingError.internalInconsistency
    }

    if context.level2Nesting != .none {
      context.log.warning(
        "Attempt to add nested Picker to Actions, please fix the nesting!")
      context.endLevelTwo()
    }

    context.startLevelTwo(.picker)
    defer { context.endLevelTwo() }

    let actionID = context.currentActionID(for: self.actionID)
    
    context.currentBlock = nil
    actions.elements.append(
      .datePicker(buildAPIPicker(with: actionID, in: context)))
    context.currentBlock = .actions(actions)

    try afterBlockSetup(for: actionID, in: context)
  }
  
  private func renderIntoSection(in context: BlocksContext) throws {
    guard case .section(var section) = context.currentBlock else {
      assertionFailure("expected section block, got \(context)")
      throw PickerRenderingError.internalInconsistency
    }
    
    guard section.accessory == nil else {
      context.log.error(
        "Attempt to add Picker to Section which already has an accessory!")
      return // TBD: throw? (more throwing in general?)
    }
        
    context.currentBlock = nil
    
    let actionID = context.currentActionID(for: self.actionID)
    section.accessory = .datePicker(buildAPIPicker(with: actionID, in: context))
    context.currentBlock = .section(section)
    
    try afterBlockSetup(for: actionID, in: context)
  }
  
  
  // MARK: - Take Values

  private func takeValues(for id: Block.ActionID, in context: BlocksContext)
                 throws
  {
    guard let selection = selection                   else { return }
    guard case .takeValues(let values) = context.mode else { return }
    
    guard let value = values.valueForActionID(id) else {
      // FIXME: only display for view submissions!
      context.log.notice("missing form value for \(id.id) (can be OK!)")
      #if false // only for view submissions!?
        selection.setter(nil) // hm
      #endif
      return
    }
    
    switch value {
      case let ymd as YearMonthDay:
        selection.setter(ymd)
      case let date as Date:
        selection.setter(.init(date))
      case let dateComponents as DateComponents:
        selection.setter(.init(dateComponents))
      case let v as Int:
        selection.setter(.init(Date(timeIntervalSince1970: TimeInterval(v))))
      case let v as String:
        guard let ymd = parseYMDString(v) else {
          context.log.error("could not parse DatePicker string value: \(v)")
          return // TBD: throw?
        }
        selection.setter(ymd)
      default:
        guard let ymd = parseYMDString(String(describing: value)) else {
          context.log.error(
            "could not parse unexpected DatePicker value: \(value)")
          return
        }
        context.log.warning("unexpected DatePicker value: \(value)")
        selection.setter(ymd)
    }
  }
}

private func parseYMDString(_ s: String) -> DatePicker.YearMonthDay? {
  // YYYY-mm-dd
  guard !s.isEmpty else { return nil }
  let parts = s.split(separator: "-", maxSplits: 3,
                      omittingEmptySubsequences: true)
  assert(parts.count == 3)
  guard parts.count == 3 else { return nil }
  guard let year  = Int(parts[0]),
        let month = Int(parts[1]),
        let day   = Int(parts[2]) else
  {
    assertionFailure("could not parse date: \(s)")
    return nil
  }
  
  return .init(year: Int16(year), month: UInt8(month), day: UInt8(day))
}
