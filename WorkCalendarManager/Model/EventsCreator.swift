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
	
	var startDateDay: Int {
		Calendar.current.component(.day, from: startDate)
	}
	
	var endDateDay: Int {
		Calendar.current.component(.day, from: endDate)
	}
	
	mutating func iterateOverDays() {
		var day = startDate
		
		while day < endDate {
			defer {
				day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
			}
			
			let tempWeekday = Calendar.current.component(.weekday, from: day)
			
			if tempWeekday == 1 || tempWeekday == 7 {
				continue
			}
			
			iterateOverAvailabilityDict(on: day)
		}
	}
	
	private mutating func iterateOverAvailabilityDict(on day: Date) {
		var slotIsEmpty = false
		var workStartDate: Date = Date()
		var workEndDate: Date = Date()
		
		fillAvailabilityDict(for: day)
		
		for (date, availability) in availabilityDict.sorted(by: { $0.0 < $1.0 }) {
			if availability {
				if !slotIsEmpty {
					workStartDate = date
				}
				slotIsEmpty = true
				workEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
				
				if workEndDate >= CalendarManager.cm.set(hour: UserSettings.dayEndHour, to: day) {
					calculateWorkEvent(workStartDate, workEndDate)
					break
				}
				
				if Int(workStartDate.distance(to: workEndDate)) / 3600 == UserSettings.workMaxDuration {
					CalendarManager.cm.createEvent(startHour: workStartDate, endHour: workEndDate, eventStore: eventStore, calendar: calendar)
					break
				}
			} else {
				if slotIsEmpty {
					calculateWorkEvent(workStartDate, workEndDate)
				}
				slotIsEmpty = false
			}
		}
	}
	
	/// Checks all events in given day in 15 minutes intervals
	/// - Parameter d: number of day in month
	mutating func fillAvailabilityDict(for day: Date) {
		availabilityDict = [:]
		
		var searchingStartDate = CalendarManager.cm.set(hour: UserSettings.dayStartHour, to: day)
		var searchingEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingStartDate)!
		let businessDayEndDate = CalendarManager.cm.set(hour: UserSettings.dayEndHour + 1, to: day)
		var eventsList: [EKEvent] = []
		
		repeat {
			for calendar in userCalendars {
				guard !(ignoredCalendars.contains(calendar)
						|| calendar.isImmutable) else { continue }
				
				let predicate = CalendarManager.cm.createPredicate(withStart: searchingStartDate, end: searchingEndDate, for: [calendar], eventStore: eventStore)
				eventsList += CalendarManager.cm.getEventsList(matching: predicate, eventStore: eventStore)
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
	
	private func calculateWorkEvent(_ workStartDate: Date, _ workEndDate: Date) {
		var eventEndDate = workEndDate
		let workDuration = Int(workStartDate.distance(to: eventEndDate))
		
		if workDuration / 3600 < UserSettings.workMinDuration { return }
		
		if workDuration % 3600 == 0 {
			if workDuration / 3600 <= UserSettings.workMaxDuration {
				CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate, eventStore: eventStore, calendar: calendar)
			} else {
				eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
				CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate, eventStore: eventStore, calendar: calendar)
			}
		} else {
			eventEndDate = cutEventToFullHour(startDate: workStartDate, endDate: eventEndDate)
			if workDuration / 3600 <= UserSettings.workMaxDuration {
				CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate, eventStore: eventStore, calendar: calendar)
			} else {
				eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
				CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate, eventStore: eventStore, calendar: calendar)
			}
		}
	}
	
	private func cutEventToMaxDuration(startDate: Date, endDate: Date) -> Date {
		let hoursToCut = Int(startDate.distance(to: endDate) / 3600) % UserSettings.workMaxDuration
		let newEndDate = Calendar.current.date(byAdding: .hour, value: -hoursToCut, to: endDate)!
		
		return newEndDate
	}
	
	private func cutEventToFullHour(startDate: Date, endDate: Date) -> Date {
		let secondsToCut = Int(startDate.distance(to: endDate)) % 3600
		let newEndDate = Calendar.current.date(byAdding: .second, value: -secondsToCut, to: endDate)!
		
		return newEndDate
	}
	
	init(startDate: Date, endDate: Date, calendar: EKCalendar, eventStore: EKEventStore, userCalendars: [EKCalendar], ignoredCalendars: [EKCalendar]) {
		self.startDate = startDate
		self.endDate = endDate
		self.calendar = calendar
		self.eventStore = eventStore
		self.userCalendars = userCalendars
		self.ignoredCalendars = ignoredCalendars
	}
}

struct CalendarManager {
	static var cm = CalendarManager()

	private var userTimeZoneIdentifier: String {
		return TimeZone.current.identifier
	}
	
	func createEvent(startHour: Date, endHour: Date, eventStore: EKEventStore, calendar: EKCalendar) {
		let newEvent = EKEvent(eventStore: eventStore)
		
		newEvent.title = EventParameters.title
		newEvent.notes = EventParameters.notes
		newEvent.startDate = startHour
		newEvent.endDate = endHour
		newEvent.calendar = calendar
		
		try? eventStore.save(newEvent, span: .thisEvent)
	}
	
	func set(hour: Int, to day: Date) -> Date {
		let userCalendar = Calendar.current
		var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from: day)
		
		dateComponents.hour = hour
		
		return userCalendar.date(from: dateComponents)!
	}
	
	func getEventsList(matching predicate: NSPredicate, eventStore: EKEventStore) -> [EKEvent] {
		return eventStore.events(matching: predicate)
	}
	
	func createPredicate(withStart startDate: Date, end endDate: Date, for calendars: [EKCalendar], eventStore: EKEventStore) -> NSPredicate {
		return eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
	}
}
