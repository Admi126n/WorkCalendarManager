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
	
	@Published var ignoredCalendars: [EKCalendar] {
		didSet {
			UserSettings.setIgnoredCalendarsIdentifiers(ignoredCalendars)
		}
	}
	
	@Published var salaryPerHour: Double {
		didSet {
			UserSettings.setSalaryPerHour(salaryPerHour)
		}
	}
	
	@Published var allCalendars: [EKCalendar]
	
	init(_ eventStore: EKEventStore) {
		self.workCalendars = UserSettings.getWorkCalendars(eventStore)
		self.ignoredCalendars = UserSettings.getIgnoredCalendars(eventStore)
		self.salaryPerHour = UserSettings.getSalaryPerHour()
		self.allCalendars = []
	}	
}
