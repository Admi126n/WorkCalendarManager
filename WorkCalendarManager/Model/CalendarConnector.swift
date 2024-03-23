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
	func getEvents(fromCalendars calendars: [EKCalendar], from: Date, to: Date, _ eventStore: EKEventStore) -> [EKEvent] {
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
	func getEvents(fromCalendar calendar: EKCalendar, from: Date, to: Date, _ eventStore: EKEventStore) -> [EKEvent] {
		getEvents(fromCalendars: [calendar], from: from, to: to, eventStore)
	}
	
	/// Returns sum of seconds between `startDate` and `endDate` of given events
	/// - Parameter events: Events to count duration
	/// - Returns: Sum of events duration in seconds
	func getDuration(of events: [EKEvent]) -> Int {
		events.reduce(0) { partialResult, event in
			partialResult + event.duration
		}
	}
	
	func getHoursAndMinutes(from seconds: Int) -> (hours: Int, minutes: Int) {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		
		return (hours, minutes)
	}
}
