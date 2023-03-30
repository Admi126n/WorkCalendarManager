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
    
    override func viewDidLoad() {
        calendarManager.delegate = self
        
        super.viewDidLoad()
        
        calendarManager.fetchWorkHours()
    }
    
    
}

extension ViewController: CalendarManagerDelegate {
    func didFetchWork(hours: Int) {
        workHoursLabel.text = "\(hours)"
    }
    
    func didFailWhileFetching(_ error: Error) {
        print(error)
    }
    
    
}
