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
            }
        }
        delegate?.didFetchWork(hours: amount)
    }
}
