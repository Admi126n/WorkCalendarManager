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
	
	@StateObject var vm = ViewModel()
	
	var body: some View {
		NavigationStack {
			ZStack {
				ScrollView {
					if vm.currentMonthSalary != 0 {
						MonthSalaryView(
							salary: vm.currentMonthSalary,
							month: Date.now.monthLongName,
							currencyCode: vm.currencyCode)
					}
					
					ChartContainer(title: "Hours per month", 300) {
						Chart(vm.workTime) { month in
							BarMark(
								x: .value("Month", month.month),
								y: .value("Hours", month.hours))
							.foregroundStyle(vm.getColorFor(hours: month.hours))
							.annotation {
								Text("\(month.hours, format: .number)")
									.font(.footnote)
									.foregroundStyle(month.hours != 0 ? Color.primary : Color.clear)
							}
							.shadow(radius: 5, x: 2.0, y: 2.0)
						}
						.chartYAxis(.hidden)
					}
					
					ChartContainer(title: "Salary per month", 150) {
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
		.sheet(isPresented: $showingSettings, onDismiss: vm.refresh, content: SettingsView.init)
		.sheet(isPresented: $showingAddWork) { AddWorkView(eventStore: vm.eventStore) }
		.environmentObject(vm.localState)
		.onAppear {
			vm.getUserCalendars()
			vm.refresh()
		}
	}
}

#Preview {
	MainScreenView()
}
