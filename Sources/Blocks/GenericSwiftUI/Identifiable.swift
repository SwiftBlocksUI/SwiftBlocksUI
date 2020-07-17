//
//  Identifiable.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

/**
 * This allows all Hashable types to be also marked as Identifiable, like:
 *
 *     enum BreadType: CaseIterable, Hashable, Identifiable {
 *       case wheat, white, rhy
 *     }
 *
 */
public extension Identifiable where Self : Hashable {
  // Not sure, the released SwiftUI doesn't seem to have that anymore?
  
  var id : Self { return self }
}
