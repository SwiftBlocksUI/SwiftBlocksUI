//
//  BlocksContextReflection.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

// The context also keeps a local cache to avoid the locking.
fileprivate var globalTypeCache = [ ObjectIdentifier : ComponentTypeInfo ]()

extension BlocksContext {

  @usableFromInline
  internal func lookupTypeInfo<V: Blocks>(for view: V) -> ComponentTypeInfo {
    let dynamicType = type(of: view)
    let typeOID     = ObjectIdentifier(dynamicType)
    if let info      = _componentTypeCache[typeOID] { return info }
    
    // TBD: Is this going to trigger ownership issues? It is properly protected
    //      within `lookupInfo()`, but maybe Swift safeguards are around that.
    let info = ComponentTypeInfo.lookupInfo(for: dynamicType,
                                            cache: &globalTypeCache)
    _componentTypeCache[typeOID] = info
    return info
  }
}
