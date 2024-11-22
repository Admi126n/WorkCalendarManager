//
//  Locale+CurrncySymbol.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 18/06/2024.
//

import Foundation

extension Locale {
	
	static var currencySymbol: String? {
		current.currency?.identifier
	}
}
