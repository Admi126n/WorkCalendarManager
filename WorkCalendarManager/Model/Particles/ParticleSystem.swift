//
//  ParticleSystem.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 27/11/2024.
//

import SwiftUI

class ParticleSystem {
	
	static var emojis: [String] = ["💵", "💸", "💰", "🤑"]
	
	var emoji: String {
		ParticleSystem.emojis.randomElement()!
	}
	
	var particles = Set<Particle>()
	var center = UnitPoint.center
	var lastUpdate: TimeInterval = Date.timeIntervalSinceReferenceDate
	
	func update(date: TimeInterval) {
		let deathDate = date - 5

		for particle in particles {
			if particle.creationDate < deathDate {
				particles.remove(particle)
			}
		}
		
		if date - Double(Int.random(in: 1...5)) > lastUpdate {
			lastUpdate = date
			let newParticle = Particle(
				x: Double.random(in: 0.1...0.9),
				y: Double.random(in: 0.1...0.9),
				emoji: emoji)
			
			particles.insert(newParticle)
		}
	}
}
