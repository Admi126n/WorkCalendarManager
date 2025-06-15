//
//  MainScreenView.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 21/03/2024.
//

import Charts
import SwiftUI

struct MainScreenView: View {
	
	@State private var showingAddWork = false
	@State private var showingSettings = false
	@State private var isAnimated = false
	@State private var trigger = false
	@State private var value = 10.0
	@StateObject var vm = ViewModel()
	
	var body: some View {
		NavigationStack {
			ZStack {
				ScrollView {
					if vm.nextSalary != 0 {
						MonthSalaryView(
							salary: vm.nextSalary,
							month: vm.nextSalaryMonth,
							currencyCode: vm.currencyCode)
//					Slider(value: $value, in: 0...5000)
//					Button("Tap") {
//						if value == 10 {
//							value = 4000
//						} else {
//							value = 10
//						}
//					}
//					Text("\(vm.nextSalary)")
					}
					
					ChartContainer(title: String(localized: "Hours per month"), 300) {
						Chart(vm.workTime) { month in
							BarMark(
								x: .value("Month", month.month),
								y: .value("Hours", month.isAnimated ? month.hours : 0))
							.foregroundStyle(vm.getColorFor(hours: month.hours))
							.annotation {
								Text("\(month.hours, format: .number)")
									.font(.footnote)
									.foregroundStyle(month.hours != 0 ? Color.primary : Color.clear)
							}
							.annotation(position: .overlay, alignment: .center) {
								if month.hours >= Float(vm.localState.monthlyHoursGoal) * 1.1 {
									ParticlesView()
								}
							}
							.shadow(radius: 5, x: 2.0, y: 2.0)
							.opacity(month.isAnimated ? 1 : 0)
						}
						.chartYScale(domain: 0...(vm.workTime.max(by: { $0.hours < $1.hours })!.hours + 10))
						.chartYAxis(.hidden)
					}
					
					ChartContainer(title: String(localized: "Salary per month"), 150) {
						HStack {
							VStack {
								ForEach(vm.workTime) { month in
									Spacer()
									Text(month.month)
									Spacer()
								}
							}
							.font(.caption2)
							.foregroundStyle(.secondary)
							
							Chart(vm.workTime) { month in
								BarMark(
									x: .value("Salary", vm.salary(in: month)),
									y: .value("Hours", month.month))
								.foregroundStyle(vm.getColorFor(hours: month.hours))
								.annotation(position: .trailing) {
									Text("\(Int(vm.salary(in: month)))")
										.font(.footnote)
										.foregroundStyle(month.hours != 0 ? Color.primary : Color.clear)
								}
								.shadow(radius: 5, x: 2.0, y: 2.0)
							}
							.chartXAxis(.hidden)
							.chartYAxis {
								AxisMarks {
									AxisGridLine()
								}
							}
						}
					}
				}
				.padding(.horizontal)
				.refreshable {
					vm.refresh()
					trigger.toggle()
				}
				
				VStack {
					Spacer()
					
					Button("Add work", systemImage: "calendar.badge.plus") {
						showingAddWork.toggle()
					}
					.buttonStyle(.borderedProminent)
					.shadow(radius: 5, x: 2.0, y: 2.0)
				}
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Settings", systemImage: "person.circle") {
						showingSettings.toggle()
					}
				}
			}
		}
		.sheet(isPresented: $showingSettings, onDismiss: refreshAndAnimate, content: SettingsView.init)
		.sheet(isPresented: $showingAddWork, onDismiss: refreshAndAnimate) { AddWorkView(eventStore: vm.eventStore) }
		.environmentObject(vm.localState)
		.onChange(of: trigger, initial: false) { oldValue, newValue in
			reset()
		}
		.onAppear {
			vm.getUserCalendars()
			vm.refresh()
			animate()
		}
	}
	
	private func refreshAndAnimate() {
		vm.refresh()
		reset()
	}
	
	private func reset() {
		$vm.workTime.forEach { element in
			element.wrappedValue.isAnimated = false
		}
		
		isAnimated = false
		animate()
	}
	
	private func animate(with constDelay: Double = 0.5) {
		guard !isAnimated else { return }
		
		isAnimated = true
		
		$vm.workTime.enumerated().forEach { index, element in
			let delay = Double(index) * 0.4 + constDelay
			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
				withAnimation(.bouncy) {
					element.wrappedValue.isAnimated = true
				}
			}
		}
	}
}

#Preview {
	MainScreenView()
}
