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
			}
			.navigationDestination(for: SelectedField.self) { selectedField in
				switch selectedField {
				case .workCalendars:
					CalendarsPicker(
						selectedCalendars: $localState.workCalendars,
						calendars: localState.allCalendars)
				case .ignoredCalendars:
					CalendarsPicker(
						selectedCalendars: $localState.ignoredCalendars,
						calendars: localState.allCalendars)
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
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
