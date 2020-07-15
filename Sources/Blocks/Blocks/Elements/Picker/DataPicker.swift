//
//  DataPicker.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

// I don't like the SelectionManager variant. The selection should be
// able to carry Identifiable objects, not just the IDs.
// This is actually implemented now below, in those weird `Any` extensions.
// Needs a proper generic cleanup.
// Need help to kill all those Any's here.

extension Picker where Content == AnyBlocks { // sigh
  
  /**
   * A data driven picker.
   * This one is for simple values where the value itself is Hashable.
   *
   * Example:
   *
   *     Picker("Countries", [ "de", "gb", "us" ], id: \.self,
   *            selection: $country)
   *     { item in
   *       "Country: \(item)"
   *     }
   *
   */
  @inlinable
  public init<Data, ID, ElementContent>(
    _ title     : String,
    _ data      : Data,
    id          : KeyPath<Data.Element, ID>,
    selection   : Binding<Selection>,
    placeholder : String? = nil,
    action      : Action? = nil,
    @BlocksBuilder content : @escaping ( Data.Element ) -> ElementContent
  )
    where Data           : RandomAccessCollection,
          ID             : Hashable,
          Selection     == Optional<ID>,
          ElementContent : Blocks
  {
    let loop = ForEach(data, id: id) { content($0).tag($0[keyPath: id]) }
    self.init(title, selection: selection,
              placeholder: placeholder, action: action,
              content: { return AnyBlocks(loop) })
  }

  /**
   * A data driven picker for a collection of Identifiable objects.
   * Selection contains the ID of the object.
   *
   * Example:
   *
   *     Picker("Orders", orders, selection: $selectedOrderID) { order in
   *       "Order: \(order.title)"
   *     }
   *
   */
  @inlinable
  public init<Data, ElementContent, SelectionValue>(
    _ title     : String,
    _ data      : Data,
    selection   : Binding<SelectionValue?>,
    placeholder : String? = nil,
    action      : Action? = nil,
    @BlocksBuilder content : @escaping ( Data.Element ) -> ElementContent
  )
    where Data            : RandomAccessCollection,
          Data.Element    : Identifiable,
          SelectionValue == Data.Element.ID,
          Selection      == SelectionValue?,
          ElementContent  : Blocks
  {
    self.init(title, data, id: \.id, selection: selection,
              placeholder: placeholder, action: action, content: content)
  }
}

extension Picker where Content == AnyBlocks { // sigh

  /**
   * A data driven picker for a collection of Identifiable objects.
   * Selection contains the matching object.
   *
   * Example:
   *
   *     Picker("Orders", orders, selection: $selectedOrder) { order in
   *       "Order: \(order.title)"
   *     }
   *
   */
  @inlinable
  public init<Data, ElementContent>(
    _ title     : String,
    _ data      : Data,
    selection   : Binding<Data.Element?>,
    placeholder : String? = nil,
    action      : Action? = nil,
    @BlocksBuilder content : @escaping ( Data.Element ) -> ElementContent
  )
    where Data           : RandomAccessCollection,
          Data.Element   : Identifiable,
          Selection     == AnyHashable?, // halp
          ElementContent : Blocks
  {
    // Halp, fix my generics.
    // This is crazy "Any", but does work surprisingly ;-)
    let wrappedSelection = Binding<Selection>(
      getValue: {
        guard let value = selection.getter() else { return nil }
        return value.id
      },
      setValue: { id in
        if let id = id {
          selection.setter(data.first(where: { AnyHashable($0.id) == id }))
        }
        else           { selection.setter(nil) }
      }
    )
    
    let loop = ForEach(data, id: \.id) { content($0).tag($0.id) }
    
    self.init(title, selection: wrappedSelection,
              placeholder: placeholder, action: action,
              content: { return AnyBlocks(loop) })
  }

  /**
   * A data driven picker for a collection of Identifiable objects.
   * Selection contains the matching object.
   *
   * Example:
   *
   *     Picker("Orders", orders, selection: $selectedOrder) { order in
   *       "Order: \(order.title)"
   *     }
   *
   */
  @inlinable
  public init<Data, ElementContent>(
    _ title     : String,
    _ data      : Data,
    selection   : Binding<Data.Element>,
    placeholder : String? = nil,
    action      : Action? = nil,
    @BlocksBuilder content : @escaping ( Data.Element ) -> ElementContent
  )
    where Data           : RandomAccessCollection,
          Data.Element   : Identifiable,
          Selection     == AnyHashable?, // halp
          ElementContent : Blocks
  {
    // Halp, fix my generics.
    // This is crazy "Any", but does work surprisingly ;-)
    let wrappedSelection = Binding<Selection>(
      getValue: { return selection.getter().id },
      setValue: { id in
        guard let id = id else {
          return globalBlocksLog.info(
            "attempt to push nil value into non-optional object selection")
        }
        guard let object = data.first(where: { AnyHashable($0.id) == id }) else
        {
          return globalBlocksLog.info(
            "did not find object for id \(id) in non-optional object selection")
        }
        selection.setter(object)
      }
    )
    
    let loop = ForEach(data, id: \.id) { content($0).tag($0.id) }
    
    self.init(title, selection: wrappedSelection,
              placeholder: placeholder, action: action,
              content: { return AnyBlocks(loop) })
  }
  
  /**
   * A data driven picker for a collection of Identifiable objects.
   * Selection contains the matching object.
   *
   * Example:
   *
   *     Picker("Orders", orders, selection: $selectedOrder) { order in
   *       "Order: \(order.title)"
   *     }
   *
   */
  @inlinable
  public init<Data, ElementContent>(
    _ title     : String,
    _ data      : Data,
    selection   : Binding<Set<Data.Element>>,
    placeholder : String? = nil,
    action      : Action? = nil,
    @BlocksBuilder content : @escaping ( Data.Element ) -> ElementContent
  )
    where Data           : RandomAccessCollection,
          Data.Element   : Identifiable,
          Selection     == Set<AnyHashable>, // halp
          ElementContent : Blocks
  {
    // Halp, fix my generics.
    // This is crazy "Any", but does work surprisingly ;-)
    let wrappedSelection = Binding<Selection>(
      getValue: { return Set(selection.getter().map(\.id)) },
      setValue: { ids in
        var objectSet = Set<Data.Element>()
        for element in data { // TODO: speedz ;-) but lists will be small here
          if ids.contains(element.id) { objectSet.insert(element) }
        }
        selection.setter(objectSet)
      }
    )
    
    let loop = ForEach(data, id: \.id) { content($0).tag($0.id) }
    
    self.init(title, selection: wrappedSelection,
              placeholder: placeholder, action: action,
              content: { return AnyBlocks(loop) })
  }
}
