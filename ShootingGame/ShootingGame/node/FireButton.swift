//
//  FireButton.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/5.
//

import Foundation
import SpriteKit

class FireButton: SKSpriteNode {
    
    var isReloading = false
    
    var isPressed = false {
        didSet {
            if isPressed {
                 texture = SKTexture(imageNamed: Texture.fireButtonPressed.imageName)
            } else {
                 texture = SKTexture(imageNamed: Texture.fireButtonNomal.imageName)
            }
            
        }
    }
    
 
    init() {
        let texture = SKTexture(imageNamed: Texture.fireButtonNomal.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        name = "fire"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

