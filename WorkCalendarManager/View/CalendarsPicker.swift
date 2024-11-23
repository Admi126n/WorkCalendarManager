//
//  CalendarsPicker.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 02/04/2024.
//

import EventKit
import SwiftUI

struct CalendarsPicker: View {
	
	@Binding var selectedCalendars: [EKCalendar]
	
	let calendars: [EKCalendar]
	let title: String
	
	var body: some View {
		List {
			ForEach(calendars, id: \.self) { cal in
				HStack {
					Circle()
						.frame(width: 10)
						.foregroundStyle(Color(cgColor: cal.cgColor))
					
					Text(cal.title)
					
					Spacer()
					
					if selectedCalendars.contains(cal) {
						Image(systemName: "checkmark")
							.foregroundStyle(.green)
					}
				}
				.contentShape(.rect)
				.onTapGesture {
					if !selectedCalendars.contains(cal) {
						// Add calendar to selected
						selectedCalendars.append(cal)
						// Remove calendar from selected
					} else if let index = selectedCalendars.firstIndex(of: cal) {
						selectedCalendars.remove(at: index)
					}
				}
			}
		}
		.navigationTitle(title)
	}
	
	init(title: String, selectedCalendars: Binding<[EKCalendar]>, calendars: [EKCalendar]) {
		self._selectedCalendars = selectedCalendars
		self.calendars = calendars
		self.title = title
	}
}

#Preview {
	CalendarsPicker(title: "Example", selectedCalendars: .constant([]), calendars: [])
}
