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
    var delegate: CalendarManagerDelegate?
    
    var currYear: Int {
        return Date().getCurrYear()
    }
    
    var currMonth: Int {
        return Date().getCurrMonth()
    }
    
    var currMonthStart: Date {
        return Date().getStartOfCurrMonth()
    }
    
    var currMonthEnd: Date {
        return Date().getEndOfCurrMonth()
    }
    
    var userTimeZoneIdentifier: String {
        return TimeZone.current.identifier
    }
    
    var userWorkCalendar: String? {
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { granted, error in
            if error != nil {
                self.delegate?.didFailWhileFetching(error!)
                return
            }
        }
        
        let calendars = store.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == K.workCalendarName {
                return calendar.calendarIdentifier
            }
        }
        
        return nil
    }
    
    func fetchWorkHours() {
        var amount: Int = 0
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { granted, error in
            if error != nil {
                self.delegate?.didFailWhileFetching(error!)
                return
            }
        }
        
        let calendars = store.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == K.workCalendarName {
                let predicate = store.predicateForEvents(withStart: currMonthStart, end: currMonthEnd, calendars: [calendar])
                
                let events = store.events(matching: predicate)
                
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
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { granted, error in
            if error != nil {
                self.delegate?.didFailWhileFetching(error!)
                return
            }
        }
        
        let newEvent = EKEvent(eventStore: store)
        let userCalendar = Calendar.current
        var dateComponents = DateComponents()
        
        newEvent.title = K.workCalendarName
        newEvent.notes = K.eventNote
        
        dateComponents.timeZone = TimeZone(identifier: userTimeZoneIdentifier)
        dateComponents.year = currYear
        dateComponents.month = currMonth
        dateComponents.day = day
        dateComponents.hour = startHour
        newEvent.startDate = userCalendar.date(from: dateComponents)
        
        dateComponents.hour = endHour
        newEvent.endDate = userCalendar.date(from: dateComponents)
        newEvent.calendar = store.calendar(withIdentifier: userWorkCalendar!)
        
        do {
            try store.save(newEvent, span: .thisEvent)
            print("Event saved in calendar")
        } catch let error {
            print(error)
        }
    }
    
    /// - Returns: dictionary with key = calendar title and value = calendar CGColor
    func fetchUserCalendars() -> [String: CGColor] {
        var calendarColorDict: [String: CGColor] = [:]
        
        let store = EKEventStore()
        store.requestAccess(to: .event) { granted, error in
            if error != nil {
                self.delegate?.didFailWhileFetching(error!)
                return
            }
        }
        
        let calendars = store.calendars(for: .event)
        for calendar in calendars {
            calendarColorDict[calendar.title] = calendar.cgColor
        }
        
        return calendarColorDict
    }
}

/*
 May be useful:
 - weekday property
 - predicateForEvents(withStart: Date, end: Date, calendars: [EKCalendar]?) -> NSPredicate function
 */
