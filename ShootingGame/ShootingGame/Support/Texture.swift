//
//  Texture.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/5.
//

import Foundation

enum Texture: String {
    case fireButtonNomal = "fire_normal"
    case fireButtonPressed = "fire_pressed"
    case fireButtonReloading = "fire_reloading"
    case bulletEmptyTxture = "icon_bullet_empty"
    case bulletTxture = "icon_bullet"
    case shotBlue = "shot_blue"
    case shotBrown = "shot_brown"
    case duckIcon = "icon_duck"
    case targetIcon = "icon_target"
    
    var imageName: String {
        return rawValue
    }
    
}

