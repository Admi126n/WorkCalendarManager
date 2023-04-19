//
//  CalendarManagerBrain.swift
//  WorkCalendarManager
//
//  Created by Adam on 05/04/2023.
//

import Foundation
import EventKit

struct CalendarManagerBrain {
    private let cM: CalendarManager = CalendarManager()
    private var availabilityDict: [Date: Bool] = [:]
    private var settingsDict: [String: Int] = [:]
    
    mutating func iterateOverDays() {
        for day in 1...cM.currMonthLastDay {
            let tempDate = cM.createDateObject(day: day)
            let tempWeekday = Calendar.current.component(.weekday, from: tempDate)
            
            if tempWeekday == 1 || tempWeekday == 7 {
                continue  // ignore saturdays and sundays
            }
            
            iterateOverAvailabilityDict(on: day)
        }
    }
    
    private mutating func iterateOverAvailabilityDict(on day: Int) {
        var slotIsEmpty = false
        var workStartDate: Date = Date()
        var workEndDate: Date = Date()
        
        fillAvailabilityDict(for: day)
        
        for (date, availability) in availabilityDict.sorted(by: { $0.0 < $1.0 }) {
            if availability {
                if !slotIsEmpty {
                    workStartDate = date
                }
                slotIsEmpty = true
                workEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
                
                if workEndDate >= cM.createDateObject(day: day, hour: (settingsDict[K.S.endHour] ?? K.businessDayEndHour)) {
                    calculateWorkEvent(workStartDate, workEndDate)
                    break
                }
                
                if Int(workStartDate.distance(to: workEndDate)) / 3600 == (settingsDict[K.S.maxDuration] ?? K.workMaxDuration) {
                    cM.createEvent(startHour: workStartDate, endHour: workEndDate)
                    break
                }
            } else {
                if slotIsEmpty {
                    calculateWorkEvent(workStartDate, workEndDate)
                }
                slotIsEmpty = false
            }
        }
    }
    
    /// Checks all events in given day in 15 minutes intervals
    /// - Parameter d: number of day in month
    mutating func fillAvailabilityDict(for day: Int) {
        availabilityDict = [:]
        
        var searchingStartDate = cM.createDateObject(day: day, hour: (settingsDict[K.S.startHour] ?? K.businessDayStartHour))
        var searchingEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingStartDate)!
        let businessDayEndDate = cM.createDateObject(day: day, hour: (settingsDict[K.S.endHour] ?? K.businessDayEndHour) + 1)
        let userCalendars = cM.getUserCalendars()
        var eventsList: [EKEvent] = []
        
        repeat {
            for calendar in userCalendars {
                // TODO: after adding UI, change title to calendarIdentifier
                guard !K.ignoredCalendars.contains(calendar.title) else { continue }
                
                let predicate = cM.createPredicate(withStart: searchingStartDate, end: searchingEndDate, for: [calendar])
                eventsList += cM.getEventsList(matching: predicate)
            }
            
            if eventsList.isEmpty {
                if availabilityDict[searchingStartDate] == nil {
                    availabilityDict[searchingStartDate] = true
                }
            } else {
                availabilityDict[searchingStartDate] = false
                
                blockAvailability(for: -(settingsDict[K.S.marginBefore] ?? K.marginBeforeWork), from: searchingStartDate)
                blockAvailability(for: (settingsDict[K.S.marginAfter] ?? K.marginAfterWork), from: searchingStartDate)
            }
            
            searchingStartDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingStartDate)!
            searchingEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingEndDate)!
            
            eventsList = []
        } while searchingEndDate <= businessDayEndDate
    }
    
    // TODO: make sure if margins work properly (I mean if they equal given values)
    private mutating func blockAvailability(for quaters: Int, from date: Date) {
        if quaters == 0 {
            return
        }
        
        for i in 1...abs(quaters) {
            let dist = 15 * i * quaters.signum()
            availabilityDict[Calendar.current.date(byAdding: .minute, value: dist, to: date)!] = false
        }
    }
    
    private func cutEventToFullHour(startDate: Date, endDate: Date) -> Date {
        let secondsToCut = Int(startDate.distance(to: endDate)) % 3600
        let newEndDate = Calendar.current.date(byAdding: .second, value: -secondsToCut, to: endDate)!
        
        return newEndDate
    }
    
    private func cutEventToMaxDuration(startDate: Date, endDate: Date) -> Date {
        let hoursToCut = Int(startDate.distance(to: endDate) / 3600) % (settingsDict[K.S.maxDuration] ?? K.workMaxDuration)
        let newEndDate = Calendar.current.date(byAdding: .hour, value: -hoursToCut, to: endDate)!
        
        return newEndDate
    }
    
    private func calculateWorkEvent(_ workStartDate: Date, _ workEndDate: Date) {
        var eventEndDate = workEndDate
        let workDuration = Int(workStartDate.distance(to: eventEndDate))
        
        if workDuration / 3600 >= (settingsDict[K.S.minDuration] ?? K.workMinDuration) {
            if workDuration % 3600 == 0 {
                if workDuration / 3600 <= (settingsDict[K.S.maxDuration] ?? K.workMaxDuration) {
                    cM.createEvent(startHour: workStartDate, endHour: eventEndDate)
                } else {
                    eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
                    cM.createEvent(startHour: workStartDate, endHour: eventEndDate)
                }
            } else {
                eventEndDate = cutEventToFullHour(startDate: workStartDate, endDate: eventEndDate)
                if workDuration / 3600 <= (settingsDict[K.S.maxDuration] ?? K.workMaxDuration) {
                    cM.createEvent(startHour: workStartDate, endHour: eventEndDate)
                } else {
                    eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
                    cM.createEvent(startHour: workStartDate, endHour: eventEndDate)
                }
            }
        }
    }
    
    mutating func setSettingsDict(_ settingsDict: [String: Int]) {
        self.settingsDict = settingsDict
    }
}
