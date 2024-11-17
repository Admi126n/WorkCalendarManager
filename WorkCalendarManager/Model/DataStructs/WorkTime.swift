//
//  WorkTime.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 24/03/2024.
//

import Foundation

/// Struct for describing work time in month
struct WorkTime: Identifiable {
	let id = UUID()
	let month: String
	let hours: Float
}
