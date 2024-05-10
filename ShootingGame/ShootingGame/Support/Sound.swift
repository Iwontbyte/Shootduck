//
//  Sound.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/5.
//

import Foundation
enum Sound: String {
    case musicLoop = "Cheerful Annoyance.wav"
    case hit = "hit.wav"
    case reload = "reload.wav"
    case score = "score.wav"
    
    var fileName: String {
        return rawValue
    }
}
