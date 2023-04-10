//
//  K.swift
//  WorkCalendarManager
//
//  Created by Adam on 30/03/2023.
//

import Foundation

struct K {
    static let workCalendarName: String = "Praca"
    static let eventTitle: String = "Work"
    static let eventNote: String = "Created by WorkCalendarManager"
    static let appAppearanceDefaults: String = "appAppearance"
    
    static let ignoredCalendars: [String] = []
    
    static let workMinDuration: Int = 3
    static let workMaxDuration: Int = 8
    
    static let businessDayStartHour: Int = 7
    static let businessDayEndHour: Int = 18
}
