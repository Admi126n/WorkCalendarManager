//
//  UserSettings.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 06/04/2024.
//

import EventKit

struct EventParameters {
	static let title = "Work"
	static let notes = "Created by WorkCalendarManager"
}

struct UserSettings {
	
	private static var workCalendars = UserDefaultsElement(key: K.workCalendarsIdentifiers)
	private static var ignoredCalendars = UserDefaultsElement(key: K.ignoredCalendarsIdentifiers)
	
	static var workCalendarsIdentifiers: [String] {
		get { workCalendars.elements }
		set(newValue) { workCalendars.elements = newValue }
	}
	
	static var ignoredCalendarsIdentifiers: [String] {
		get { ignoredCalendars.elements }
		set(newValue) { ignoredCalendars.elements = newValue }
	}
	
	#warning("TODO: Implement day start hour")
	static var dayStartHour: Int {
		7
	}
	
	#warning("TODO: Implement day end hour")
	static var dayEndHour: Int {
		15
	}
	
	#warning("TODO: Implement work min duration")
	static var workMinDuration: Int {
		2
	}
	
	#warning("TODO: Implement work max duration")
	static var workMaxDuration: Int {
		8
	}
	
	#warning("TODO: Implement margin before")
	static var marginBefore: Int {
		15
	}
	
	#warning("TODO: Implement margin after")
	static var marginAfter: Int {
		15
	}

	static func setWorkCalendarIdentifiers(_ calendars: [EKCalendar]) {
		workCalendars.setElements(calendars)
	}
	
	static func setIgnoredCalendarsIdentifiers(_ calendars: [EKCalendar]) {
		ignoredCalendars.setElements(calendars)
	}
	
	static func getWorkCalendars(_ eventStore: EKEventStore) -> [EKCalendar] {
		workCalendars.getCalendars(eventStore)
	}
	
	static func getIgnoredCalendars(_ eventStore: EKEventStore) -> [EKCalendar] {
		ignoredCalendars.getCalendars(eventStore)
	}
	
	static func setSalaryPerHour(_ salaryPerHour: Double) {
		UserDefaults.standard.set(salaryPerHour, forKey: K.salaryPerHour)
	}
	
	static func getSalaryPerHour() -> Double {
		UserDefaults.standard.double(forKey: K.salaryPerHour)
	}
}

// MARK: - Helper struct

fileprivate struct UserDefaultsElement {
	
	/// Key under which `elements` will be saved in `UserDefaults`
	let key: String
	
	/// List of elements saved in `UserDefaults` under `key` given in init
	var elements: [String] {
		get {
			if let array = UserDefaults.standard.array(forKey: key) as? [String] {
				return array
			} else {
				return []
			}
		}
		
		set(newValue) {
			UserDefaults.standard.set(newValue, forKey: key)
		}
	}
	
	/// Removes given element from `elements`
	///
	/// If given element is not present in `elements` method has no effect.
	/// - Parameter element: Element to remove
	mutating func remove(element: String) {
		if let index = elements.firstIndex(of: element) {
			elements.remove(at: index)
		}
	}
	
	/// Maps given `calendars` list into list of `calendarIdentifier`
	/// - Parameter calendars: Calendars to set
	mutating func setElements(_ calendars: [EKCalendar]) {
		elements = calendars.map { $0.calendarIdentifier }
	}
	
	/// Returns list of `EKCalendar` from given `EKEventStore`
	///
	/// Calendars are get by identifiers saved in `elements`
	/// - Parameter eventStore: EventStore to get calendars from
	/// - Returns: List of calendars
	mutating func getCalendars(_ eventStore: EKEventStore) -> [EKCalendar] {
		elements.compactMap { id in
			if let calendar = eventStore.calendar(withIdentifier: id) {
				return calendar
			} else {
				// remove calendar identifier if there is no calendar for it
				remove(element: id)
				return nil
			}
		}
	}
}
