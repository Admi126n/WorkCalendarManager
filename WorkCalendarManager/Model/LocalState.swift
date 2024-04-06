//
//  UserSettings.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 04/04/2024.
//

import EventKit

class LocalState: ObservableObject {
	
	@Published var workCalendars: [EKCalendar] {
		didSet {
			UserSettings.workCalendarsIdentifiers = workCalendars.map { $0.calendarIdentifier }
		}
	}
	
	@Published var allCalendars: [EKCalendar]
	
	init(_ eventStore: EKEventStore) {
		workCalendars = UserSettings.workCalendarsIdentifiers.compactMap {
			// TODO: remove identifiers for which there is no calendar
			eventStore.calendar(withIdentifier: $0)
		}
		
		allCalendars = []
	}
	
}
