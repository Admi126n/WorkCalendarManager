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
    
    var currMonthStart: Date {
        return Date().getStartOfCurrMonth()
    }
    
    var currMonthEnd: Date {
        return Date().getEndOfCurrMonth()
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
    
    func createEvent() {
        /*
         May be useful:
         - weekday property
         - predicateForEvents(withStart: Date, end: Date, calendars: [EKCalendar]?) -> NSPredicate function
         */
        
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { granted, error in
            if error != nil {
                self.delegate?.didFailWhileFetching(error!)
                return
            }
        }
        
        let event = EKEvent(eventStore: store)
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2023
        dateComponents.month = 3
        dateComponents.day = 10
        dateComponents.timeZone = TimeZone(identifier: "Europe/Warsaw")
        dateComponents.hour = 8
        dateComponents.minute = 0

        // Create date from components
        let userCalendar = Calendar.current // user calendar
        event.startDate = userCalendar.date(from: dateComponents)
        
        dateComponents.hour = 9
        
        event.title = "Test Title"
        
        event.endDate = userCalendar.date(from: dateComponents)
        
        let calendars = store.calendars(for: .event)
        for calendar in calendars {
            print(calendar.calendarIdentifier)
        }
        
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent)
            print("Saved Event")
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
    }
    
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
