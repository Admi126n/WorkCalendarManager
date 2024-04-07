//
//  UserSettings.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 06/04/2024.
//

import EventKit

struct UserSettings {
	
	static var workCalendarsIdentifiers: [String] {
		get {
			if let array = UserDefaults.standard.array(forKey: K.workCalendarsIdentifiers) as? [String] {
				return array
			} else {
				return []
			}
		}
		
		set(newValue) {
			UserDefaults.standard.set(newValue, forKey: K.workCalendarsIdentifiers)
		}
	}
	
	static func setWorkCalendarIdentifiers(_ calendars: [EKCalendar]) {
		workCalendarsIdentifiers = calendars.map { $0.calendarIdentifier }
	}
	
	static func getCalendarsFromIdentifiers(_ eventStore: EKEventStore) -> [EKCalendar] {
		workCalendarsIdentifiers.compactMap { id in
			if let calendar = eventStore.calendar(withIdentifier: id) {
				return calendar
			} else {
				// remove calendar identifier if there is no calendar for it
				remove(identifier: id)
				return nil
			}
		}
	}
	
	private static func remove(identifier: String) {
		if let index = workCalendarsIdentifiers.firstIndex(of: identifier) {
			workCalendarsIdentifiers.remove(at: index)
		}
	}
}
