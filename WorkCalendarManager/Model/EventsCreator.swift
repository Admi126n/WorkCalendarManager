//
//  EventsCreator.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 17/11/2024.
//

import EventKit
import Foundation

struct EventsCreator {
	
	private var availabilityDict: [Date: Bool] = [:]
	
	let startDate: Date
	let endDate: Date
	let calendar: EKCalendar
	let eventStore: EKEventStore
	let userCalendars: [EKCalendar]
	let ignoredCalendars: [EKCalendar]
	
	init(startDate: Date,
		 endDate: Date,
		 calendar: EKCalendar,
		 eventStore: EKEventStore,
		 userCalendars: [EKCalendar],
		 ignoredCalendars: [EKCalendar]
	) {
		self.startDate = startDate
		self.endDate = endDate
		self.calendar = calendar
		self.eventStore = eventStore
		self.userCalendars = userCalendars
		self.ignoredCalendars = ignoredCalendars
	}
	
	mutating func createWork() {
		var day = startDate
		
		while day < endDate {
			defer {
				day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
			}
			
			guard day.weekday != 1 && day.weekday != 7 else { continue }
			
			iterateOverAvailabilityDict(on: day)
		}
	}
	
	private mutating func iterateOverAvailabilityDict(on day: Date) {
		var slotIsEmpty = false
		var workStartDate: Date = Date()
		var workEndDate: Date = Date()
		
		fillAvailabilityDict(for: day)
		
		for (date, available) in availabilityDict.sorted(by: { $0.0 < $1.0 }) {
			if available {
				if !slotIsEmpty {
					workStartDate = date
				}
				slotIsEmpty = true
				workEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
				
				if workEndDate >= day.getCopyWithHour(UserSettings.dayEndHour) {
					createWorkEvent(workStartDate, workEndDate)
					break
				}
				
				if Int(workStartDate.distance(to: workEndDate)) / 3600 == UserSettings.maxDuration {
					eventStore.saveEvent(withStart: workStartDate, end: workEndDate, in: calendar)
					break
				}
			} else {
				if slotIsEmpty {
					createWorkEvent(workStartDate, workEndDate)
				}
				slotIsEmpty = false
			}
		}
	}
	
	/// Checks all events in given day in 15 minutes intervals
	/// - Parameter d: number of day in month
	mutating func fillAvailabilityDict(for day: Date) {
		availabilityDict = [:]
		
		var searchingStartDate = day.getCopyWithHour(UserSettings.dayStartHour)
		var searchingEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingStartDate)!
		let businessDayEndDate = day.getCopyWithHour(UserSettings.dayEndHour + 1)
		var eventsList: [EKEvent] = []
		
		repeat {
			for calendar in userCalendars {
				guard !(ignoredCalendars.contains(calendar)
						|| calendar.isImmutable) else { continue }
				
				eventsList += eventStore.getEventsBetween(searchingStartDate, searchingEndDate, for: calendar)
			}
			
			if eventsList.isEmpty {
				if availabilityDict[searchingStartDate] == nil {
					availabilityDict[searchingStartDate] = true
				}
			} else {
				availabilityDict[searchingStartDate] = false
				
				blockAvailability(for: -UserSettings.marginBefore, from: searchingStartDate)
				blockAvailability(for: UserSettings.marginAfter, from: searchingStartDate)
			}
			
			searchingStartDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingStartDate)!
			searchingEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingEndDate)!
			
			eventsList = []
		} while searchingEndDate <= businessDayEndDate
	}
	
	private mutating func blockAvailability(for quaters: Int, from date: Date) {
		if quaters == 0 {
			return
		}
		
		for i in 1...abs(quaters) {
			let dist = 15 * i * quaters.signum()
			availabilityDict[Calendar.current.date(byAdding: .minute, value: dist, to: date)!] = false
		}
	}
	
	private func createWorkEvent(_ workStartDate: Date, _ workEndDate: Date) {
		var eventEndDate = workEndDate
		let workDuration = Int(workStartDate.distance(to: eventEndDate))
		
		if workDuration / 3600 < UserSettings.minDuration { return }
		
		if workDuration % 3600 == 0 {
			if workDuration / 3600 <= UserSettings.maxDuration {
				eventStore.saveEvent(withStart: workStartDate, end: eventEndDate, in: calendar)
			} else {
				eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
				eventStore.saveEvent(withStart: workStartDate, end: eventEndDate, in: calendar)
			}
		} else {
			eventEndDate = cutEventToFullHour(startDate: workStartDate, endDate: eventEndDate)
			if workDuration / 3600 <= UserSettings.maxDuration {
				eventStore.saveEvent(withStart: workStartDate, end: eventEndDate, in: calendar)
			} else {
				eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
				eventStore.saveEvent(withStart: workStartDate, end: eventEndDate, in: calendar)
			}
		}
	}
	
	private func cutEventToMaxDuration(startDate: Date, endDate: Date) -> Date {
		let hoursToCut = Int(startDate.distance(to: endDate) / 3600) % UserSettings.maxDuration
		let newEndDate = Calendar.current.date(byAdding: .hour, value: -hoursToCut, to: endDate)!
		
		return newEndDate
	}
	
	private func cutEventToFullHour(startDate: Date, endDate: Date) -> Date {
		let secondsToCut = Int(startDate.distance(to: endDate)) % 3600
		let newEndDate = Calendar.current.date(byAdding: .second, value: -secondsToCut, to: endDate)!
		
		return newEndDate
	}
}
