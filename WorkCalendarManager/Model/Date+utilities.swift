//
//  Date+utilities.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 22/03/2024.
//

import Foundation

extension Date {
	
	/// Returns first moment of current month
	var startOfMonth: Date {
		let startOfToday = Calendar.current.startOfDay(for: self)
		let componentsOfToday = Calendar.current.dateComponents([.year, .month], from: startOfToday)
		return Calendar.current.date(from: componentsOfToday)!
	}
	
	/// Returns first moment of next month
	var endOfMonth: Date {
		Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
	}
	
	/// Returns short month name from date
	var monthShortName: String {
		let monthNum = Calendar.current.dateComponents([.month], from: self).month!
		
		return DateFormatter().shortMonthSymbols[monthNum - 1]
	}
}
