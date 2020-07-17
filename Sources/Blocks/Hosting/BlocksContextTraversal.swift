//
//  BlocksContextTraversal.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension BlocksContext {

  func enterConditional(_ flag: Bool) {
    if flag { currentElementID.appendElementIDComponent("Y" ) }
    else    { currentElementID.appendElementIDComponent("N" ) }
  }
  func leaveConditional() {
    currentElementID.deleteLastElementIDComponent()
  }
  
  func enterTuple(count: Int) {
    currentElementID.appendZeroElementIDComponent()
  }
  func processedTupleElement(at index: Int) {
    currentElementID.incrementLastElementIDComponent()
  }
  func leaveTuple() {
    currentElementID.deleteLastElementIDComponent()
  }
  
  func enterForEach(count: Int) {}
  func leaveForEach()           {}
  func enterForEachElement<ID: Hashable & WebRepresentableIdentifier>
         (with id: ID)
  {
    currentElementID.appendElementIDComponent(id)
  }
  func leaveForEachElement<ID: Hashable>(with id: ID) {
    currentElementID.deleteLastElementIDComponent()
  }
  
  @usableFromInline
  func enterComponent<V: Blocks>(_ view: inout V) {}
  @usableFromInline
  func leaveComponent<V: Blocks>(_ view: inout V) {}
}
