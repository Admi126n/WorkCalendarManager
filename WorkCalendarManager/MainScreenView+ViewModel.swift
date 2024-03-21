//
//  MainScreenView+ViewModel.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 21/03/2024.
//

import EventKit
import SwiftUI

extension MainScreenView {
	
	class ViewModel: ObservableObject {
		
		@Published private(set) var accessGranted: Bool = false
		
		init() {
			let acces = EKEventStore.authorizationStatus(for: .event)
			
			if acces == .fullAccess {
				self.accessGranted = true
			} else {
				self.requestCalendarAccess()
			}
		}
		
		private func requestCalendarAccess() {
			let eventStore = EKEventStore()
			
			eventStore.requestFullAccessToEvents { granted, error in
				Task { @MainActor in
					self.accessGranted = granted
				}
			}
		}
	}
}