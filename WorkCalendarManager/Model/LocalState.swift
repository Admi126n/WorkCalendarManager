//
//  UserSettings.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 04/04/2024.
//

import EventKit

class LocalState: ObservableObject {
	
	@Published var workCalendars: [EKCalendar] {
		didSet { UserSettings.setWorkCalendarIdentifiers(workCalendars) }
	}
	
	@Published var ignoredCalendars: [EKCalendar] {
		didSet { UserSettings.setIgnoredCalendarsIdentifiers(ignoredCalendars) }
	}
	
	@Published var salaryPerHour: Float {
		didSet { UserSettings.salaryPerHour = salaryPerHour }
	}
	
	@Published var dayStartHour: Int {
		didSet { UserSettings.dayStartHour = dayStartHour }
	}
	
	@Published var dayEndHour: Int {
		didSet { UserSettings.dayEndHour = dayEndHour }
	}
	
	@Published var marginBefore: Int {
		didSet { UserSettings.marginBefore = marginBefore }
	}
	
	@Published var marginAfter: Int {
		didSet { UserSettings.marginAfter = marginAfter }
	}
	
	@Published var minDuration: Int {
		didSet { UserSettings.minDuration = minDuration }
	}
	
	@Published var maxDuration: Int {
		didSet { UserSettings.maxDuration = maxDuration }
	}
	
	@Published var lastSelectedCalendar: String {
		didSet { UserSettings.lastSelectedCalendar = lastSelectedCalendar }
	}
	
	@Published var monthlyHoursGoal: Int {
		didSet { UserSettings.monthlyHoursGoal = monthlyHoursGoal }
	}
	
	@Published var allCalendars: [EKCalendar]
	
	init(_ eventStore: EKEventStore) {
		self.workCalendars = UserSettings.getWorkCalendars(eventStore)
		self.ignoredCalendars = UserSettings.getIgnoredCalendars(eventStore)
		self.salaryPerHour = UserSettings.salaryPerHour
		self.allCalendars = []
		
		self.dayStartHour = UserSettings.dayStartHour
		self.dayEndHour = UserSettings.dayEndHour
		
		self.marginBefore = UserSettings.marginBefore
		self.marginAfter = UserSettings.marginAfter
		
		self.minDuration = UserSettings.minDuration
		self.maxDuration = UserSettings.maxDuration
		
		self.lastSelectedCalendar = UserSettings.lastSelectedCalendar
		self.monthlyHoursGoal = UserSettings.monthlyHoursGoal
	}
}
