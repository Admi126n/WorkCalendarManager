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
    
    func getStartOfMonth(from currentMonth: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: currentMonth, to: Date().getStartOfCurrMonth())!
    }
    
    func getEndOfMonth(from currentMonth: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: currentMonth + 1), to: Calendar.current.date(byAdding: .month, value: currentMonth, to: self.getStartOfMonth(from: currentMonth))!)!
    }
    
    func getCurrYear() -> Int {
        return Calendar.current.component(.year, from: Date())
    }
    
    func getCurrMonth() -> Int {
        return Calendar.current.component(.month, from: Date())
    }
}
