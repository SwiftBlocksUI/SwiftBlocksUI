//
//  OptionHelpers.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import enum SlackBlocksModel.Block

// MARK: - Applying Initial Options

extension Block.InteractiveElement {
  
  mutating func setInitialOptions(_ values: Set<String>) {
    switch self {
      case .staticSelect(var staticSelect):
        staticSelect.setInitialOptions(values)
        self = .staticSelect(staticSelect)
        
      case .checkboxes(var checkboxes):
        checkboxes.setInitialOptions(values)
        self = .checkboxes(checkboxes)

      case .button, .datePicker, .timePicker, .overflowMenu,
           .channelSelect, .conversationSelect, .userSelect, .externalSelect:
        assertionFailure("unexpected element for initial options")
        return globalBlocksLog.error("cannot set initial opts: \(self)")
    }
  }
}

extension Block.Accessory {
  
  mutating func setInitialOptions(_ values: Set<String>) {
    switch self {
      case .staticSelect(var staticSelect):
        staticSelect.setInitialOptions(values)
        self = .staticSelect(staticSelect)
        
      case .checkboxes(var checkboxes):
        checkboxes.setInitialOptions(values)
        self = .checkboxes(checkboxes)

      case .button, .datePicker, .timePicker, .image, .overflowMenu,
           .channelSelect, .conversationSelect, .userSelect, .externalSelect:
        assertionFailure("unexpected element for initial options")
        return globalBlocksLog.error("cannot set initial opts: \(self)")
    }
  }
}
