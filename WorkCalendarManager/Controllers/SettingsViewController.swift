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

class SettingsViewController: UIViewController {
    @IBOutlet weak var minDurationLabel: UILabel!
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var marginBeforeLabel: UILabel!
    @IBOutlet weak var marginAfterLabel: UILabel!
    
    @IBOutlet weak var appearanceControl: UISegmentedControl!
    
    @IBOutlet weak var minDurationStepper: UIStepper!
    @IBOutlet weak var maxDurationStepper: UIStepper!
    @IBOutlet weak var startHourStepper: UIStepper!
    @IBOutlet weak var endHourStepper: UIStepper!
    @IBOutlet weak var marginBeforeStepper: UIStepper!
    @IBOutlet weak var marginAfterStepper: UIStepper!
    
    var delegate: SettingsViewControllerDelegate?
    private let defaults = UserDefaults.standard
    private var settingsDict: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
        
        appearanceControl.selectedSegmentIndex = defaults.integer(forKey: K.appAppearanceDefaults)
    }
    
    @IBAction func changeAppearance(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            defaults.set(UIUserInterfaceStyle.unspecified.rawValue, forKey: K.appAppearanceDefaults)
            view.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: K.appAppearanceDefaults))!
        case 1:
            defaults.set(UIUserInterfaceStyle.light.rawValue, forKey: K.appAppearanceDefaults)
            view.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: K.appAppearanceDefaults))!
        default:
            defaults.set(UIUserInterfaceStyle.dark.rawValue, forKey: K.appAppearanceDefaults)
            view.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: K.appAppearanceDefaults))!
        }
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        updateSettings()
        updateLabels()
        delegate?.updateSettings(settingsDict)
    }
    
    private func updateSettings() {
        settingsDict[K.S.minDuration] = Int(minDurationStepper.value)
        settingsDict[K.S.maxDuration] = Int(maxDurationStepper.value)
        settingsDict[K.S.startHour] = Int(startHourStepper.value)
        settingsDict[K.S.endHour] = Int(endHourStepper.value)
        settingsDict[K.S.marginBefore] = Int(marginBeforeStepper.value)
        settingsDict[K.S.marginAfter] = Int(marginAfterStepper.value)
    }
    
    private func updateLabels() {
        minDurationLabel.text = "Minimum: \(settingsDict[K.S.minDuration]!)h"
        maxDurationLabel.text = "Maximum: \(settingsDict[K.S.maxDuration]!)h"
        startHourLabel.text = "Start hour: \(settingsDict[K.S.startHour]!):00"
        endHourLabel.text = "End hour: \(settingsDict[K.S.endHour]!):00"
        marginBeforeLabel.text = "Margin before work: \(settingsDict[K.S.marginBefore]!)min"
        marginAfterLabel.text = "Margin after work: \(settingsDict[K.S.marginAfter]!)min"
    }
}
