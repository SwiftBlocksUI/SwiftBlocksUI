//
//  ForEachBlocks.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public protocol DynamicBlocksContent: Blocks {
  associatedtype Data : Collection
  
  var data : Self.Data { get }
}

extension ForEach : Blocks where Content : Blocks {
  public typealias Body = Never

  @inlinable
  public init(_ data: Data, id: KeyPath<Data.Element, ID>,
              @BlocksBuilder content: @escaping ( Data.Element ) -> Content)
  {
    self.data        = data
    self.content     = content
    self.elementToID = { element in element[keyPath: id] }
  }
}
extension ForEach : DynamicBlocksContent where Content : Blocks {}

extension ForEach where ID == Data.Element.ID, Data.Element: Identifiable,
                        Content: Blocks
{
  @inlinable
  public init(_ data: Data,
              @BlocksBuilder content: @escaping ( Data.Element ) -> Content)
  {
    self.data        = data
    self.content     = content
    self.elementToID = { element in element.id }
  }
}

extension ForEach where Data == Range<Int>, ID == Int, Content: Blocks {
  @inlinable
  public init(_ data: Data,
              @BlocksBuilder content: @escaping ( Data.Element ) -> Content)
  {
    self.data        = data
    self.content     = content
    self.elementToID = { element in element }
  }
}
