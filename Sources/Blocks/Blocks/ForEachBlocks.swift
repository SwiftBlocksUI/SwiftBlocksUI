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
  public init(_ data: Data, id idKeyPath: KeyPath<Data.Element, ID>,
              @BlocksBuilder content: @escaping ( Data.Element ) -> Content)
  {
    self.data        = data
    self.content     = content
    self.elementToID = { element in
      let id = element[keyPath: idKeyPath]
      if let webID = id as? WebRepresentableIdentifier { return webID.webID }
      return nil
    }
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
    self.elementToID = { element in
      let id = element.id
      if let webID = id as? WebRepresentableIdentifier { return webID.webID }
      return nil
    }
  }
}

extension ForEach where ID == Data.Element.ID,
                        Data.Element: Identifiable,
                        Content: Blocks,
                        Data.Element.ID: WebRepresentableIdentifier
{
  @inlinable
  public init(_ data: Data,
              @BlocksBuilder content: @escaping ( Data.Element ) -> Content)
  {
    self.data        = data
    self.content     = content
    self.elementToID = { element in element.id.webID }
  }
}

extension ForEach where Data == Range<Int>, ID == Int, Content: Blocks {
  @inlinable
  public init(_ data: Data,
              @BlocksBuilder content: @escaping ( Data.Element ) -> Content)
  {
    self.data        = data
    self.content     = content
    self.elementToID = { element in element.webID }
  }
}
