//
//  EKEventStore+utilities.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 17/11/2024.
//

import EventKit

extension EKEventStore {
	
	private func createPredicate(withStart start: Date, end: Date, for calendar: EKCalendar) -> NSPredicate {
		self.predicateForEvents(withStart: start, end: end, calendars: [calendar])
	}
	
	func getEventsBetween(_ start: Date, _ end: Date, for calendar: EKCalendar) -> [EKEvent] {
		self.events(matching: self.createPredicate(withStart: start, end: end, for: calendar))
	}
	
	func saveEvent(withStart start: Date, end: Date, in calendar: EKCalendar) {
		let newEvent = EKEvent(eventStore: self)
		
		newEvent.title = EventParameters.title
		newEvent.notes = EventParameters.notes
		newEvent.startDate = start
		newEvent.endDate = end
		newEvent.calendar = calendar
		
		try? self.save(newEvent, span: .thisEvent)
	}
}
