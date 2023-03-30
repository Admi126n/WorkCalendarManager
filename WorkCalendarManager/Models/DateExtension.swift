//
//  DateExtension.swift
//  WorkCalendarManager
//
//  Created by Adam on 30/03/2023.
//

import Foundation

extension Date {
    func getStartOfCurrMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func getEndOfCurrMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1), to: self.getStartOfCurrMonth())!
    }
}
