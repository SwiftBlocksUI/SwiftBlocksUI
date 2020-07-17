//
//  ComponentTypeInfo.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

@usableFromInline
enum ComponentTypeInfo: Equatable {
  
  @usableFromInline
  typealias DynamicPropertyType = _DynamicBlockPropertyType
  
  case `static`
  case `dynamic`(dynamicProperties: [ DynamicPropertyInfo ])
  
  @usableFromInline
  struct DynamicPropertyInfo: Equatable {
    
    let rawName       : String
    let name          : String
    let offset        : Int
    @usableFromInline
    let typeInstance  : DynamicPropertyType.Type // TBD: do we even need this?

    @usableFromInline
    func withMutablePointer<T>
           (_ value: inout T, execute: ( UnsafeMutableRawPointer ) -> Void)
    {
      withUnsafeMutablePointer(to: &value) { valuePtr in
        let rawValuePtr = UnsafeMutableRawPointer(valuePtr)
        let rawPropPtr  = rawValuePtr.advanced(by: offset)
        execute(rawPropPtr)
      }
    }
    
    
    // MARK: - Equatable
    
    @usableFromInline
    static func ==(lhs: DynamicPropertyInfo, rhs: DynamicPropertyInfo)
                -> Bool
    {
      guard lhs.offset       == rhs.offset        else { return false }
      guard lhs.name         == rhs.name          else { return false }
      guard lhs.typeInstance == rhs.typeInstance  else { return false }
      return true
    }
  }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  import Darwin
#else
  import Glibc
#endif

fileprivate let lock : UnsafeMutablePointer<pthread_mutex_t> = {
  let lock = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
  let err = pthread_mutex_init(lock, nil)
  precondition(err == 0, "could not initialize lock")
  return lock
}()

internal extension ComponentTypeInfo {

  /**
   * This method is thread safe, and uses a global cache.
   *
   * Provide a proper cache using (the lock is provided):
   *
   *     var cache =
   *       [ ObjectIdentifier : ComponentTypeInfo<DynamicPropertyType> ]()
   */
  static func lookupInfo<V>(for viewType: V.Type,
                            cache: inout [ObjectIdentifier : ComponentTypeInfo])
              -> ComponentTypeInfo
  {
    let typeOID = ObjectIdentifier(viewType)
    
    pthread_mutex_lock(lock)
    let cachedData = cache[typeOID]
    pthread_mutex_unlock(lock)
    if let ti = cachedData { return ti }
    
    let newType = ComponentTypeInfo(reflecting: V.self) ?? .static
    pthread_mutex_lock(lock)
    cache[typeOID] = newType
    pthread_mutex_unlock(lock)
    return newType
  }
}

import func Runtime.typeInfo

extension ComponentTypeInfo {
  
  fileprivate init?<T>(reflecting viewType: T.Type) {
    guard let structInfo = try? Runtime.typeInfo(of: viewType) else {
      globalBlocksLog.error("failed to reflect on View: \(viewType)")
      assertionFailure("failed to reflect on View \(viewType)")
      return nil
    }

    switch structInfo.kind {
      case .struct:
        break
 
      case .class:
        globalBlocksLog.error("Cannot use a `class` as a View: \(viewType)")
        return nil
        
      case .optional:
        self = .static
        return
        
      default:
        globalBlocksLog.error(
          "Only structs allowed:\n  Type: \(viewType)\n  info: \(structInfo)"
        )
        assertionFailure(
          "currently only supporting structs for Views, got type: \(viewType)" +
          " info: \(structInfo)"
        )
        return nil
    }
    
    let dynamicProperties : [ ComponentTypeInfo.DynamicPropertyInfo ]
                          = structInfo.properties.compactMap
    {
      propInfo in
                            
      guard let dynamicType =
                  propInfo.type as? DynamicPropertyType.Type else {
        return nil
      }
      
      let rawName : String = propInfo.name
      let cleanedName : String = {
        if rawName.hasPrefix(magicDelegateStoragePrefix) {
          return String(rawName.dropFirst(magicDelegateStoragePrefix.count))
        }
        if rawName.hasPrefix("$") {
          return String(rawName.dropFirst())
        }
        return rawName
      }()
      
      let info = DynamicPropertyInfo(rawName       : rawName,
                                     name          : cleanedName,
                                     offset        : propInfo.offset,
                                     typeInstance  : dynamicType)
      return info
    }
    self = dynamicProperties.isEmpty
      ? .static
      : .dynamic(dynamicProperties: dynamicProperties)
  }
  
}

fileprivate let magicDelegateStoragePrefix = "$__delegate_storage_$_"
