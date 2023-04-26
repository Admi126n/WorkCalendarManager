//
//  K.swift
//  WorkCalendarManager
//
//  Created by Adam on 30/03/2023.
//

import Foundation

/// Struct with string variables and needed default settings
struct K {
    // Event note and title and work calendar name
    static let workCalendarName: String = "Work Calendar"
    static let eventTitle: String = "Work"
    static let eventNote: String = "Created by WorkCalendarManager"
    
    /// Identifier of segue to settings screen
    static let settingsScreenSegue: String = "settingsScreenSegue"
    
    // Calendar cell identifier and name
    static let calendarCellIdentifier: String = "ReusableCalendarCell"
    static let calendarCellName: String = "CalendarCell"
    
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
    
    /// Dictionary with default settings
    static let DS: [String: Int] = [S.minDuration: 3,
                                    S.maxDuration: 8,
                                    S.startHour: 7,
                                    S.endHour: 18,
                                    S.marginBefore: 4,
                                    S.marginAfter: 4]
}
