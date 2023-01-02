//
//  BindingFormatter.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2019-2020 ZeeZide GmbH. All rights reserved.
//

import class Foundation.NSString
import class Foundation.Formatter

#if os(Linux) && swift(>=5.2)
  import class Foundation.DateFormatter
  import class Foundation.ISO8601DateFormatter
  import class Foundation.NumberFormatter
  import class Foundation.ByteCountFormatter
  import class Foundation.DateIntervalFormatter
  import class Foundation.EnergyFormatter
  import class Foundation.MassFormatter
  import class Foundation.LengthFormatter
#endif
  
extension Binding {
  
  @usableFromInline
  func formatter(_ formatter: Formatter, nilString: String = "")
       -> Binding<String>
  {
    return Binding<String>(
      getValue: {
           formatter.editingString(for: self.wrappedValue) // TBD
        ?? formatter.string       (for: self.wrappedValue)
        ?? nilString
      },
      setValue: { s in
        do {
          self.wrappedValue = try formatter.parseValue(s, of: Value.self)
        }
        catch {
          globalBlocksLog.warning(
            "failed to convert: '\(s)', \(type(of: self))")
        }
      }
    )
  }
}

enum FormatterError: Swift.Error {
  case formatterCannotConvertFromString
  /// https://bugs.swift.org/browse/SR-12411
  case unsupportedFormatterBlameSwift52Foundation
  
  case formatError(String?)
  case cannotConvertToFinalType(Any, Any.Type)
}

extension Formatter {
  
  func parseValue<V>(_ s: String, of type: V.Type) throws -> V {
    
    #if os(Linux) && swift(>=5.2)
      var obj : Any?
      // https://bugs.swift.org/browse/SR-12411
      switch self {
        case let formatter as DateFormatter:
          obj = formatter.date(from: s)
        case let formatter as ISO8601DateFormatter:
          obj = formatter.date(from: s)
        case let formatter as NumberFormatter:
          obj = formatter.number(from: s)
        
        case is ByteCountFormatter,
             is DateIntervalFormatter, is EnergyFormatter,
             is LengthFormatter,       is MassFormatter:
          throw FormatterError.formatterCannotConvertFromString
        
        // unavailable on Linux 5.2
        #if false
        case let formatter as PersonNameComponentsFormatter:
          return FormatterError
                   .formatterCannotConvertFromString
        case is DateComponentsFormatter,
             is MeasurementFormatter:
          throw FormatterError
                  .formatterCannotConvertFromString
        #endif

        default:
          throw FormatterError
            .unsupportedFormatterBlameSwift52Foundation
      }
    #elseif os(Linux) // getObjectValue is internal on Linux
      var obj : AnyObject?
      obj = try self.objectValue(s)
    #else
      var obj   : AnyObject?
      var error : NSString?
      guard self.getObjectValue(&obj, for: s,
                                errorDescription: &error) else
      {
        if let error = error {
          throw FormatterError.formatError(error as String)
        }
        else {
          throw FormatterError.formatError(nil)
        }
      }
    #endif

    if let v = obj as? V {
      return v
    }
    
    // The formatter returns a different value, but the bound value is
    // still a String
    if V.self is String.Type,
       let v = (self.editingString(for: obj as Any)
             ?? self.string       (for: obj as Any)
             ?? String(describing: obj as Any)) as? V
    {
      return v
    }
    
    throw FormatterError.cannotConvertToFinalType(obj as Any, V.self)
  }
}
