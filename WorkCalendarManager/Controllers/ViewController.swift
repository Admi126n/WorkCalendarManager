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
    
    var calendarManager = CalendarManager()
    var calendarManagerBrain = CalendarManagerBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSegmentedControl()
        
        calendarManager.delegate = self
        calendarManager.fetchWorkHours()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidBecomeActiveNotification(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setSegmentedControl() {
        segmentedControl.setTitle("\(DateFormatter().shortMonthSymbols[calendarManager.currMonth - 1])", forSegmentAt: 0)
        segmentedControl.setTitle("\(DateFormatter().shortMonthSymbols[calendarManager.currMonth])", forSegmentAt: 1)
        segmentedControl.setTitle("\(DateFormatter().shortMonthSymbols[calendarManager.currMonth + 1])", forSegmentAt: 2)
    }
    
    @IBAction func changeMonth(_ sender: UISegmentedControl) {
        calendarManager.monthsFromCurr = sender.selectedSegmentIndex
        calendarManagerBrain.setMonthsFromCurr(x: sender.selectedSegmentIndex)
        calendarManager.fetchWorkHours()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        settingsButton.isUserInteractionEnabled = false
        // TODO: maybe add label with info 'adding events'
        
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
        DispatchQueue.main.async { [self] in
            self.workHoursLabel.text = "Work hours in \(segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? ""): \(hours)"
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
