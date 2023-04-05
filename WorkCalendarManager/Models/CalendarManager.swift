//
//  CalendarManager.swift
//  WorkCalendarManager
//
//  Created by Adam on 30/03/2023.
//

import Foundation
import EventKit

protocol CalendarManagerDelegate {
    func didFetchWork(hours: Int)
    func didFailWhileFetching(_ error: Error)
}

struct CalendarManager {
    private var eventStore: EKEventStore
    var delegate: CalendarManagerDelegate?
    
    private var currYear: Int {
        return Date().getCurrYear()
    }
    
    private var currMonth: Int {
        return Date().getCurrMonth()
    }
    
    private var currMonthStart: Date {
        return Date().getStartOfCurrMonth()
    }
    
    private var currMonthEnd: Date {
        return Date().getEndOfCurrMonth()
    }
    
    private var currMonthLastDay: Int {
        let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: currMonthEnd)
        return Calendar.current.component(.day, from: lastDay!)
    }
    
    private var userTimeZoneIdentifier: String {
        return TimeZone.current.identifier
    }
    
    private var userWorkCalendar: String? {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == K.workCalendarName {
                return calendar.calendarIdentifier
            }
        }
        
        // TODO: Create new calendar instead of using default calendar
        return eventStore.defaultCalendarForNewEvents?.calendarIdentifier
    }
    
    // TODO: handle errors
    init() {
        eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if error != nil {
                print(error as Any)
                return
            }
        }
    }
    
    func fetchWorkHours() {
        var amount: Int = 0
        
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title != K.workCalendarName { continue }
            
            let predicate = eventStore.predicateForEvents(withStart: currMonthStart, end: currMonthEnd, calendars: [calendar])
            let events = eventStore.events(matching: predicate)
            
            for event in events {
                let eventStartDate = event.startDate
                let eventEndDate = event.endDate
                let eventDuration = eventEndDate!.timeIntervalSinceReferenceDate - eventStartDate!.timeIntervalSinceReferenceDate
                amount += Int(eventDuration / 3600.0)
            }
            break
        }
        delegate?.didFetchWork(hours: amount)
    }
    
    func createEvent(day: Int, startHour: Int, endHour: Int) {
        let newEvent = EKEvent(eventStore: eventStore)
        
        newEvent.title = K.workCalendarName
        newEvent.notes = K.eventNote
        newEvent.startDate = createDateObject(day: day, hour: startHour)
        newEvent.endDate = createDateObject(day: day, hour: endHour)
        newEvent.calendar = eventStore.calendar(withIdentifier: userWorkCalendar!)
        
        do {
            try eventStore.save(newEvent, span: .thisEvent)
            print("Event saved in calendar")
        } catch let error {
            print(error)
        }
    }
    
    /// - Returns: dictionary with key = calendar title and value = calendar CGColor
    func fetchUserCalendars() -> [String: CGColor] {
        var calendarColorDict: [String: CGColor] = [:]
        
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            calendarColorDict[calendar.title] = calendar.cgColor
        }
        
        return calendarColorDict
    }
    
    func createDateObject(day: Int, hour: Int) -> Date? {
        let userCalendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.timeZone = TimeZone(identifier: userTimeZoneIdentifier)
        dateComponents.year = currYear
        dateComponents.month = currMonth
        dateComponents.day = day
        dateComponents.hour = hour
        
        return userCalendar.date(from: dateComponents)
    }
    
    func iterateOverDays() {
        for day in 1...currMonthLastDay {
            let tempDate = createDateObject(day: day, hour: 10)!
            let tempWeekday = Calendar.current.component(.weekday, from: tempDate)
            
            if tempWeekday == 1 || tempWeekday == 7 {
                continue  // ignore saturdays and sundays
            }
            
            iterateOverHours(day: day)
        }
    }
    
    // MARK: first sketch of function adding events to empty slots in calendar
    func iterateOverHours(day: Int) {
        let startHour = 7
        var endHour = 8
        let calendars = eventStore.calendars(for: .event)
        var eventsInHour: [EKEvent]
        
    hoursLoop: for hour in endHour...20 {
        eventsInHour = []
        
    calendarsLoop: for calendar in calendars {
        let predicate = eventStore.predicateForEvents(withStart: createDateObject(day: day, hour: startHour)!, end: createDateObject(day: day, hour: endHour)!, calendars: [calendar])
        
        eventsInHour += eventStore.events(matching: predicate)
    }
        if eventsInHour.isEmpty {
            endHour = hour
        } else {
            // TODO: instead of -= 2 get event start hour and calculate good value
            endHour -= 2
            break hoursLoop
        }
    }
        if endHour - startHour > 8 {
            endHour -= (endHour - startHour - 8)
        }
        
        createEvent(day: day, startHour: startHour, endHour: endHour)
    }
}
