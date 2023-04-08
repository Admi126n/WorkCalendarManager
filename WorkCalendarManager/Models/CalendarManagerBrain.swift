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
    
    mutating func iterateOverAvailabilityDict(on day: Int) {
        // TODO: work duration has to be full hours
        // TODO: work duration has to be smaller or equal to K.workMaxDuration
        var slotIsEmpty = false
        var startDate: Date = Date()
        var endDate: Date = Date()
        
        fillAvailabilityDict(for: day)
        
        for (key, value) in availabilityDict.sorted(by: { $0.0 < $1.0 }) {
            if value {
                if !slotIsEmpty {
                    startDate = key
                }
                slotIsEmpty = true
                endDate = Calendar.current.date(byAdding: .minute, value: 15, to: key)!
            } else {
                if slotIsEmpty {
                    let duration = startDate.distance(to: endDate) / 3600
                    
                    if duration >= Double(K.workMinDuration) {
                        cM.createEvent(startHour: startDate, endHour: endDate)
                    }
                    
                    print(startDate, endDate)
                }
                slotIsEmpty = false
            }
        }
    }
    
    /// Checks all events in given day in 15 minutes intervals
    /// - Parameter d: number of day in month
    mutating func fillAvailabilityDict(for day: Int) {
        availabilityDict = [:]
        
        // FIXME: make some refactoring because it looks terrible
        var startDate = cM.createDateObject(day: day, hour: 7)
        var endDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)!
        let maxEndDate = cM.createDateObject(day: day, hour: 20)
        let calendars = cM.eventStore.calendars(for: .event)
        var eventsList: [EKEvent] = []
        
        repeat {
            for calendar in calendars {
                // TODO: after adding UI, change title to calendarIdentifier
                if K.ignoredCalendars.contains(calendar.title) { continue }
                
                let predicate = cM.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                eventsList += cM.eventStore.events(matching: predicate)
            }
            
            if eventsList.isEmpty {
                if availabilityDict[startDate] == nil {
                    availabilityDict[startDate] = true
                }
            } else {
                availabilityDict[startDate] = false
                
                blockAvailability(for: -4, from: startDate)  // block time 1 hour before calendar event
                blockAvailability(for: 4, from: startDate)  // block time 1 hour after calendar event
            }
            
            startDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)!
            endDate = Calendar.current.date(byAdding: .minute, value: 15, to: endDate)!
            
            eventsList = []
        } while endDate <= maxEndDate
    }
    
    private mutating func blockAvailability(for quaters: Int, from date: Date) {
        for i in 1...abs(quaters) {
            let dist = 15 * i * quaters.signum()
            availabilityDict[Calendar.current.date(byAdding: .minute, value: dist, to: date)!] = false
        }
    }
    
}
