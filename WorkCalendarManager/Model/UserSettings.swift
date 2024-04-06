//
//  UserSettings.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 06/04/2024.
//

import Foundation

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
}
