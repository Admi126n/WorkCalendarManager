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
				getSalaryPerMonth()
			}
		}
		
		@Published private(set) var localState: LocalState
		@Published private(set) var workTime: [WorkTime] = []
		@Published private(set) var salaryPerMonth: [SalaryPerMonth] = []
		
		private(set) var eventStore = EKEventStore()
		
		/// Calculated salary for current month
		var currentMonthSalary: Double {
			// when app is opened first time there is no data because of no access
			guard workTime.count == 5 else { return 0 }
			
			return localState.salaryPerHour * Double(workTime[2].hours)
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
		
		private func getSalaryPerMonth() {
			guard accessGranted else { return }
			
			withAnimation {
				salaryPerMonth = []
			}
			
			for (i, month) in workTime.enumerated() {
				withAnimation {
					salaryPerMonth.append(SalaryPerMonth(
						month: month.month,
						salary: Double(workTime[i].hours) * localState.salaryPerHour))
				}
			}
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
			getSalaryPerMonth()
			getUserCalendars()
		}
		
		/// Gets local calendars and sets `localState.allCalendars`
		func getUserCalendars() {
			guard accessGranted else { return }
			
			localState.allCalendars = CalendarConnector.getLocalCalendars(from: eventStore)
		}
	}
}
