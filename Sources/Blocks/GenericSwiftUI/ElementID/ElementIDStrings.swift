//
//  ElementIDStrings.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2023 ZeeZide GmbH. All rights reserved.
//

import Logging
import struct Foundation.UUID

public extension ElementID {

  @inlinable
  var webID: String {
    assert(!components.isEmpty, "asking for web ID of empty element-id?")
    return components.map { $0.webID }.joined(separator: ".")
  }
}

extension ElementID: CustomStringConvertible {
  
  public var description: String { return webID }
}

public protocol WebRepresentableIdentifier {
  var webID: String { get }
}

extension Int: WebRepresentableIdentifier {
  @inlinable
  public var webID: String { return String(self) }
}

extension String: WebRepresentableIdentifier {
  @inlinable
  public var webID: String {
    // FIXME
    // lame-o. Not sure what is best here.
    if !self.contains(".") { return self }
    return self.replacingOccurrences(of: ".", with: "_")
  }
}

extension UUID: WebRepresentableIdentifier {
  @inlinable
  public var webID: String {
    return uuidString
  }
}

extension RawRepresentable where RawValue : WebRepresentableIdentifier {
  // Note: The `RawRepresentable` still needs to declare itself as
  //       `WebRepresentableIdentifier`.
  @inlinable
  public var webID: String { return rawValue.webID }
}


// MARK: - Generic Version

extension AnyHashable: WebRepresentableIdentifier {
  @inlinable
  public var webID: String {
    return ElementID.makeWebID(for: base)
  }
}

extension ElementID { // WebID

  @inlinable
  static func makeWebID(for id: String) -> String { return id.webID }
  @inlinable
  static func makeWebID(for id: Int) -> String { return id.webID }
  @inlinable
  static func makeWebID(for id: UUID) -> String { return id.webID }

  @inlinable
  static func makeWebID<T: WebRepresentableIdentifier>(for id: T) -> String {
    return id.webID
  }

  @inlinable
  static func makeWebID(for id: Any) -> String {
    if let webID = (id as? WebRepresentableIdentifier)?.webID {
      return webID
    }
    globalBlocksLog.error(
      "Attempt to generate webID for generic ID: \(id), \(type(of: id))")
    return "ERROR"
  }
}
