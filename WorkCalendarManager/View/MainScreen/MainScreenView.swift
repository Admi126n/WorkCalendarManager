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
					HStack {
						Text("Work hours per month")
							.font(.headline)
							.padding(.leading, 8)
						
						Spacer()
					}
					
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
						// show settings screen
						print("Settings...")
						showingSettings.toggle()
					}
				}
			}
		}
		.sheet(isPresented: $showingSettings, content: SettingsView.init)
		.sheet(isPresented: $showingAddWork, content: AddWorkView.init)
		.onAppear {
			vm.getWorkTimePerMonth()
		}
	}
}

#Preview {
    MainScreenView()
}
