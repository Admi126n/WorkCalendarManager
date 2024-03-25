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
		
		@Published private(set) var workTime: [WorkTime] = []
		
		private let eventStore = EKEventStore()
		
		init() {
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
		///   - calendar: Calendar to fetch events from
		/// - Returns: Duration of events in seconds
		private func getWorkDuration(for month: Date, fromCalendar calendar: EKCalendar) -> Int {
			let events = CalendarConnector.getEvents(
				fromCalendar: eventStore.defaultCalendarForNewEvents!,
				from: month.startOfMonth,
				to: month.endOfMonth,
				eventStore)
			
			return CalendarCalculator.getDuration(of: events)
		}
		
		/// Fetches events from user calendar and fills `workTime` list
		func getWorkTimePerMonth() {
			guard accessGranted else { return }
			
			withAnimation {
				workTime = []
			}
			
			let months = CalendarCalculator.getMonths()
			
			for (name, month) in months {
				let duration = getWorkDuration(
					for: month,
					fromCalendar: eventStore.defaultCalendarForNewEvents!)
					
				withAnimation {
					workTime.append(WorkTime(month: name, hours: Float(duration) / 3600.0))
				}
			}
		}
	}
}
