//
//  Particle.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 27/11/2024.
//

import Foundation

struct Particle: Hashable {
	
	let x: Double
	let y: Double
	let emoji: String
	let creationDate = Date.now.timeIntervalSinceReferenceDate
}
