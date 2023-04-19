//
//  CalendarCell.swift
//  WorkCalendarManager
//
//  Created by Adam on 19/04/2023.
//

import UIKit

class CalendarCell: UITableViewCell {
    @IBOutlet weak var calendarName: UILabel!
    @IBOutlet weak var calendarColor: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        calendarColor.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
}
