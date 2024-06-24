//
//  ChartContainer.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 19/06/2024.
//

import SwiftUI

struct ChartContainer<Content> : View where Content : View {
	
	let chart: Content
	let title: String
	let height: CGFloat
	
	var body: some View {
		VStack {
			Text(title)
				.font(.headline)
				.fontDesign(.rounded)
			
			chart
				.chartYAxis(.hidden)
				.frame(height: height)
		}
		.padding(8)
		.background(.ultraThinMaterial)
		.clipShape(.rect(cornerRadius: 10))
	}
	
	init(title: String, _ height: CGFloat = 100, @ViewBuilder chart: () -> Content) {
		self.chart = chart()
		self.height = height
		self.title = title
	}
}
