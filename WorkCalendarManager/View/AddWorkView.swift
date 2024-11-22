//
//  AddWorkView.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 19/03/2024.
//

import EventKit
import SwiftUI

struct AddWorkView: View {
	
	@Environment(\.dismiss) var dismiss
	
	@EnvironmentObject var localState: LocalState
	
	@State private var startDate = Date().startOfMonth
	@State private var endDate = Date().endOfMonth
	@State private var selectedCalendar: EKCalendar
	
	let eventStore: EKEventStore
	
	var body: some View {
		NavigationStack {
			Form {
				Section("Dates") {
					DatePicker(
						"From date",
						selection: $startDate,
						in: Date().startOfMonth...,
						displayedComponents: .date)
					
					DatePicker(
						"To date",
						selection: $endDate,
						in: startDate...,
						displayedComponents: .date)
				}
				
				Section {
					ForEach(localState.allCalendars, id: \.self) { calendar in
						HStack {
							Circle()
								.frame(width: 10)
								.foregroundStyle(Color(cgColor: calendar.cgColor))
							
							Text(calendar.title)
							
							Spacer()
							
							if selectedCalendar == calendar {
								Image(systemName: "checkmark")
									.foregroundStyle(.green)
							}
						}
						.contentShape(.rect)
						.onTapGesture {
							selectedCalendar = calendar
						}
					}
				} header: {
					Text("Calendar")
				} footer: {
					Text("Select calendar in which new work events will be added")
				}
				
				Button {
					print("Adding")
					var eventCreator = EventsCreator(
						startDate: startDate,
						endDate: endDate,
						calendar: selectedCalendar,
						eventStore: eventStore,
						userCalendars: localState.allCalendars,
						ignoredCalendars: localState.ignoredCalendars)
					
					eventCreator.createWork()
				} label: {
					Spacer()
					
					Text("Add")
					
					Spacer()
				}
				.buttonStyle(.borderedProminent)
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
			.onChange(of: startDate) { _, newValue in
				if newValue > endDate {
					endDate = newValue
				}
			}
		}
	}
	
	init(eventStore: EKEventStore) {
		self.eventStore = eventStore
		self.selectedCalendar = eventStore.defaultCalendarForNewEvents!
	}
}

#Preview {
	AddWorkView(eventStore: EKEventStore())
}
