//
//  SalaryPerMonth.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 19/06/2024.
//

import Foundation

struct SalaryPerMonth: Identifiable {
	
	let id = UUID()
	let month: String
	let salary: Double
}
