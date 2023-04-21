//
//  ViewController.swift
//  WorkCalendarManager
//
//  Created by Adam on 28/03/2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var workHoursLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var calendarManager = CalendarManager()
    var calendarManagerBrain = CalendarManagerBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarManager.delegate = self
        calendarManager.fetchWorkHours()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidBecomeActiveNotification(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        settingsButton.isUserInteractionEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.calendarManagerBrain.iterateOverDays()
            self.calendarManager.fetchWorkHours()

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.settingsButton.isUserInteractionEnabled = true
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.settingsScreenSegue {
            let svc = segue.destination as! SettingsViewController
            svc.delegate = self
        }
    }
    
    @objc func handleAppDidBecomeActiveNotification(notification: Notification) {
        calendarManager.fetchWorkHours()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - CalendarManagerDelegate

extension ViewController: CalendarManagerDelegate {
    func didFetchWorkHours(hours: Int) {
        DispatchQueue.main.async {
            self.workHoursLabel.text = "Work hours in this month: \(hours)"
        }
    }
    
    func didFail(_ error: Error, _ message: String?) {
        print(error)
    }
    
    
}

//MARK: - SettingsViewControllerDelegate

extension ViewController: SettingsViewControllerDelegate {
    func updateIgnoredCalendars() {
        calendarManagerBrain.setIgnoredCalendars()
    }
    
    func updateSettings(_ settingsDict: [String : Int]) {
        calendarManagerBrain.setSettingsDict(settingsDict)
    }
    
    
}
