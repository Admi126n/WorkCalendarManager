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
}

/*
 May be useful:
 - weekday property
 - predicateForEvents(withStart: Date, end: Date, calendars: [EKCalendar]?) -> NSPredicate function
 */
