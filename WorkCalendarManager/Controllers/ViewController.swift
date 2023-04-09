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
    var calendarManagerBrain = CalendarManagerBrain()
    
    override func viewDidLoad() {
        calendarManager.delegate = self
        
        super.viewDidLoad()
        
        calendarManager.fetchWorkHours()
    }
    
    @IBAction func calendarManagerTest(_ sender: UIButton) {
        calendarManagerBrain.iterateOverDays()
        calendarManager.fetchWorkHours()
    }
    
}

extension ViewController: CalendarManagerDelegate {
    func didFetchWorkHours(hours: Int) {
        workHoursLabel.text = "Work hours in this month: \(hours)"
    }
    
    func didFail(_ error: Error, _ message: String?) {
        print(error)
    }
    
    
}
