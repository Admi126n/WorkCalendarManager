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
			UserSettings.setWorkCalendarIdentifiers(workCalendars)
		}
	}
	
	@Published var allCalendars: [EKCalendar]
	
	init(_ eventStore: EKEventStore) {
		self.workCalendars = UserSettings.getCalendarsFromIdentifiers(eventStore)
		self.allCalendars = []
	}
	
}
