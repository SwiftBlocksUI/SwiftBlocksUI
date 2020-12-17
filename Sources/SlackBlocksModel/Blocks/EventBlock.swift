//
//  Event.swift
//  SlackBlocksModel
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL

public extension Block {
  
  /**
   * An Event block as used by the Google calendar integration.
   *
   * Those show up in a block w/ rounded corners.
   *
   * NOTE: Not public API, do not use.
   */
  struct Event: Encodable {

    public static let validInSurfaces : [ BlockSurfaceSet ]
                                      = [ .messages ]
    
    public struct EventInfo: Codable {
      
      public enum CalendarApplication: String, Codable {
        case googleCalendar = "gcal"
      }
      public struct Organizer: Codable {
        let email   : String
        let name    : String
        let user_id : String
      }
      public struct Attendee: Codable {
        let email   : String
        let name    : String
        let user_id : String
        let rsvp    : String // iCal RSVP, e.g. "needs_action"
      }
      
      var title               : String
      var info                : String
      var location            : String
      var numberOfAttendees   : Int
      var calendarApplication : CalendarApplication
      var needsRefetch        : Bool
      var webLink             : URL?
      
      var organizer           : Organizer
      var attendees           : [ Attendee ]
      var status              : String // iCal status, e.g. "confirmed"
      
      // TODO: start, end (nested, e.g. `start: { date_time = 1626262 }`)
      // TODO: copies
      // TODO: invite_permission: request

      enum CodingKeys: String, CodingKey {
        case title, location, organizer, attendees, status
        case info                = "description"
        case numberOfAttendees   = "attendee_count"
        case calendarApplication = "app_type"
        case needsRefetch        = "needs_refetch"
        case webLink             = "web_link"
      }
    }

    public var id      : BlockID
    public var eventID : String
    public var event   : EventInfo
    
    public init(id: BlockID, eventID: String, event: EventInfo) {
      self.id      = id
      self.eventID = eventID
      self.event   = event
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
      case id      = "block_id"
      case eventID = "event_id"
      case type, event
    }
      
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("event", forKey: .type)
      try container.encode(id,      forKey: .id)
      try container.encode(eventID, forKey: .eventID)
      try container.encode(event,   forKey: .event)
    }
  }
}


// MARK: - Markdown

public extension Block.Event {
  
  @inlinable
  var blocksMarkdownString : String {
    return "[events cannot be shown by this client]"
  }
}


// MARK: - Description

extension Block.Event: CustomStringConvertible {

  @inlinable
  public var description: String {
    return "<Event[\(id.id)]: id=\(eventID) \(event)>"
  }
}
