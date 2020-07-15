//
//  InputValidationError.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * An action can throw this to mark Input blocks as invalid.
 *
 * Alternatively one can use formatters to validate input.
 */
public struct InputValidationError: Swift.Error {
  // Errors are stored in the `BlocksContext`.
  
  public let invalidInputs : [ BlockIDStyle : String ]

  public init(invalidInputs: [ BlockIDStyle : String ]) {
    self.invalidInputs = invalidInputs
  }
}

public extension InputValidationError {

  struct InvalidInput {
    
    public let id      : BlockIDStyle
    public let message : String
    
    @inlinable
    public init(id: BlockIDStyle, message: String = "Invalid Value") {
      self.id      = id
      self.message = message
    }
  }
  
  @inlinable
  init(_ invalidInputs: InvalidInput...) {
    self.init(invalidInputs: invalidInputs)
  }
  
  @inlinable
  init<S: Sequence>(invalidInputs: S) where S.Element == InvalidInput {
    var dict = [ BlockIDStyle : String ]()
    for input in invalidInputs {
      dict[input.id] = input.message
    }
    self.init(invalidInputs: dict)
  }
}

extension InputValidationError: ExpressibleByDictionaryLiteral {
  
  public init(dictionaryLiteral elements: ( String, String )...) {
    self.init(invalidInputs: elements.lazy.map { id, message in
      InvalidInput(id: .rootRelativeID(id), message: message)
    })
  }
}
