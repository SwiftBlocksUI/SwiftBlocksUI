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
    
    public typealias YearMonthDay = Block.DatePicker.YearMonthDay

    case button        (String)
    case plainTextInput(String)
    case option        (value  : String)
    case options       (values : [ String ])
    case date          (YearMonthDay)
    
    public var value : Any { // rather fix the callers
      switch self {
        case .button        (let value)  : return value
        case .plainTextInput(let value)  : return value
        case .option        (let value)  : return value
        case .options       (let values) : return values
        case .date          (let value)  : return value
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
    }
    
    public init(from decoder: Decoder) throws {
      typealias Error = InteractiveRequest.DecodingError
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      let type =
        try container.decode(Block.InteractiveElementType.self, forKey: .type)
      
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
            try container.decode(YearMonthDay.self, forKey: .selectedDate))

        default: // just be dynamic here
          if let opt = try? container.decode(Option.self,
                                             forKey: .selectedOption)
          {
            self = .option(value: opt.value)
          }
          else if let opts = try? container.decode([ Option ].self,
                                                   forKey: .selectedOptions)
          {
            self = .options(values: opts.map { $0.value })
          }
          else {
            assertionFailure("unsupported form value: \(type)")
            throw Error.unsupportedViewStateValue
          }
      }
    }
  }
}
