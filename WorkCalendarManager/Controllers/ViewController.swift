//
//  ViewController.swift
//  WorkCalendarManager
//
//  Created by Adam on 28/03/2023.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func test(_ sender: UIButton) {
        print(Date().startOfMonth())
        print(Date().endOfMonth())
        
        // Create event store object
        let store = EKEventStore()
        
        // Request access to calendar
        store.requestAccess(to: .event) { granted, error in
            if error != nil {
                print(error!)
            }
        }
        
        let calendars = store.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == "Praca" {
                
                let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*3600)
                let oneMonthAfter = Date(timeIntervalSinceNow: 30*24*3600)
                let predicate =  store.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])
                
                let events = store.events(matching: predicate)
                
                for event in events {
                    print(event.title!)
                    let start = event.startDate
                    let end = event.endDate
                    let x = end!.timeIntervalSinceReferenceDate - start!.timeIntervalSinceReferenceDate
                    print(x) // difference in seconds
                }
            }
        }
    }
    
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
