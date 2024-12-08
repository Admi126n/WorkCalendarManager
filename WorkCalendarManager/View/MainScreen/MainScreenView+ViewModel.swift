//
//  MainScreenView+ViewModel.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 21/03/2024.
//

import EventKit
import SwiftUI

extension MainScreenView {
	
	class ViewModel: ObservableObject {
		
		@Published private(set) var accessGranted: Bool = false {
			didSet {
				getWorkTimePerMonth()
			}
		}
		
		@Published private(set) var localState: LocalState
		@Published private(set) var workTime: [WorkTime] = []
		
		private(set) var eventStore = EKEventStore()
		
		/// Calculated next salary
		///
		/// Returns salary for next month if current day is less than 11. If day is greater
		/// or equal to 11 salary for current month is returned.
		var nextSalary: (salary: Float, month: String) {
			// when app is opened first time there is no data because of no access
			guard workTime.count == 5 else { return (0, "") }
			
			if Calendar.current.component(.day, from: .now) < 11 {
				let tempDate = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
				return (localState.salaryPerHour * workTime[1].hours, tempDate.monthLongName)
			} else {
				return (localState.salaryPerHour * workTime[2].hours, Date.now.monthLongName)
			}
		}
		
		var currencyCode: String {
			Locale.currencySymbol ?? "PLN"
		}
		
		init() {
			self.localState = LocalState(eventStore)
			
			let acces = EKEventStore.authorizationStatus(for: .event)
			
			if acces == .fullAccess {
				self.accessGranted = true
			} else {
				self.requestCalendarAccess()
			}
		}
		
		private func requestCalendarAccess() {
			eventStore.requestFullAccessToEvents { granted, error in
				Task { @MainActor in
					self.accessGranted = granted
				}
			}
		}
		
		/// Returns duration of all events from given `month` for given `calendar`
		/// - Parameters:
		///   - month: Month to fetch events from
		///   - calendars: Calendars to fetch events from
		/// - Returns: Duration of events in seconds
		private func getWorkDuration(for month: Date, fromCalendars calendars: [EKCalendar]) -> Int {
			let events = CalendarConnector.getEvents(
				fromCalendars: calendars,
				from: month.startOfMonth,
				to: month.endOfMonth,
				eventStore)
			
			return CalendarCalculator.getDuration(of: events)
		}
		
		/// Fetches events from user calendar and fills `workTime` list
		private func getWorkTimePerMonth() {
			guard accessGranted else { return }
			
			withAnimation {
				workTime = []
			}
			
			let months = CalendarCalculator.getMonths()
			
			for (name, month) in months {
				let duration = getWorkDuration(
					for: month,
					fromCalendars: localState.workCalendars)
				
				withAnimation {
					workTime.append(WorkTime(month: name, hours: Float(duration) / 3600.0))
				}
			}
		}
		
		func refresh() {
			getWorkTimePerMonth()
			getUserCalendars()
		}
		
		/// Gets local calendars and sets `localState.allCalendars`
		func getUserCalendars() {
			guard accessGranted else { return }
			
			localState.allCalendars = CalendarConnector.getLocalCalendars(from: eventStore)
		}
		
		func salary(in month: WorkTime) -> Float {
			month.hours * localState.salaryPerHour
		}
		
		func getColorFor(hours: Float, between: Color = .yellow, and: Color = .green) -> Color {
			let ratio = CGFloat(min(1, hours / Float(localState.monthlyHoursGoal)))
			
			let (r1, g1, b1) = between.conponents
			let (r2, g2, b2) = and.conponents
			
			let red = r1 - r2
			let green = g1 - g2
			let blue = b1 - b2
			
			return Color(red: r1 - red * ratio, green: g1 - green * ratio, blue: b1 - blue * ratio)
		}
	}
}
