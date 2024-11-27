//
//  Color+components.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 27/11/2024.
//

import SwiftUI

extension Color {
	
	var conponents: (red: CGFloat, green: CGFloat, blue: CGFloat) {
		let uiColor = UIColor(self)
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		
		guard uiColor.getRed(&r, green: &g, blue: &b, alpha: nil) else {
			return (0, 0, 0)
		}
		
		return (r, g, b)
	}
}
