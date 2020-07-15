//
//  Checkboxes.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * Note: Not allowed in messages, only in home tabs and modals!
   *
   * Docs: https://api.slack.com/reference/block-kit/block-elements#checkboxes
   */
  struct Checkboxes: BlockElement {

    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .actions, .input ]
    public static let validInSurfaces   : [ BlockSurfaceSet ]
                                        = [ .homeTabs, .modals ]
    
    public let actionID       : ActionID
    public var options        : [ Option ]
    public var initialOptions : [ Option ]?
    public let confirm        : ConfirmationDialog?
    
    public init(actionID       : ActionID,
                options        : [ Option ],
                initialOptions : [ Option ]?         = nil,
                confirm        : ConfirmationDialog? = nil)
    {
      self.actionID       = actionID
      self.options        = options
      self.initialOptions = initialOptions
      self.confirm        = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type
      case actionID       = "action_id"
      case options
      case initialOptions = "initial_options"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("checkboxes", forKey: .type)
      try container.encode(actionID,     forKey: .actionID)
      try container.encode(options,      forKey: .options)
      if let v = initialOptions, !v.isEmpty {
        try container.encode(initialOptions, forKey: .initialOptions)
      }
      if let v = confirm { try container.encode(v, forKey: .confirm) }
    }
  }
}

public extension Block.Checkboxes {
  
  /**
   * Sets the initial options based on the values of the available options.
   * I.e. must be called after setting up the options.
   */
  mutating func setInitialOptions(_ values: Set<String>) {
    guard !values.isEmpty else {
      self.initialOptions = nil
      return
    }

    #if DEBUG
      var pendingValues = values
    #endif
    var initialOptions = [ Block.Option ]()
    initialOptions.reserveCapacity(values.count)
    
    for option in options {
      if values.contains(option.value) {
        initialOptions.append(option)
        #if DEBUG
          pendingValues.remove(option.value)
        #endif
      }
    }
    
    self.initialOptions = initialOptions
    #if DEBUG
      assert(pendingValues.isEmpty,
             "did not find option for keys: \(pendingValues)")
    #endif
  }
}
