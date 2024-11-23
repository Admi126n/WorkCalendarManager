//
//  MonthSalaryView.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 18/06/2024.
//

import SwiftUI

struct MonthSalaryView: View {
	
	let currencyCode: String
	let month: String
	let salary: Double
	
    var body: some View {
		VStack {
			Text(salary, format: .currency(code: currencyCode))
				.fontDesign(.rounded)
				.bold()
				.font(.system(size: 100))
				.lineLimit(1)
				.minimumScaleFactor(0.01)
				.padding(.horizontal, 32)
			
			Text("Salary for \(month)")
				.foregroundStyle(.secondary)
		}
		.background(.background)
		.padding(.bottom)
    }
	
	init(salary: Double, month: String, currencyCode: String) {
		self.currencyCode = currencyCode
		self.month = month
		self.salary = salary
	}
}

#Preview {
	MonthSalaryView(salary: 123.45, month: "June", currencyCode: "PLN")
}
