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

enum UserSettings {
	
	private static var workCalendars = UserDefaultsElement(key: K.workCalendarsIdentifiers)
	private static var ignoredCalendars = UserDefaultsElement(key: K.ignoredCalendarsIdentifiers)
	
	static var dayStartHour: Int {
		get { UserDefaults.standard.value(forKey: K.startHour) as? Int ?? 7 }
		set { UserDefaults.standard.set(newValue, forKey: K.startHour) }
	}

	static var dayEndHour: Int {
		get { UserDefaults.standard.value(forKey: K.endHour) as? Int ?? 15 }
		set { UserDefaults.standard.set(newValue, forKey: K.endHour) }
	}
	
	/// Duration in hours
	static var minDuration: Int {
		get { UserDefaults.standard.value(forKey: K.minDuration) as? Int ?? 3 }
		set { UserDefaults.standard.set(newValue, forKey: K.minDuration) }
	}
	
	/// Duration in hours
	static var maxDuration: Int {
		get { UserDefaults.standard.value(forKey: K.maxDuration) as? Int ?? 8 }
		set { UserDefaults.standard.set(newValue, forKey: K.maxDuration) }
	}
	
	/// Number of quaters
	///
	/// 1 is treated as 15 minutes
	static var marginBefore: Int {
		get { UserDefaults.standard.value(forKey: K.magrinBefore) as? Int ?? 4 }
		set { UserDefaults.standard.set(newValue, forKey: K.magrinBefore) }
	}
	
	/// Number of quaters
	///
	/// 1 is treated as 15 minutes
	static var marginAfter: Int {
		get { UserDefaults.standard.value(forKey: K.magrinAfter) as? Int ?? 4 }
		set { UserDefaults.standard.set(newValue, forKey: K.magrinAfter) }
	}
	
	static var salaryPerHour: Float {
		get { UserDefaults.standard.float(forKey: K.salaryPerHour) }
		set { UserDefaults.standard.set(newValue, forKey: K.salaryPerHour) }
	}

	/// Identifier of last calendar selected for new events
	static var lastSelectedCalendar: String {
		get { UserDefaults.standard.string(forKey: K.lastSelectedCalendar) ?? "" }
		set { UserDefaults.standard.set(newValue, forKey: K.lastSelectedCalendar) }
	}
	
	static var monthlyHoursGoal: Int {
		get { UserDefaults.standard.value(forKey: K.monthlyHoursGoal) as? Int ?? 100 }
		set { UserDefaults.standard.set(newValue, forKey: K.monthlyHoursGoal) }
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
