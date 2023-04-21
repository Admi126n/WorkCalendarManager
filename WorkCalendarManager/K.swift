//
//  K.swift
//  WorkCalendarManager
//
//  Created by Adam on 30/03/2023.
//

import Foundation

struct K {
    static let workCalendarName: String = "Work Calendar"
    static let eventTitle: String = "Work"
    static let eventNote: String = "Created by WorkCalendarManager"
    static let settingsScreenSegue: String = "settingsScreenSegue"
    
    static let calendarCellIdentifier: String = "ReusableCalendarCell"
    static let calendarCellName: String = "CalendarCell"
    
    static let systemCalendars: [String] = ["Birthdays", "Siri Suggestions"]
    
    static let workMinDuration: Int = 3
    static let workMaxDuration: Int = 8
    
    static let businessDayStartHour: Int = 7
    static let businessDayEndHour: Int = 18
    
    // margins are equal to number of quaters
    static let marginBeforeWork: Int = 4
    static let marginAfterWork: Int = 4
    
    /// Struct with keys to user defaults
    struct D {
        static let appAppearance: String = "appAppearance"
        static let settingsDict: String = "settingsDict"
        static let ignoredCalendars: String = "ignoredCalendars"
    }
    
    /// Struct with keys to settings dictionary
    struct S {
        static let minDuration: String = "minDuration"
        static let maxDuration: String = "maxDuration"
        static let startHour: String = "startHour"
        static let endHour: String = "endHour"
        static let marginBefore: String = "marginBefore"
        static let marginAfter: String = "marginAfter"
    }
}