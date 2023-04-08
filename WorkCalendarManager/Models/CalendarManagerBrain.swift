//
//  CalendarManagerBrain.swift
//  WorkCalendarManager
//
//  Created by Adam on 05/04/2023.
//

import Foundation
import EventKit

struct CalendarManagerBrain {
    /*
     scenariusze:
     - wolne od 7:00 do godziny x
     - wolne od godzuny x do 18:00
     - wolne od godziny x do godziny y
     - brak wolnego czasu
     */
    private let cM: CalendarManager = CalendarManager()
    
    func iterateOverDays() {
        for day in 1...cM.currMonthLastDay {
            let tempDate = cM.createDateObject(day: day, hour: 10)
            let tempWeekday = Calendar.current.component(.weekday, from: tempDate)
            
            if tempWeekday == 1 || tempWeekday == 7 {
                continue  // ignore saturdays and sundays
            }
            
            iterateOverHours(day: day)
        }
    }
    
    // MARK: first sketch of function adding events to empty slots in calendar
    func iterateOverHours(day: Int) {
        // TODO: refactoring using new method getAvailabilityDict
        let startHour: Date = cM.createDateObject(day: day, hour: 7)
        var endHour: Date = cM.createDateObject(day: day, hour: 10)
        let calendars = cM.eventStore.calendars(for: .event)
        var eventsInHour: [EKEvent]
        
    hoursLoop: for hour in 10...20 {
        eventsInHour = []
        
    calendarsLoop: for calendar in calendars {
        let predicate = cM.eventStore.predicateForEvents(withStart: startHour, end: endHour, calendars: [calendar])
        
        eventsInHour += cM.eventStore.events(matching: predicate)
    }
        if eventsInHour.isEmpty {
            endHour = cM.createDateObject(day: day, hour: hour)
        } else {
            // TODO: instead of -= 2 get event start hour and calculate good value
            endHour -= 2
            break hoursLoop
        }
    }
        let duration = startHour.distance(to: endHour) / 3600
        print(duration)
        
        //        if endHour.distance(to: startHour) > 8 {
        //            endHour -= (endHour - startHour - 8)
        //        }
        
        //        cM.createEvent(day: day, startHour: startHour, endHour: endHour)
    }
    
    /// Checks all events in given day in 15 minutes intervals
    /// - Parameter d: number of day in month
    /// - Returns: dictionary [startDate: value], where value means if given slot is empty
    func getAvailabilityDict(day d: Int) -> [Date: Bool] {
        // FIXME: make some refactoring because it looks terrible
        var startDate = cM.createDateObject(day: d, hour: 7)
        var endDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)!
        let maxEndDate = cM.createDateObject(day: d, hour: 20)
        var availabilityDict: [Date: Bool] = [:]
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
                if let _ = availabilityDict[startDate] {
                    // do nothing
                } else {
                    availabilityDict[startDate] = true
                }
            } else {
                availabilityDict[startDate] = false
                
                // block time 1 hour before calendar event
                availabilityDict[Calendar.current.date(byAdding: .minute, value: -15, to: startDate)!] = false
                availabilityDict[Calendar.current.date(byAdding: .minute, value: -30, to: startDate)!] = false
                availabilityDict[Calendar.current.date(byAdding: .minute, value: -45, to: startDate)!] = false
                availabilityDict[Calendar.current.date(byAdding: .minute, value: -60, to: startDate)!] = false
                
                // block time 1 hour after calendar event
                availabilityDict[Calendar.current.date(byAdding: .minute, value: 15, to: startDate)!] = false
                availabilityDict[Calendar.current.date(byAdding: .minute, value: 30, to: startDate)!] = false
                availabilityDict[Calendar.current.date(byAdding: .minute, value: 45, to: startDate)!] = false
                availabilityDict[Calendar.current.date(byAdding: .minute, value: 60, to: startDate)!] = false
                
            }
            
            startDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)!
            endDate = Calendar.current.date(byAdding: .minute, value: 15, to: endDate)!
            
            eventsList = []
            
        } while endDate <= maxEndDate
        
        return availabilityDict
    }
    
}
