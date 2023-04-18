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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.settingsScreenSegue {
            let svc = segue.destination as! SettingsViewController
            svc.delegate = self
        }
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

extension ViewController: SettingsViewControllerDelegate {
    func updateSettings(_ settingsDict: [String : Int]) {
        // TODO: update all settings in calendar manager
    }
    
    
}
