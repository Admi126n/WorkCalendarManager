//
//  ViewController.swift
//  WorkCalendarManager
//
//  Created by Adam on 28/03/2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var workHoursLabel: UILabel!
    
    var calendarManager = CalendarManager()
    var cMB: CalendarManagerBrain = CalendarManagerBrain()
    
    override func viewDidLoad() {
        calendarManager.delegate = self
        
        super.viewDidLoad()
        
        calendarManager.fetchWorkHours()
    }
    
    @IBAction func calendarManagerTest(_ sender: UIButton) {
        cMB.iterateOverAvailabilityDict(on: 3)
        calendarManager.fetchWorkHours()
    }
    
}

extension ViewController: CalendarManagerDelegate {
    func didFetchWork(hours: Int) {
        workHoursLabel.text = "Work hours in this month: \(hours)"
    }
    
    func didFailWhileFetching(_ error: Error) {
        print(error)
    }
    
    
}
