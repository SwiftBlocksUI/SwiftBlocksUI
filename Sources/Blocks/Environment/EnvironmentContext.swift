//
//  EnvironmentContext.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension BlocksContext.Environments {
  
  /**
   * Creates a copy of the active environment,
   * runs the modifier closure on it,
   * then pushes the modified environment on the stack,
   * executes the closure,
   * and pops the environment of the stack.
   *
   * This is internal and used by `Environment`, but can also be used to perform
   * bulk changes on the given `EnvironmentValues`.
   * It's the generic version which drives `setValue`, `addValue` and
   * `removingValues`.
   */
  @inlinable
  func _inModifiedEnvironment<R>(execute  : () throws -> R,
                                 modifier : ( inout EnvironmentValues ) -> Void)
         rethrows -> R
  {
    var environment = self.environment
    modifier(&environment)
    
    environmentStack.append(environment) // TBD: more efficient backing algo
    defer { environmentStack.removeLast() }
    
    return try execute()
  }

  /**
   * Run a closure within a new environment with one changed key.
   *
   * Used by the `Environment` propery wrapper.
   */
  @inlinable
  func setValue<Value, R>(_    value : Value,
                          in keyPath : WritableKeyPath<EnvironmentValues,Value>,
                          execute    : () throws -> R) rethrows -> R
  {
    return try _inModifiedEnvironment(execute: execute) {
      $0[keyPath: keyPath] = value
    }
  }
  
  /**
   * Run a closure within a new environment with one changed key.
   *
   * Used by the `EnvironmentKeyAddModifier` propery wrapper.
   */
  @inlinable
  func addValue<C, R>(_    value : C.Element,
                      in keyPath : WritableKeyPath<EnvironmentValues, C>,
                      execute    : () throws -> R) rethrows -> R
         where C: RangeReplaceableCollection
  {
    return try _inModifiedEnvironment(execute: execute) {
      $0[keyPath: keyPath].append(value)
    }
  }

  /**
   * Remove a set of keys.
   *
   * Example usage:
   *
   *     try context.environments
   *       .removingValues(of: IDEnvironmentKey     .self,
   *                           ClassesEnvironmentKey.self,
   *                           StylesEnvironmentKey .self)
   *     {
   *       try context.render(content)
   *     }
   *
   */
  @inlinable
  func removingValues<R>(of types : Any.Type...,
                         execute  : () throws -> R) rethrows -> R
  {
    return try _inModifiedEnvironment(execute: execute) { env in
      for type in types {
        env._removeAny(type)
      }
    }
  }
}
