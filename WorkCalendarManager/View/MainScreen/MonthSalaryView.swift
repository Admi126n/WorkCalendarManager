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
	let salary: Float
	
	@State private var isAnimated = false
	@State private var trigger = false
	
    var body: some View {
		VStack {
			Text("Next salary")
				.foregroundStyle(.secondary)
			
			Text(isAnimated ? Double(salary) : 0.0, format: .currency(code: currencyCode))
				.fontDesign(.rounded)
				.bold()
				.font(.system(size: 100))
				.lineLimit(1)
				.minimumScaleFactor(0.01)
				.padding(.horizontal, 32)
				.contentTransition(.numericText(value: Double(salary)))
				.animation(.snappy, value: salary)
			
			Text("for \(month)")
				.foregroundStyle(.secondary)
		}
		.background(.background)
		.padding(.bottom)
		.onAppear {
			resetAnimation()
		}
    }
	
	init(salary: Float, month: String, currencyCode: String) {
		self.currencyCode = currencyCode
		self.month = month
		self.salary = salary
	}
	
	private func animate() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			withAnimation {
				isAnimated = true
			}
		}
	}
	
	func resetAnimation() {
		isAnimated = false
		animate()
	}
}

#Preview {
	MonthSalaryView(salary: 123.45, month: "June", currencyCode: "PLN")
}
