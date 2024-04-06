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
	
	@EnvironmentObject var userSettings: LocalState
	
	@State private var c: [EKCalendar] = []
	
    var body: some View {
		NavigationStack {
			Form {
				Text("Settings")
					.font(.title)
					.fontDesign(.serif)
				
				NavigationLink(value: SelectedField.workCalendars) {
					Text("Select calendars")
				}
			}
			.navigationDestination(for: SelectedField.self) { selectedField in
				switch selectedField {
				case .workCalendars:
					CalendarsPicker(
						selectedCalendars: $userSettings.workCalendars,
						calendars: userSettings.allCalendars)
				}
			}
		}
    }
}

#Preview {
    SettingsView()
}
