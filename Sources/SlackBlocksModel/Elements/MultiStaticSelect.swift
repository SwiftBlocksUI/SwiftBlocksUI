//
//  MultiStaticSelect.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension Block {
  
  /**
   * A multi static select results in a modal to make the selection, while a
   * regular static select is a single select combo box.
   *
   * Note: One might think setting maxSelectedItems to 1 makes it a regular
   *       static select, but that isn't the case for the API block. However,
   *       we fake this behaviour in here to avoid all the duping.
   * 
   * Docs: https://api.slack.com/reference/block-kit/block-elements#static_multi_select
   */
  struct MultiStaticSelect: SelectElement {
    
    public static let validInBlockTypes : [ BlockTypeSet ]
                                        = [ .section, .input ]
                 
    public let actionID         : ActionID
    public let placeholder      : String // max 150 chars
    public var options          : [ Option      ]
    public var optionGroups     : [ OptionGroup ]?
    public var initialOptions   : [ Option      ]?
    public let maxSelectedItems : Int?
    public var confirm          : ConfirmationDialog?
    
    public init(actionID         : ActionID,
                placeholder      : String,
                options          : [ Option      ],
                optionGroups     : [ OptionGroup ]?    = nil,
                initialOptions   : [ Option      ]?    = nil,
                maxSelectedItems : Int?                = nil,
                confirm          : ConfirmationDialog? = nil)
    {
      self.actionID         = actionID
      self.placeholder      = placeholder
      self.options          = options
      self.optionGroups     = optionGroups
      self.initialOptions   = initialOptions
      self.maxSelectedItems = maxSelectedItems
      self.confirm          = confirm
    }

    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case type, placeholder, options
      case actionID         = "action_id"
      case initialOptions   = "initial_options"
      case initialOption    = "initial_option"
      case optionGroups     = "option_groups"
      case maxSelectedItems = "max_selected_items"
      case confirm
    }
    
    public func encode(to encoder: Encoder) throws {
      let isSingle = maxSelectedItems == 1
      
      var container = encoder.container(keyedBy: CodingKeys.self)
      if isSingle {
        try container.encode("static_select",       forKey: .type)
        if let v = initialOptions?.first {
          try container.encode(v, forKey: .initialOption)
        }
      }
      else {
        try container.encode("multi_static_select", forKey: .type)
        if let v = initialOptions, !v.isEmpty {
          try container.encode(v, forKey: .initialOptions)
        }
        if let v = maxSelectedItems, v >= 0 {
          try container.encode(v, forKey: .maxSelectedItems)
        }
      }
      try container.encode(actionID,                forKey: .actionID)
      try container.encode(Text(placeholder),       forKey: .placeholder)
      
      if let v = optionGroups, !v.isEmpty {
        if options.isEmpty {
          try container.encode(v, forKey: .optionGroups)
        }
        else {
          try container.encode([ OptionGroup(label: "", options: options) ] + v,
                               forKey: .optionGroups)
        }
      }
      else {
        try container.encode(options, forKey: .options)
      }
      if let v = confirm { try container.encode(v, forKey: .confirm) }
    }
  }
}

extension Block.MultiStaticSelect: CustomStringConvertible {

  public var description: String {
    var ms = "<Select[\(actionID.id)]:"
    
    if let v = maxSelectedItems { if v != 1 { ms += " max=\(v)" } }
    else                                    { ms += " multi" }
    
    if !placeholder.isEmpty { ms += " '\(placeholder)'" }
    
    if !options.isEmpty {
      if options.count > 8 { ms += " #\(options.count)" }
      else { ms += " " + options.map { $0.value }.joined(separator: ",") }
    }
    
    if let v = optionGroups,   !v.isEmpty { ms += " groups=#\(v.count)"  }
    if let v = initialOptions, !v.isEmpty {
      if v.count > 8 { ms += " initial=#\(v.count)" }
      else { ms += " initial=" + v.map { $0.value }.joined(separator: ",") }
    }

    if confirm != nil { ms += " confirm" }
    
    ms += ">"
    return ms
  }
}

public extension Block.MultiStaticSelect {
  
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
    for optionGroup in optionGroups ?? [] {
      for option in optionGroup.options {
        if values.contains(option.value) {
          initialOptions.append(option)
          #if DEBUG
            pendingValues.remove(option.value)
          #endif
        }
      }
    }
    
    self.initialOptions = initialOptions
    #if DEBUG
      assert(pendingValues.isEmpty,
             "did not find option for keys: \(pendingValues)")
    #endif
  }
}
