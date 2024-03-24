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
	static func getDuration(of events: [EKEvent]) -> Int {
		events.reduce(0) { partialResult, event in
			partialResult + event.duration
		}
	}
	
	/// Returns number of hours and minutes from given seconds
	/// - Parameter seconds: Seconds to calculate hours and minutes
	/// - Returns: Hours and minutes
	static func getHoursAndMinutes(from seconds: Int) -> (hours: Int, minutes: Int) {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		
		return (hours, minutes)
	}
	
	/// Returns list of five months
	///
	/// Returned value contains current month, two past months and two next months. List is sorted from oldest to newest month.
	/// - Returns: List with month short name and date
	static func getMonths() -> [(monthName: String, date: Date)] {
		// now
		let currentDate = Date.now
		
		// month ago
		let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
		
		// two months ago
		let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: currentDate)!
		
		// after one month. One hour have to be added because after adding one month date is
		// one hour lower than expected
		var afterOneMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
		afterOneMonth = Calendar.current.date(byAdding: .hour, value: 1, to: afterOneMonth)!
		
		// after two months
		var afterTwoMonths = Calendar.current.date(byAdding: .month, value: 2, to: currentDate)!
		afterTwoMonths = Calendar.current.date(byAdding: .hour, value: 1, to: afterTwoMonths)!
		
		return [
			(twoMonthsAgo.monthShortName, twoMonthsAgo),
			(oneMonthAgo.monthShortName, oneMonthAgo),
			(currentDate.monthShortName, currentDate),
			(afterOneMonth.monthShortName, afterOneMonth),
			(afterTwoMonths.monthShortName, afterTwoMonths),
		]
	}
}
