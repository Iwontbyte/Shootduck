//
//  Bullet.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/13.
//

import Foundation
import SpriteKit
 
class Bullet: SKSpriteNode {
    private var isEmpty = true
    
    init() {
        let texture = SKTexture(imageNamed: Texture.bulletEmptyTxture.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rereloaded() {
        isEmpty  = false
    }

    func shoot() {
        isEmpty  = true
        texture = SKTexture(imageNamed: Texture.bulletEmptyTxture.imageName)
    }
    
    func wasShoot () -> Bool {
        return isEmpty
    }
    
    func reloadIfneeded() {
        if isEmpty {
            texture = SKTexture(imageNamed: Texture.bulletTxture.imageName)
            isEmpty = false
        }
    }
}
