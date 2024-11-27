//
//  ParticlesView.swift
//  WorkCalendarManager
//
//  Created by Adam Tokarski on 27/11/2024.
//

import SwiftUI

struct ParticlesView: View {
	@State private var particleSystem = ParticleSystem()
	
	var body: some View {
		TimelineView(.animation) { timeline in
			Canvas { context, size in
				let timelineDate = timeline.date.timeIntervalSinceReferenceDate
				particleSystem.update(date: timelineDate)
				
				for particle in particleSystem.particles {
					let xPos = particle.x * size.width
					let yPos = particle.y * size.height
					
					let age = timelineDate - particle.creationDate
					
					context.opacity = getOpacity(for: age)
					context.draw(Text(particle.emoji), at: CGPoint(x: xPos, y: yPos))
				}
			}
		}
	}
	
	private func getOpacity(for age: Double) -> Double {
		let appearPhase = 1.0
		
		switch age {
		case 0...appearPhase:
			return age / appearPhase
		case appearPhase...:
			return 1 - age / 5
		default:
			return 0.0
		}
	}
}

#Preview {
    ParticlesView()
}
