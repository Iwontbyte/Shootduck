//
//  Magazine.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/13.
//

import Foundation
import SpriteKit

class Magazine {
    var bullets : [Bullet]!
    var capacity: Int!
    
    init(bullets: [Bullet]!) {
        self.bullets = bullets
        self.capacity = bullets.count
    }
    
    func shoot() {
        bullets.first{ $0.wasShoot() == false }?.shoot()
    }
    
    func needReload() -> Bool {
        return bullets.allSatisfy{ $0.wasShoot() == true }
    }
    
    func reloadIfNeed() {
        if needReload() {
            for bullet in bullets {
                bullet.reloadIfneeded()
            }
        }
       
    }
    
}
