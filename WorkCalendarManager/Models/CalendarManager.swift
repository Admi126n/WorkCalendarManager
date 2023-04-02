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
    
    private var userTimeZoneIdentifier: String {
        return TimeZone.current.identifier
    }
    
    // TODO: handle scenario when work calendar doesn't exist, e.g. create new calendar or use defaultCalendarForNewEvents
    private var userWorkCalendar: String? {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == K.workCalendarName {
                return calendar.calendarIdentifier
            }
        }
        
        return nil
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
            if calendar.title == K.workCalendarName {
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
    
    // MARK: first sketch of function adding events to empty slots in calendar
    func test() {
        let day = 5
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

/*
 May be useful:
 - weekday property
 - predicateForEvents(withStart: Date, end: Date, calendars: [EKCalendar]?) -> NSPredicate function
 */
