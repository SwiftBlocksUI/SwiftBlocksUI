//
//  ForEach.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public struct ForEach<Data, ID, Content>
         where Data : RandomAccessCollection,
               ID   : Hashable
{
  
  public let data : Data
  
  @usableFromInline
  let content : ( Data.Element ) -> Content
  
  @usableFromInline
  let elementToID : ( Data.Element ) -> String?
}
