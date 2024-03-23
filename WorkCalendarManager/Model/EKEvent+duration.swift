//
//  EKEvent+getDuration.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 23/03/2024.
//

import EventKit

extension EKEvent {
	
	/// Event duration in seconds
	var duration: Int {
		Int(self.endDate.timeIntervalSince(self.startDate))
	}
}
