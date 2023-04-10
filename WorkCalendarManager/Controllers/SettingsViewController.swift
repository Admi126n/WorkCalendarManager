//
//  SettingsViewController.swift
//  WorkCalendarManager
//
//  Created by Adam on 10/04/2023.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var minDurationLabel: UILabel!
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    
    @IBOutlet weak var appearanceControl: UISegmentedControl!
    
    @IBOutlet weak var minDurationStepper: UIStepper!
    @IBOutlet weak var maxDurationStepper: UIStepper!
    @IBOutlet weak var startHourStepper: UIStepper!
    @IBOutlet weak var endHourStepper: UIStepper!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
        
        appearanceControl.selectedSegmentIndex = defaults.integer(forKey: K.appAppearanceDefaults)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        updateLabels()
    }
    
    private func updateLabels() {
        minDurationLabel.text = "Minimum: \(Int(minDurationStepper.value))h"
        maxDurationLabel.text = "Maximum: \(Int(maxDurationStepper.value))h"
        startHourLabel.text = "Start hour: \(Int(startHourStepper.value)):00"
        endHourLabel.text = "End hour: \(Int(endHourStepper.value)):00"
    }
}
