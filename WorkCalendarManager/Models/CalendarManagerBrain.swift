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
        /*
         1. zebranie eventow z calego dnia od 7:00 do 19:00/20:00
         2. utworzenie slownika/listy? wolnych slotow w przedzialach 15 min
         */
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
    /// - Returns: list of Bools, where each element describes avialability in 15 minutes slot
    func getEmptySlots(day d: Int) -> [Bool] {
        // TODO: add wanted margin to avialabilityList (e.g. 1 hour); maybe change list to dict [startHour: value]
        var startDate = cM.createDateObject(day: d, hour: 7)
        var endDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)!
        let maxEndDate = cM.createDateObject(day: d, hour: 20)
        var avialabilityList: [Bool] = []
        let calendars = cM.eventStore.calendars(for: .event)
        var eventsList: [EKEvent] = []
        
        repeat {
            for calendar in calendars {
                if K.ignoredCalendars.contains(calendar.title) { continue }
                
                let predicate = cM.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                
                eventsList += cM.eventStore.events(matching: predicate)
            }
            
            if eventsList.isEmpty {
                avialabilityList.append(true)
            } else {
                avialabilityList.append(false)
            }
            
            startDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)!
            endDate = Calendar.current.date(byAdding: .minute, value: 15, to: endDate)!
            
            eventsList = []
            
        } while endDate <= maxEndDate
        
        return avialabilityList
    }
    
}
