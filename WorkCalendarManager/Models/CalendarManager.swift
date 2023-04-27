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
    func didFetchWorkHours(_ hours: Int)
    func didGetMonthsNames(_ monthsNames: [String])
    func didFail(_ error: Error, _ message: String?)
}

struct CalendarManager {
    static var cm = CalendarManager()
    
    private var eventStore: EKEventStore
    private var monthsFromCurr: Int = 0
    var delegate: CalendarManagerDelegate?
    
    private var currYear: Int {
        return Date().getYear(of: Date().getStartDateOfMonth(x: monthsFromCurr))
    }
    
    var currMonth: Int {
        return Date().getCurrMonth()
    }
    
    var selectedMonthLastDay: Int {
        let lastDay = Calendar.current.date(byAdding: .day,
                                            value: -1,
                                            to: Date().getEndDateOfMonth(x: monthsFromCurr))
        
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
    
    private init() {
        eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if error != nil {
                print(error as Any)
                return
            }
        }
        
        getMonthsNames()
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
        let defaults = UserDefaults.standard
        
        var ignoredCalendars: [String] = []
        if let safeList = defaults.array(forKey: K.D.ignoredCalendars) {
            ignoredCalendars = safeList as! [String]
        }
        
        let calendars = getUserCalendars()
        
        for calendar in calendars {
            guard !(ignoredCalendars.contains(calendar.calendarIdentifier)
                    || calendar.isImmutable) else { continue }
            
            let predicate = createPredicate(withStart: Date().getStartDateOfMonth(x: monthsFromCurr),
                                            end: Date().getEndDateOfMonth(x: monthsFromCurr),
                                            for: [calendar])
            
            let events = getEventsList(matching: predicate)
            
            for event in events {
                guard event.title.contains(K.eventTitle) else { continue }
                
                var eventDuration: TimeInterval
                
                if #available(iOS 13.0, *) {
                    eventDuration = event.startDate.distance(to: event.endDate)
                } else {
                    eventDuration = event.endDate.timeIntervalSince(event.startDate)
                }
                workHours += Int(eventDuration / 3600.0)
            }
        }
        delegate?.didFetchWorkHours(workHours)
    }
    
    func createEvent(startHour: Date, endHour: Date) {
        let newEvent = EKEvent(eventStore: eventStore)
        
        newEvent.title = K.eventTitle
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
            guard !calendar.isImmutable && calendar.title != K.workCalendarName else { continue }
            
            calendarsData.append([calendar.calendarIdentifier: [calendar.title, calendar.cgColor!]])
        }
        
        return calendarsData
    }
    
    func createDateObject(day: Int, hour: Int? = nil) -> Date {
        let userCalendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.timeZone = TimeZone(identifier: userTimeZoneIdentifier)
        dateComponents.year = currYear
        dateComponents.month = Date().getCurrMonth() + monthsFromCurr
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
    
    func getMonthsNames() {
        var monthsShortNames: [String] = []
        
        for i in -1...1 {
            monthsShortNames.append("\(DateFormatter().shortMonthSymbols[(currMonth + i) % 11])")
        }
        
        delegate?.didGetMonthsNames(monthsShortNames)
    }
    
    mutating func setMonthsFromCurr(_ x: Int) {
        monthsFromCurr = x
    }
}
