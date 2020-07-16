//
//  CheckboxPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension Checkbox: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    guard let block = context.currentBlock else {
      return try CheckboxGroup(title.value, content: { self })
                   .render(in: context)
    }
    
    let tag = context.consumePendingTag()
           ?? url.flatMap(AnyHashable.init)
           ?? AnyHashable(title)
        
    let infoText = self.infoText ?? context.environment[keyPath: \.infoText]
    let apiValue : String = { // this is the API key value we match on
      switch optionID {
        case .auto:
          if let id = context.consumePendingID()?.webID { return id }
          if let tagID = tag.base as? WebRepresentableIdentifier {
            return tagID.webID
          }
          return context.currentElementID.webID
        case .elementID:
          return context.currentElementID.webID
        case .value(let id):
          return id
      }
    }()
    
    if let state = context.selectionState {
      switch context.mode {
        case .invoke:
          break
        case .render:
          if isOn?.getter() ?? false {
            state.clientValues.insert(apiValue)
          }
        case .takeValues:
          if let isOn = isOn {
            isOn.setter(state.clientValues.contains(apiValue))
          }
      }
    }
    
    switch block {
    
      case .richText, .image, .context, .divider:
        return context.log
          .error("Attempt to use Checkbox in a unsupported block: \(block)")

      case .section(var section):
        guard let accessory = section.accessory else {
          return context.log
            .error("Attempt to use Checkbox as a Section accessory: \(block)")
        }
        guard case .checkboxes(var checkboxes) = accessory else {
          return context.log
            .error("Attempt to use Checkbox in a unsupported accessory: \(block)")
        }
        checkboxes.addOption(title, value: apiValue, infoText: infoText, url: url)
        section.accessory    = .checkboxes(checkboxes)
        context.currentBlock = .section(section)
        
      case .actions(var actions): // this is appending to the last staticSelect
        guard !actions.elements.isEmpty else {
          return context.log
            .error("Attempt to use Checkbox at Actions top-level: \(block)")
        }
        guard case .checkboxes(var checkboxes) = actions.elements.last else {
          return context.log
            .error("Attempt to use Checkbox in a unsupported action: \(block)")
        }
        actions.elements.removeLast()
        checkboxes.addOption(title, value: apiValue, infoText: infoText, url: url)
        actions.elements.append(.checkboxes(checkboxes))
        context.currentBlock = .actions(actions)

      case .input(var input):
        if input.containsDummyElement {
          return try CheckboxGroup("", content: { self }) // TBD: title
                       .render(in: context)
        }
        
        guard case .checkboxes(var checkboxes) = input.element else {
          return context.log
            .error("Attempt to use Checkbox in a unsupported input: \(block)")
        }
        checkboxes.addOption(title, value: apiValue, infoText: infoText, url: url)
        input.element = .checkboxes(checkboxes)
        context.currentBlock = .input(input)
    }
  }
}


import struct Foundation.URL
import enum   SlackBlocksModel.Block

extension Block.Checkboxes {
  
  mutating func addOption(_ text   : Block.Text,
                          value    : String,
                          infoText : String? = nil,
                          url      : URL?    = nil)
  {
    // TODO: drop this, done by Option primitive now
    let option = Block.Option(text: text, value: value,
                              infoText: infoText, url: url)
    options.append(option)
  }
}
