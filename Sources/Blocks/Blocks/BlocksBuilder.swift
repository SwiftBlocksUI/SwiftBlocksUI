//
//  BlocksBuilder.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020-2021 ZeeZide GmbH. All rights reserved.
//

#if swift(>=5.5)
  /**
   * The function builder to trigger building of `Blocks` elements.
   */
  @resultBuilder public struct BlocksBuilder {}
#else
  /**
   * The function builder to trigger building of `Blocks` elements.
   */
  @_functionBuilder public struct BlocksBuilder {}
#endif

public extension BlocksBuilder {

  @inlinable
  static func buildBlock() -> Empty {
    return Empty()
  }

  @inlinable
  static func buildBlock<V: Blocks>(_ content: V) -> V {
    return content
  }

  @inlinable
  static func buildIf<V: Blocks>(_ content: V)  -> V  { return content }
  @inlinable
  static func buildIf<V: Blocks>(_ content: V?) -> V? { return content }

  @inlinable
  static func buildEither<T: Blocks, F: Blocks>(first: T) -> IfElse<T, F> {
    return IfElse(first: first)
  }
  @inlinable
  static func buildEither<T: Blocks, F: Blocks>(second: F) -> IfElse<T, F> {
    return IfElse(second: second)
  }
}

public extension BlocksBuilder { // Tuples
  
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks>(_ c0: C0, _ c1: C1)
              -> Tuple2<C0, C1>
  {
    return Tuple2(c0, c1)
  }
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks, C2: Blocks>
                (_ c0: C0, _ c1: C1, _ c2: C2) -> Tuple3<C0, C1, C2>
  {
    return Tuple3(c0, c1, c2)
  }
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks, C2: Blocks, C3: Blocks>
                (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3)
                -> Tuple4<C0, C1, C2, C3>
  {
    return Tuple4(c0, c1, c2, c3)
  }
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks, C2: Blocks, C3: Blocks,
                         C4: Blocks>
                (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4)
                -> Tuple5<C0, C1, C2, C3, C4>
  {
    return Tuple5(c0, c1, c2, c3, c4)
  }
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks, C2: Blocks, C3: Blocks,
                         C4: Blocks, C5: Blocks>
                (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5)
                -> Tuple6<C0, C1, C2, C3, C4, C5>
  {
    return Tuple6(c0, c1, c2, c3, c4, c5)
  }
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks, C2: Blocks, C3: Blocks,
                         C4: Blocks, C5: Blocks, C6: Blocks>
                (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4,
                 _ c5: C5, _ c6: C6)
                -> Tuple7<C0, C1, C2, C3, C4, C5, C6>
  {
    return Tuple7(c0, c1, c2, c3, c4, c5, c6)
  }
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks, C2: Blocks, C3: Blocks,
                         C4: Blocks, C5: Blocks, C6: Blocks, C7: Blocks>
                (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4,
                 _ c5: C5, _ c6: C6, _ c7: C7 )
                -> Tuple8<C0, C1, C2, C3, C4, C5, C6, C7>
  {
    return Tuple8(c0, c1, c2, c3, c4, c5, c6, c7)
  }
  @inlinable
  static func buildBlock<C0: Blocks, C1: Blocks, C2: Blocks, C3: Blocks,
                         C4: Blocks, C5: Blocks, C6: Blocks, C7: Blocks,
                         C8: Blocks>
                (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4,
                 _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8)
                -> Tuple9<C0, C1, C2, C3, C4, C5, C6, C7, C8>
  {
    return Tuple9(c0, c1, c2, c3, c4, c5, c6, c7, c8)
  }
}

// MARK: - Empty

extension BlocksBuilder {
  public struct Empty: Blocks {
    public typealias Body = Never
    public init() {}
  }
}

extension Optional : Blocks where Wrapped : Blocks {
  public typealias Body = Never
}

extension Never : Blocks {
  public var body : Never { fatalError("no body in Never") }
}

extension Blocks where Body == Never {
  public var body : Never { fatalError("no body in \(type(of: self))") }
}

// MARK: - Conditional

extension BlocksBuilder {

  public struct IfElse<TrueContent, FalseContent> : Blocks
           where TrueContent: Blocks, FalseContent: Blocks
  {
    public typealias Body = Never
    
    @usableFromInline
    enum Content {
      case first (TrueContent)
      case second(FalseContent)
    }
    @usableFromInline let content : Content
    
    @inlinable
    public init(first  : TrueContent)  { content = .first(first)   }
    @inlinable
    public init(second : FalseContent) { content = .second(second) }
  }
}

// MARK: - Tuple specialization

extension Group : Blocks where Content : Blocks {
  
  public typealias Body = Never
  
  @inlinable
  public init(@BlocksBuilder _ content: () -> Content) {
    self.content = content()
  }
}

extension Tuple2: Blocks where T1: Blocks, T2: Blocks {
  public typealias Body = Never
}
extension Tuple3: Blocks where T1: Blocks, T2: Blocks, T3: Blocks {
  public typealias Body = Never
}
extension Tuple4: Blocks where T1: Blocks, T2: Blocks, T3: Blocks, T4: Blocks {
  public typealias Body = Never
}
extension Tuple5: Blocks where T1: Blocks, T2: Blocks, T3: Blocks, T4: Blocks,
                               T5: Blocks
{
  public typealias Body = Never
}
extension Tuple6: Blocks where T1: Blocks, T2: Blocks, T3: Blocks, T4: Blocks,
                               T5: Blocks, T6: Blocks
{
  public typealias Body = Never
}
extension Tuple7: Blocks where T1: Blocks, T2: Blocks, T3: Blocks, T4: Blocks,
                               T5: Blocks, T6: Blocks, T7: Blocks
{
  public typealias Body = Never
}
extension Tuple8: Blocks where T1: Blocks, T2: Blocks, T3: Blocks, T4: Blocks,
                               T5: Blocks, T6: Blocks, T7: Blocks, T8: Blocks
{
  public typealias Body = Never
}
extension Tuple9: Blocks where T1: Blocks, T2: Blocks, T3: Blocks, T4: Blocks,
                               T5: Blocks, T6: Blocks, T7: Blocks, T8: Blocks,
                               T9: Blocks
{
  public typealias Body = Never
}
