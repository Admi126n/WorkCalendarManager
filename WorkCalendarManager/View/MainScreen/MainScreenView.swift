//
//  MainScreenView.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 21/03/2024.
//

import SwiftUI

struct MainScreenView: View {
	@State private var showingSettings = false
	@State private var showingAddWork = false
	
	@StateObject var vm = ViewModel()
	
	var body: some View {
		NavigationStack {
			ZStack {
				ScrollView {
					Text(vm.accessGranted ? "True" : "False")
						.foregroundStyle(vm.accessGranted ? .green : .red)
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
	}
}

#Preview {
    MainScreenView()
}
