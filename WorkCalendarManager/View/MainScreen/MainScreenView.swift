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
					if vm.monthSalary != 0 {
						MonthSalaryView(
							salary: vm.monthSalary,
							month: Date.now.monthLongName,
							currencyCode: vm.currencyCode)
					}
					
					VStack {
						Text("Hours per month")
							.font(.headline)
							.fontDesign(.rounded)
						
						Chart {
							ForEach(vm.workTime) { month in
								BarMark(
									x: .value("Month", month.month),
									y: .value("Hours", month.hours))
								.annotation {
									Text("\(month.hours, format: .number)")
										.font(.footnote)
								}
								.shadow(radius: 5, x: 2.0, y: 2.0)
							}
						}
						.chartYAxis(.hidden)
						.frame(height: 300)
					}
					.padding(8)
					.background(.ultraThinMaterial)
					.clipShape(.rect(cornerRadius: 20))
				}
				.padding(.horizontal)
				
				VStack {
					Spacer()
					
					Button("Add work", systemImage: "calendar.badge.plus") {
						// show sheet with configuration options
						print("Adding...")
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
		.sheet(isPresented: $showingSettings, onDismiss: vm.getWorkTimePerMonth, content: SettingsView.init)
		.sheet(isPresented: $showingAddWork, content: AddWorkView.init)
		.environmentObject(vm.localState)
		.onAppear {
			vm.getUserCalendars()
			vm.getWorkTimePerMonth()
		}
	}
}

#Preview {
	MainScreenView()
}
