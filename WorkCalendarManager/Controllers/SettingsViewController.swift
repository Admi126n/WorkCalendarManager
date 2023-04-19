//
//  SettingsViewController.swift
//  WorkCalendarManager
//
//  Created by Adam on 10/04/2023.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func updateSettings(_ settingsDict: [String: Int])
}

// FIXME: minDuration < maxDuration; startHour < endHour; endHour - startHour > minDuration
class SettingsViewController: UIViewController {
    @IBOutlet weak var minDurationLabel: UILabel!
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var marginBeforeLabel: UILabel!
    @IBOutlet weak var marginAfterLabel: UILabel!
    
    @IBOutlet weak var minDurationStepper: UIStepper!
    @IBOutlet weak var maxDurationStepper: UIStepper!
    @IBOutlet weak var startHourStepper: UIStepper!
    @IBOutlet weak var endHourStepper: UIStepper!
    @IBOutlet weak var marginBeforeStepper: UIStepper!
    @IBOutlet weak var marginAfterStepper: UIStepper!
    
    @IBOutlet weak var appearanceControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: SettingsViewControllerDelegate?
    private let defaults = UserDefaults.standard
    private var settingsDict: [String: Int] = [:]
    private var calendars: [[String: [Any]]] = [[:]]
    private var calendarManager: CalendarManager = CalendarManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.calendarCellName, bundle: nil), forCellReuseIdentifier: K.calendarCellIdentifier)
        
        calendars = calendarManager.getUserCalendarsColors()
        
        loadSettingsDict()
        updateLabelsText()
        updateSteppersValue()
        
        appearanceControl.selectedSegmentIndex = defaults.integer(forKey: K.D.appAppearance)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateSettingsDict()
        
        delegate?.updateSettings(settingsDict)
    }
    
    @IBAction func changeAppearance(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            defaults.set(UIUserInterfaceStyle.unspecified.rawValue, forKey: K.D.appAppearance)
            view.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: K.D.appAppearance))!
        case 1:
            defaults.set(UIUserInterfaceStyle.light.rawValue, forKey: K.D.appAppearance)
            view.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: K.D.appAppearance))!
        default:
            defaults.set(UIUserInterfaceStyle.dark.rawValue, forKey: K.D.appAppearance)
            view.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: K.D.appAppearance))!
        }
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        updateSettingsDict()
        updateLabelsText()
    }
    
    private func updateSettingsDict() {
        settingsDict[K.S.minDuration] = Int(minDurationStepper.value)
        settingsDict[K.S.maxDuration] = Int(maxDurationStepper.value)
        settingsDict[K.S.startHour] = Int(startHourStepper.value)
        settingsDict[K.S.endHour] = Int(endHourStepper.value)
        settingsDict[K.S.marginBefore] = Int(marginBeforeStepper.value)
        settingsDict[K.S.marginAfter] = Int(marginAfterStepper.value)
        
        defaults.set(settingsDict, forKey: K.D.settingsDict)
    }
    
    private func updateLabelsText() {
        minDurationLabel.text = "Minimum: \(settingsDict[K.S.minDuration] ?? K.workMinDuration)h"
        maxDurationLabel.text = "Maximum: \(settingsDict[K.S.maxDuration] ?? K.workMaxDuration)h"
        startHourLabel.text = "Start hour: \(settingsDict[K.S.startHour] ?? K.businessDayStartHour):00"
        endHourLabel.text = "End hour: \(settingsDict[K.S.endHour] ?? K.businessDayEndHour):00"
        marginBeforeLabel.text = "Margin before work: \((settingsDict[K.S.marginBefore] ?? K.marginBeforeWork) * 15)min"
        marginAfterLabel.text = "Margin after work: \((settingsDict[K.S.marginAfter] ?? K.marginAfterWork) * 15)min"
    }
    
    private func updateSteppersValue() {
        minDurationStepper.value = Double(settingsDict[K.S.minDuration] ?? K.workMinDuration)
        maxDurationStepper.value = Double(settingsDict[K.S.maxDuration] ?? K.workMaxDuration)
        startHourStepper.value = Double(settingsDict[K.S.startHour] ?? K.businessDayStartHour)
        endHourStepper.value = Double(settingsDict[K.S.endHour] ?? K.businessDayEndHour)
        marginBeforeStepper.value = Double(settingsDict[K.S.marginBefore] ?? K.marginBeforeWork)
        marginAfterStepper.value = Double(settingsDict[K.S.marginAfter] ?? K.marginAfterWork)
    }
    
    private func loadSettingsDict() {
        if let safeDict = defaults.dictionary(forKey: K.D.settingsDict) {
            settingsDict = safeDict as! [String: Int]
        }
    }
}

//MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let calendar = calendars[indexPath.row].first
        let cell = tableView.dequeueReusableCell(withIdentifier: K.calendarCellIdentifier, for: indexPath) as! CalendarCell
        
        cell.calendarName.text = (calendar!.value[0] as! String)
        cell.calendarColor.backgroundColor = UIColor(cgColor: calendar!.value[1] as! CGColor)
        
        return cell
    }
    
    
}

//MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CalendarCell
        
        if cell.checkmark.alpha == 0 {
            cell.checkmark.alpha = 1
        } else {
            cell.checkmark.alpha = 0
        }
    }
}
