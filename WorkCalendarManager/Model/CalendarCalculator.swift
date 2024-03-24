//
//  CalendarCalcularot.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 23/03/2024.
//

import EventKit

struct CalendarCalculator {
	
	/// Returns sum of seconds between `startDate` and `endDate` of given events
	/// - Parameter events: Events to count duration
	/// - Returns: Sum of events duration in seconds
	func getDuration(of events: [EKEvent]) -> Int {
		events.reduce(0) { partialResult, event in
			partialResult + event.duration
		}
	}
	
	/// Returns number of hours and minutes from given seconds
	/// - Parameter seconds: Seconds to calculate hours and minutes
	/// - Returns: Hours and minutes
	func getHoursAndMinutes(from seconds: Int) -> (hours: Int, minutes: Int) {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		
		return (hours, minutes)
	}
}
