//
//  SettingsView.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 19/03/2024.
//

import EventKit
import SwiftUI

struct SettingsView: View {
	
	@EnvironmentObject var localState: LocalState
	
	@FocusState var focused: Bool
	
	@State private var c: [EKCalendar] = []
	
    var body: some View {
		NavigationStack {
			Form {
				Section("Calendars") {
					CalendarPickerLink(
						navigationValue: .workCalendars,
						selectedElementsCount: localState.workCalendars.count)
				
					CalendarPickerLink(
						navigationValue: .ignoredCalendars,
						selectedElementsCount: localState.ignoredCalendars.count)
				}
				
				Section {
					TextField("Salary", value: $localState.salaryPerHour, format: .currency(code: "PLN"))
						.keyboardType(.decimalPad)
						.focused($focused)
				} header: {
					Text("Salary per hour")
				} footer: {
					Text("Based on it app can calculate your month salary")
				}
				
				Section("Monthly hours goal") {
					Stepper("\(localState.monthlyHoursGoal) hours", value: $localState.monthlyHoursGoal, in: 80...160)
				}
				
				Section("Buisness day") {
					Picker("Start hour", selection: $localState.dayStartHour) {
						ForEach(6..<11) {
							Text("\($0):00")
								.tag($0)
						}
					}
					
					Picker("End hour", selection: $localState.dayEndHour) {
						ForEach(12..<21) {
							Text("\($0):00")
								.tag($0)
						}
					}
				}
				
				Section("Duration") {
					Picker("Minimum duration", selection: $localState.minDuration) {
						ForEach(1..<5) {
							Text("\($0) hours")
								.tag($0)
						}
					}
					
					Picker("Maximum duration", selection: $localState.maxDuration) {
						ForEach(5..<13) {
							Text("\($0) hours")
								.tag($0)
						}
					}
				}
				
				Section("Margins") {
					Picker("Margin before work", selection: $localState.marginBefore) {
						ForEach(1..<9) {
							Text("\($0 * 15) minutes")
								.tag($0)
						}
					}
					
					Picker("Margin after work", selection: $localState.marginAfter) {
						ForEach(1..<9) {
							Text("\($0 * 15) minutes")
								.tag($0)
						}
					}
				}
			}
			.navigationDestination(for: SelectedField.self) { selectedField in
				switch selectedField {
				case .workCalendars:
					CalendarsPicker(
						title: "Work calendars",
						selectedCalendars: $localState.workCalendars,
						calendars: localState.allCalendars)
				case .ignoredCalendars:
					CalendarsPicker(
						title: "Ignored calendars",
						selectedCalendars: $localState.ignoredCalendars,
						calendars: localState.allCalendars)
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .keyboard) {
					HStack {
						Spacer()
						
						Button("Done") {
							focused = false
						}
					}
				}
			}
		}
    }
}

// MARK: - Helper struct and enum

fileprivate enum SelectedField: String {
	case ignoredCalendars = "Ignored"
	case workCalendars = "Work"
}

fileprivate struct CalendarPickerLink: View {
	let navigationValue: SelectedField
	let selectedElementsCount: Int
	
	var body: some View {
		NavigationLink(value: navigationValue) {
			HStack {
				Text(navigationValue.rawValue)
				
				Spacer()
				
				Text("\(selectedElementsCount) selected")
					.foregroundStyle(.secondary)
			}
		}
	}
}

// MARK: - Preview

#Preview {
    SettingsView()
		.environmentObject(LocalState(EKEventStore()))
}
