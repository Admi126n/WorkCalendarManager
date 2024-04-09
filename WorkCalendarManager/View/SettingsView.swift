//
//  SettingsView.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 19/03/2024.
//

import EventKit
import SwiftUI

fileprivate enum SelectedField {
	case workCalendars
}

struct SettingsView: View {
	
	@EnvironmentObject var localState: LocalState
	
	@State private var c: [EKCalendar] = []
	
    var body: some View {
		NavigationStack {
			Form {
				Section("Work calendars") {
					NavigationLink(value: SelectedField.workCalendars) {
						HStack {
							Text("Select calendars")
							
							Spacer()
							
							Text("\(localState.workCalendars.count) selected")
								.foregroundStyle(.secondary)
						}
					}
				}
			}
			.navigationDestination(for: SelectedField.self) { selectedField in
				switch selectedField {
				case .workCalendars:
					CalendarsPicker(
						selectedCalendars: $localState.workCalendars,
						calendars: localState.allCalendars)
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
		}
    }
}

#Preview {
    SettingsView()
		.environmentObject(LocalState(EKEventStore()))
}
