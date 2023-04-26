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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var calendarManagerBrain = CalendarManagerBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CalendarManager.cm.delegate = self
        CalendarManager.cm.fetchWorkHours()
        CalendarManager.cm.getMonthsNames()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppDidBecomeActiveNotification(notification:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @IBAction func changeMonth(_ sender: UISegmentedControl) {
        CalendarManager.cm.setMonthsFromCurr(sender.selectedSegmentIndex)
        CalendarManager.cm.fetchWorkHours()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        runActivityIndicatorAndExecute {
            self.calendarManagerBrain.iterateOverDays()
            CalendarManager.cm.fetchWorkHours()
        }
        
    }

    @objc func handleAppDidBecomeActiveNotification(notification: Notification) {
        CalendarManager.cm.fetchWorkHours()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.settingsScreenSegue {
            let svc = segue.destination as! SettingsViewController
            svc.delegate = self
        }
    }
    
    func runActivityIndicatorAndExecute(code: @escaping () -> Void) {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        settingsButton.isUserInteractionEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            code()
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.settingsButton.isUserInteractionEnabled = true
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - CalendarManagerDelegate

extension ViewController: CalendarManagerDelegate {
    func didFetchWorkHours(_ hours: Int) {
        let selectedSegmentTitle = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
        
        DispatchQueue.main.async { [self] in
            self.workHoursLabel.text = "Work hours in \(selectedSegmentTitle): \(hours)"
        }
    }
    
    func didGetMonthsNames(_ monthsNames: [String]) {
        for i in 0..<segmentedControl.numberOfSegments {
            segmentedControl.setTitle(monthsNames[i], forSegmentAt: i)
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
