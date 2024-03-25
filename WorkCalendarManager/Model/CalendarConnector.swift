//
//  CalendarConnector.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 21/03/2024.
//

import EventKit

struct CalendarConnector {
	
	/// Returns events from given `calendars` from given time range
	/// - Parameters:
	///   - calendars: Calendars to get events from
	///   - from: Start date of searching
	///   - to: End date of searching
	///   - eventStore: Instange of `EKEventStore`
	/// - Returns: List of  events
	static func getEvents(fromCalendars calendars: [EKCalendar], from: Date, to: Date, _ eventStore: EKEventStore) -> [EKEvent] {
		let predicate = eventStore.predicateForEvents(
			withStart: from,
			end: to,
			calendars: calendars)
		
		let events = eventStore.events(matching: predicate)
		
		return events
	}
	
	/// Returns events from given `calendar` from given time range
	/// - Parameters:
	///   - calendar: Calendar to get events from
	///   - from: Start date of searching
	///   - to: End date of searching
	///   - eventStore: Instange of `EKEventStore`
	/// - Returns: List of  events
	static func getEvents(fromCalendar calendar: EKCalendar, from: Date, to: Date, _ eventStore: EKEventStore) -> [EKEvent] {
		getEvents(fromCalendars: [calendar], from: from, to: to, eventStore)
	}
}
