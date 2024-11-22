//
//  UserDefaultsKeys.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 05/04/2024.
//

import Foundation

typealias K = UserDefaultsKeys

enum UserDefaultsKeys {
	
	static let workCalendarsIdentifiers = "workCalendarsIdentifiers"
	static let ignoredCalendarsIdentifiers = "ignoredCalendarsIdentifiers"
	static let salaryPerHour = "salaryPerHour"
	static let magrinBefore = "marginBefore"
	static let magrinAfter = "marginAfter"
	static let minDuration = "workMinDuration"
	static let maxDuration = "workMaxDuration"
	static let startHour = "startHour"
	static let endHour = "endHour"
}
