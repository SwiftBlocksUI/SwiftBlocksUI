//
//  CallbackBlock.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.CallbackID

/**
 * When generating interactive content, we may need to generate callback IDs,
 * so that we can find the View/the Blocks later on.
 *
 * Note: This does NOT have to be a View. A View uses the callback ID for
 *       view submission, but regular blocks can still have interactive
 *       content!
 *
 * If the View has no CallbackID assigned, we generate one based on the type
 * signature.
 */
public protocol CallbackBlock {
  
  var callbackBlockID : CallbackID? { get }
  
}


// MARK: - Top-Level Identifying Elements
// hm. The idea is that the user can always do .id("")

extension IDModifier: CallbackBlock {
  @inlinable
  var callbackBlockID: CallbackID? {
    return CallbackID(ElementID.makeWebID(for: id))
  }
}

public protocol CallbackIDTransparentModifier: CallbackBlock {
  associatedtype Content : Blocks
  var content : Content { get }
}
public extension CallbackIDTransparentModifier {
  @inlinable
  var callbackBlockID: CallbackID? {
    return CallbackID.blockID(for: content)
  }
}

/// A private hack, do not use ;-)
public struct CallbackIDTransparentEnvironmentWritingModifier<Content: Blocks>
              : Blocks
{
  // Optimization over just using tons of `.environment()`,
  // avoids all the CoW copying by using just one View for
  // all those keys.

  public typealias Body = Never
  
  public let modifier : ( inout EnvironmentValues ) -> Void
  public let content  : Content

  @inlinable
  public init(_ content : Content,
              modifier  : @escaping ( inout EnvironmentValues ) -> Void)
  {
    self.modifier = modifier
    self.content  = content
  }
}
extension CallbackIDTransparentEnvironmentWritingModifier
            : CallbackIDTransparentModifier, CallbackBlock
{
}
extension CallbackIDTransparentEnvironmentWritingModifier: BlocksPrimitive {

  public func render(in context: BlocksContext) throws {
    try context.environments._inModifiedEnvironment(
      execute  : { try context.render(content) },
      modifier : modifier
    )
  }
}

extension InteractiveRequestEnvironmentWritingModifier
            : CallbackIDTransparentModifier, CallbackBlock
{
}


// MARK: - CallbackID Generation

public extension CallbackID {
  
  @inlinable
  static func blockID<B: Blocks & CallbackBlock>(for blocks: B) -> CallbackID {
    return blocks.callbackBlockID ?? generatedBlockID(for: blocks)
  }
  
  @inlinable
  static func blockID<B: Blocks>(for blocks: B) -> CallbackID {
    return (blocks as? CallbackBlock)?.callbackBlockID
        ?? generatedBlockID(for: blocks)
  }
}


public extension CallbackID {
  
  /**
   * This generates an ID based on the _type name_.
   *
   * The typename is used because we want a "semi stable" name, it is a tradeoff
   * between stability and restart persistence after recompilation.
   * It should be stable across app restarts (hence we can't use the type's
   * OID).
   *
   * Note that this is not guaranteed to be stable, and there _can be_
   * duplicates!
   * E.g. often it seems to be just the "short name" in Swift 5.3?
   */
  static func generatedBlockID<B: Blocks>(for blocks: B) -> CallbackID {
    let blockType = type(of: blocks)
    let typeOID   = ObjectIdentifier(blockType)
    
    do {
      blockIDsLock.lock()
      let cachedID = blockIDs[typeOID]
      blockIDsLock.unlock()
      if let id = cachedID { return id }
    }
    
    let reflector = TypeReflector(blockType)
    let typeName  = reflector.bestAvailableTypeName
    
    // OK, so we use base64, more compact than hex. 26 characters for the 20
    // char hash.
    // base64 is alnum and "+/="
    let nameHash  = typeName.sha1Base64()
    
    let id        = CallbackID(nameHash)
    globalBlocksLog.notice(
      "Generated type based CallbackID '\(id.id)'\n for blocks: \(typeName)")

    do {
      blockIDsLock.lock()
      blockIDs[typeOID] = id
      blockIDsLock.unlock()
    }
    return id
  }
  
}
import class Foundation.NSLock
fileprivate var blockIDsLock = NSLock() // slow, use something better
fileprivate var blockIDs = [ ObjectIdentifier : CallbackID ]()

// TODO: IdentifiedBlock: CallbackBlock!

extension View: CallbackBlock {
  
  @inlinable
  public var callbackBlockID: CallbackID? { return id }
}


// MARK: - ID generator

// This is a dirty hack to get the mangled typename :-) Let me know if there
// is a better way.
// It is not going to be stable across Swift version.
fileprivate struct TypeReflector {
  let SOY: Any.Type
  init(_ type: Any.Type) { SOY = type }
  
  var bestAvailableTypeName: String {
    return fullyQualifiedType ?? String(describing: SOY)
  }
  var fullyQualifiedType: String? {
    // TypeReflector(SOY: Blocks.View<SwiftBlocksUITests.IDTests.CowsBlocks>)
    let selfString = String(describing: self)
    guard let idx = selfString.range(of: "SOY:")?.upperBound else {
      // just to let myself know, need to test a few Swift versions
      assertionFailure(
        "hacky type reflection doesn't work in this Swift version")
      return nil
    }
    var sub = selfString[idx...]
    while sub.first == " " { sub = sub.dropFirst() }
    if let end = selfString.firstIndex(of: ")") {
      sub = sub[..<end]
    }
    // Blocks.View<SwiftBlocksUITests.IDTests.CowsBlocks>
    return String(sub)
  }
}
