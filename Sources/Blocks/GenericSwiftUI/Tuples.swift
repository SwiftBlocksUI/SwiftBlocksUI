//
//  Tuples.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public struct Group<Content> {
  @usableFromInline
  let content : Content
}
extension Group: CustomStringConvertible {
  public var description: String { return "<Group: \(content)>" }
}

public struct Tuple2<T1, T2> {
  public let value1 : T1, value2 : T2
  public init(_ value1: T1, _ value2: T2) {
    self.value1 = value1
    self.value2 = value2
  }
}
public struct Tuple3<T1, T2, T3> {
  public let value1 : T1, value2 : T2, value3 : T3
  public init(_ value1: T1, _ value2: T2, _ value3: T3) {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
  }
}
public struct Tuple4<T1, T2, T3, T4> {
  public let value1 : T1, value2 : T2, value3 : T3, value4 : T4
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4) {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
    self.value4 = value4
  }
}
public struct Tuple5<T1, T2, T3, T4, T5> {
  public let value1 : T1, value2 : T2, value3 : T3, value4 : T4, value5 : T5
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5)
  {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
    self.value4 = value4
    self.value5 = value5
  }
}
public struct Tuple6<T1, T2, T3, T4, T5, T6> {
  public let value1 : T1, value2 : T2, value3 : T3, value4 : T4, value5 : T5
  public let value6 : T6
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6)
  {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
    self.value4 = value4
    self.value5 = value5
    self.value6 = value6
  }
}
public struct Tuple7<T1, T2, T3, T4, T5, T6, T7> {
  public let value1 : T1, value2 : T2, value3 : T3, value4 : T4, value5 : T5
  public let value6 : T6, value7 : T7
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6, _ value7: T7)
  {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
    self.value4 = value4
    self.value5 = value5
    self.value6 = value6
    self.value7 = value7
  }
}
public struct Tuple8<T1, T2, T3, T4, T5, T6, T7, T8> {
  public let value1 : T1, value2 : T2, value3 : T3, value4 : T4, value5 : T5
  public let value6 : T6, value7 : T7, value8 : T8
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6, _ value7: T7, _ value8: T8)
  {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
    self.value4 = value4
    self.value5 = value5
    self.value6 = value6
    self.value7 = value7
    self.value8 = value8
  }
}
public struct Tuple9<T1, T2, T3, T4, T5, T6, T7, T8, T9> {
  public let value1 : T1, value2 : T2, value3 : T3, value4 : T4, value5 : T5
  public let value6 : T6, value7 : T7, value8 : T8, value9 : T9
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6, _ value7: T7, _ value8: T8,
              _ value9: T9)
  {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
    self.value4 = value4
    self.value5 = value5
    self.value6 = value6
    self.value7 = value7
    self.value8 = value8
    self.value9 = value9
  }
}
