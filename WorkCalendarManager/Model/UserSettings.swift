//
//  UserSettings.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 04/04/2024.
//

import EventKit

class UserSettings: ObservableObject {
	
	@Published var workCalendars: [EKCalendar] = []
	@Published var allCalendars: [EKCalendar] = []
	
}
