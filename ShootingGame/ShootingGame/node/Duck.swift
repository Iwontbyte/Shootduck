//
//  Duck.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/6.
//

import Foundation
import SpriteKit

class Duck: SKNode {
    var hasTarget:Bool!
    
    init(hasTarget:Bool = false) {
        super.init()
        self.hasTarget = hasTarget
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

