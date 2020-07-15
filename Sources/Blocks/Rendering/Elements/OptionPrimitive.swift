//
//  OptionPrimitive.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension Option: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    guard let block = context.currentBlock else {
      context.log.error("Attempt to use Option w/o a block!")
      return
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
          if state.isSelected(tag) { state.clientValues.insert(apiValue) }
        case .takeValues:
          if state.clientValues.contains(apiValue) { state.select(tag) }
      }
    }
    
    switch block {
    
      case .richText, .image, .context, .divider:
        return context.log
          .error("Attempt to use Option in a unsupported block: \(block)")

      case .section(var section):
        guard let accessory = section.accessory else {
          return context.log
            .error("Attempt to use Option as a Section accessory: \(block)")
        }
        guard case .staticSelect(var select) = accessory else {
          return context.log
            .error("Attempt to use Option in a unsupported accessory: \(block)")
        }
        select.addOption(title, value: apiValue, infoText: infoText, url: url)
        section.accessory    = .staticSelect(select)
        context.currentBlock = .section(section)
        
      case .actions(var actions): // this is appending to the last staticSelect
        guard !actions.elements.isEmpty else {
          return context.log
            .error("Attempt to use Option at Actions top-level: \(block)")
        }
        guard case .staticSelect(var select) = actions.elements.last else {
          return context.log
            .error("Attempt to use Option in a unsupported action: \(block)")
        }
        actions.elements.removeLast()
        select.addOption(title, value: apiValue, infoText: infoText, url: url)
        actions.elements.append(.staticSelect(select))
        context.currentBlock = .actions(actions)

      case .input(var input):
        guard case .staticSelect(var select) = input.element else {
          return context.log
            .error("Attempt to use Option in a unsupported input: \(block)")
        }
        select.addOption(title, value: apiValue, infoText: infoText, url: url)
        input.element = .staticSelect(select)
        context.currentBlock = .input(input)
    }
  }
}


import struct Foundation.URL
import enum   SlackBlocksModel.Block

fileprivate extension Block.MultiStaticSelect {
  
  // TBD: Can we use the generic `Group` to group options? Maybe if assigned
  //      a label? (Group { ... }.title("My Options")
  
  mutating func addOption(_ text   : Block.Text,
                          value    : String,
                          infoText : String? = nil,
                          url      : URL?    = nil)
  {
    // TODO: drop this, done by Option primitive now
    
    let option = Block.Option(text: text, value: value,
                              infoText: infoText, url: url)
    
    if var groups = optionGroups, !groups.isEmpty {
      // OK, we have option groups. Just add it to the last. This way we
      // can't have root-options, but better than nothing.
      let lastIdx = groups.index(before: groups.endIndex)
      groups[lastIdx].options.append(option)
    }
    else {
      options.append(option)
    }
  }
}
