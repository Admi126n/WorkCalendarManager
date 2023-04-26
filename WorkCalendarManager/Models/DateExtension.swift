//
//  DateExtension.swift
//  WorkCalendarManager
//
//  Created by Adam on 30/03/2023.
//

import Foundation

extension Date {
    func getStartDateOfCurrMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func getEndDateOfCurrMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1), to: self.getStartDateOfCurrMonth())!
    }
    
    func getStartDateOfMonth(x monthsFromCurr: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: monthsFromCurr, to: Date().getStartDateOfCurrMonth())!
    }
    
    func getEndDateOfMonth(x monthsFromCurr: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1), to: self.getStartDateOfMonth(x: monthsFromCurr))!
    }
    
    func getYear(of selectedMonth: Date) -> Int {
        let month = Calendar.current.component(.month, from: selectedMonth)
        
        return Calendar.current.component(.year, from: Date().getStartDateOfMonth(x: month))
    }
    
    func getCurrMonth() -> Int {
        return Calendar.current.component(.month, from: Date())
    }
}
