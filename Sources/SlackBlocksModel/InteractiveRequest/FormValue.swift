//
//  FormValue.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension InteractiveRequest {

  // Example: type": "plain_text_input", "value": "Blub"
  // TBD: what values are allowed?
  
  public enum FormValue: Decodable {
    
    case button        (String)
    case plainTextInput(String)
    case option        (value  : String)
    case options       (values : [ String ])
    case date          (Block.YearMonthDay)
    case time          (Block.HourMinute)

    public var value : Any { // rather fix the callers
      switch self {
        case .button        (let value)  : return value
        case .plainTextInput(let value)  : return value
        case .option        (let value)  : return value
        case .options       (let values) : return values
        case .date          (let value)  : return value
        case .time          (let value)  : return value
      }
    }
    
    struct Option: Decodable {
      // Note: this also carries the full Option JSON
      let value : String
      enum CodingKeys: String, CodingKey {
        case value
      }
    }
    
    enum CodingKeys: String, CodingKey {
      case type, value
      case selectedOption  = "selected_option"
      case selectedOptions = "selected_options"
      case selectedDate    = "selected_date"
      case selectedTime    = "selected_time"
    }
    
    public init(from decoder: Decoder) throws {
      typealias Error = InteractiveRequest.DecodingError
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      let type =
        try container.decode(Block.InteractiveElementType.self, forKey: .type)
      
      func decodeOptions() -> FormValue? {
        if let opt = try? container.decode(Option.self,
                                           forKey: .selectedOption)
        {
          return .option(value: opt.value)
        }
        else if let opts = try? container.decode([ Option ].self,
                                                 forKey: .selectedOptions)
        {
          return .options(values: opts.map { $0.value })
        }
        else {
          return nil
        }
      }
      
      switch type {
        case .plainTextInput:
          self = .plainTextInput(
                   try container.decode(String.self, forKey: .value))
        
        case .button:
          self = .button(
                   try container.decode(String.self, forKey: .value))
        
        case .datePicker:
          // "selected_date": "2020-07-08"
          self = .date(
            try container.decode(Block.YearMonthDay.self, forKey:.selectedDate))
          
        case .timePicker:
          // "selected_time": "12:12"
          self = .time(
            try container.decode(Block.HourMinute.self, forKey:.selectedTime))
          
        case .checkboxes, .staticMultiSelect:
          self = decodeOptions() ?? .options(values: [])

        // TODO: probably needs more keys for user/conversation selects
          
        default: // just be dynamic here
          if let value = decodeOptions() {
            self = value
          }
          else {
            assertionFailure("unsupported form value: \(type)")
            throw Error.unsupportedViewStateValue
          }
      }
    }
  }
}

extension InteractiveRequest.FormValue: CustomStringConvertible {
  
  public var description: String {
    switch self {
      case .button (let value) : return "<ButtonValue: '\(value)'>"
      case .date   (let value) : return "<DateValue: \(value)>"
      case .time   (let value) : return "<TimeValue: \(value)>"
      case .option (let value) : return "<OptionValue: \(value)>"
      case .options(let values):
        return "<OptionValues: " + values.joined(separator: ",") + ">"
      case .plainTextInput(let value): return "<InputValue: '\(value)'>"
    }
  }
}
