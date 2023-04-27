//
//  CalendarManagerBrain.swift
//  WorkCalendarManager
//
//  Created by Adam on 05/04/2023.
//

import Foundation
import EventKit

struct CalendarManagerBrain {
    private var availabilityDict: [Date: Bool] = [:]
    private var settingsDict: [String: Int] = [:]
    private var ignoredCalendars: [String] = []
    
    init() {
        setIgnoredCalendars()
    }
    
    mutating func iterateOverDays() {
        for day in 1...CalendarManager.cm.selectedMonthLastDay {
            let tempDate = CalendarManager.cm.createDateObject(day: day)
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
                
                if workEndDate >= CalendarManager.cm.createDateObject(day: day, hour: (settingsDict[K.S.endHour] ?? K.DS[K.S.endHour]!)) {
                    calculateWorkEvent(workStartDate, workEndDate)
                    break
                }
                
                if #available(iOS 13.0, *) {
                    if Int(workStartDate.distance(to: workEndDate)) / 3600 == (settingsDict[K.S.maxDuration] ?? K.DS[K.S.maxDuration]!) {
                        CalendarManager.cm.createEvent(startHour: workStartDate, endHour: workEndDate)
                        break
                    }
                } else {
                    // Fallback on earlier versions
                    if Int(workEndDate.timeIntervalSince(workStartDate)) / 3600 == (settingsDict[K.S.maxDuration] ?? K.DS[K.S.maxDuration]!) {
                        CalendarManager.cm.createEvent(startHour: workStartDate, endHour: workEndDate)
                        break
                    }
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
        
        var searchingStartDate = CalendarManager.cm.createDateObject(day: day, hour: (settingsDict[K.S.startHour] ?? K.DS[K.S.startHour]!))
        var searchingEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: searchingStartDate)!
        let businessDayEndDate = CalendarManager.cm.createDateObject(day: day, hour: (settingsDict[K.S.endHour] ?? K.DS[K.S.endHour]!) + 1)
        let userCalendars = CalendarManager.cm.getUserCalendars()
        var eventsList: [EKEvent] = []
        
        repeat {
            for calendar in userCalendars {
                guard !(ignoredCalendars.contains(calendar.calendarIdentifier)
                        || calendar.isImmutable) else { continue }
                
                let predicate = CalendarManager.cm.createPredicate(withStart: searchingStartDate, end: searchingEndDate, for: [calendar])
                eventsList += CalendarManager.cm.getEventsList(matching: predicate)
            }
            
            if eventsList.isEmpty {
                if availabilityDict[searchingStartDate] == nil {
                    availabilityDict[searchingStartDate] = true
                }
            } else {
                availabilityDict[searchingStartDate] = false
                
                blockAvailability(for: -(settingsDict[K.S.marginBefore] ?? K.DS[K.S.marginBefore]!), from: searchingStartDate)
                blockAvailability(for: (settingsDict[K.S.marginAfter] ?? K.DS[K.S.marginAfter]!), from: searchingStartDate)
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
        var secondsToCut = 0
        if #available(iOS 13.0, *) {
            secondsToCut = Int(startDate.distance(to: endDate)) % 3600
        } else {
            // Fallback on earlier versions
            secondsToCut = Int(endDate.timeIntervalSince(startDate)) % 3600
        }
        let newEndDate = Calendar.current.date(byAdding: .second, value: -secondsToCut, to: endDate)!
        
        return newEndDate
    }
    
    private func cutEventToMaxDuration(startDate: Date, endDate: Date) -> Date {
        var hoursToCut = 0
        if #available(iOS 13.0, *) {
            hoursToCut = Int(startDate.distance(to: endDate) / 3600) % (settingsDict[K.S.maxDuration] ?? K.DS[K.S.maxDuration]!)
        } else {
            // Fallback on earlier versions
            hoursToCut = Int(endDate.timeIntervalSince(startDate) / 3600) % (settingsDict[K.S.maxDuration] ?? K.DS[K.S.maxDuration]!)
        }
        let newEndDate = Calendar.current.date(byAdding: .hour, value: -hoursToCut, to: endDate)!
        
        return newEndDate
    }
    
    private func calculateWorkEvent(_ workStartDate: Date, _ workEndDate: Date) {
        var workDuration = 0
        var eventEndDate = workEndDate
        if #available(iOS 13.0, *) {
            workDuration = Int(workStartDate.distance(to: eventEndDate))
        } else {
            // Fallback on earlier versions
            workDuration = Int(eventEndDate.timeIntervalSince(workStartDate))
        }
        
        if workDuration / 3600 >= (settingsDict[K.S.minDuration] ?? K.DS[K.S.minDuration]!) {
            if workDuration % 3600 == 0 {
                if workDuration / 3600 <= (settingsDict[K.S.maxDuration] ?? K.DS[K.S.maxDuration]!) {
                    CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate)
                } else {
                    eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
                    CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate)
                }
            } else {
                eventEndDate = cutEventToFullHour(startDate: workStartDate, endDate: eventEndDate)
                if workDuration / 3600 <= (settingsDict[K.S.maxDuration] ?? K.DS[K.S.maxDuration]!) {
                    CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate)
                } else {
                    eventEndDate = cutEventToMaxDuration(startDate: workStartDate, endDate: eventEndDate)
                    CalendarManager.cm.createEvent(startHour: workStartDate, endHour: eventEndDate)
                }
            }
        }
    }
    
    mutating func setSettingsDict(_ settingsDict: [String: Int]) {
        self.settingsDict = settingsDict
    }
    
    mutating func setIgnoredCalendars() {
        let defaults = UserDefaults.standard
        
        if let safeList = defaults.array(forKey: K.D.ignoredCalendars) {
            self.ignoredCalendars = safeList as! [String]
        }
    }
}
