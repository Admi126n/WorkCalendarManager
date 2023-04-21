//
//  CalendarManager.swift
//  WorkCalendarManager
//
//  Created by Adam on 30/03/2023.
//

import Foundation
import EventKit
import UIKit

protocol CalendarManagerDelegate {
    func didFetchWorkHours(hours: Int)
    func didFail(_ error: Error, _ message: String?)
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
    
    var currMonthLastDay: Int {
        let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: currMonthEnd)
        return Calendar.current.component(.day, from: lastDay!)
    }
    
    private var userTimeZoneIdentifier: String {
        return TimeZone.current.identifier
    }
    
    private var userWorkCalendar: String? {
        let calendars = getUserCalendars()
        for calendar in calendars {
            if calendar.title == K.workCalendarName {
                return calendar.calendarIdentifier
            }
        }
        
        return createWorkCalendar(withName: K.workCalendarName)
    }
    
    init() {
        eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if error != nil {
                print(error as Any)
                return
            }
        }
    }
    
    private mutating func refreshEventStore() {
        eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if error != nil {
                print(error as Any)
                return
            }
        }
    }
    
    private func createWorkCalendar(withName name: String) -> String {
        guard let source = eventStore.defaultCalendarForNewEvents?.source else {
            return eventStore.defaultCalendarForNewEvents!.calendarIdentifier
        }
        
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = name
        newCalendar.source = source
        newCalendar.cgColor = UIColor.blue.cgColor
        
        try! eventStore.saveCalendar(newCalendar, commit: true)
        
        return newCalendar.calendarIdentifier
    }
    
    mutating func fetchWorkHours() {
        refreshEventStore()
        var workHours: Int = 0
        
        let calendars = getUserCalendars()
        for calendar in calendars {
            guard calendar.title == K.workCalendarName else { continue }
            
            let predicate = createPredicate(withStart: currMonthStart, end: currMonthEnd, for: [calendar])
            let events = getEventsList(matching: predicate)
            
            for event in events {
                let eventDuration = event.startDate.distance(to: event.endDate)
                workHours += Int(eventDuration / 3600.0)
            }
            break
        }
        delegate?.didFetchWorkHours(hours: workHours)
    }
    
    func createEvent(startHour: Date, endHour: Date) {
        let newEvent = EKEvent(eventStore: eventStore)
        
        newEvent.title = K.workCalendarName
        newEvent.notes = K.eventNote
        newEvent.startDate = startHour
        newEvent.endDate = endHour
        newEvent.calendar = eventStore.calendar(withIdentifier: userWorkCalendar!)
        
        do {
            try eventStore.save(newEvent, span: .thisEvent)
        } catch let error {
            delegate?.didFail(error, "Failed while adding event")
        }
    }
    
    /// - Returns: dictionary with key = calendar identifier and value = [calendar title, calendar CGColor]
    func getUserCalendarsColors() -> [[String: [Any]]] {
        let calendars = eventStore.calendars(for: .event)
        var calendarsData: [[String: [Any]]] = [[:]]
        calendarsData.remove(at: 0)
        
        for calendar in calendars {
            guard !K.systemCalendars.contains(calendar.title) && calendar.title != K.workCalendarName else { continue }
            
            calendarsData.append([calendar.calendarIdentifier: [calendar.title, calendar.cgColor!]])
        }
        
        return calendarsData
    }
    
    func createDateObject(day: Int, hour: Int? = nil) -> Date {
        let userCalendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.timeZone = TimeZone(identifier: userTimeZoneIdentifier)
        dateComponents.year = currYear
        dateComponents.month = currMonth
        dateComponents.day = day
        dateComponents.hour = hour
        
        return userCalendar.date(from: dateComponents)!
    }
    
    func getUserCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    func getEventsList(matching predicate: NSPredicate) -> [EKEvent] {
        return eventStore.events(matching: predicate)
    }
    
    func createPredicate(withStart startDate: Date, end endDate: Date, for calendars: [EKCalendar]) -> NSPredicate {
        return eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
    }
}
