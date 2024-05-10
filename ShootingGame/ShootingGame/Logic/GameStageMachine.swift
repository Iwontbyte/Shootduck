//
//  GameStageMachine.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/5.
//

import Foundation
import GameplayKit

class GameState : GKState {
    unowned var fire: FireButton
    unowned var magazine: Magazine
    
    init(fire: FireButton, magazine: Magazine) {
        self.fire = fire
        self.magazine = magazine
        super.init()
    }
}

class ReadyStage: GameState {
    override func didEnter(from previousState: GKState?) {
        magazine.reloadIfNeed()
        stateMachine?.enter(ShootingStage.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ShootingStage.Type && !magazine.needReload() {
            return true
        }
        return false
    }
     
}

class ShootingStage: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ReloadingStage.Type && magazine.needReload() {
            return true
        }
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        fire.removeAction(forKey: ActionKey.reloading.rawValue)
        fire.run(.animate(with: [SKTexture.init(imageNamed: Texture.fireButtonNomal.imageName)], timePerFrame: 0.1),withKey: ActionKey.reloading.rawValue)
    }
}

class ReloadingStage: GameState {
    let reloadingTime = 0.25
    let reloadingTexture = SKTexture(imageNamed: Texture.fireButtonReloading.imageName)
    let bulletTexture = SKTexture(imageNamed: Texture.bulletTxture.imageName)
    lazy var bulletReloadingAction = {
        SKAction.animate(with: [bulletTexture], timePerFrame: 0.1)
    }()
    
    lazy var fireButtonReloadingAction = {
        SKAction.sequence([
            SKAction.animate(with: [reloadingTexture], timePerFrame: 0.1),
            SKAction.rotate(byAngle: 360, duration: 30)
        ])
    }()
    
    override func didEnter(from previousState: GKState?) {
        fire.isReloading = true
        fire.removeAction(forKey: ActionKey.reloading.rawValue)
        fire.run(fireButtonReloadingAction, withKey: ActionKey.reloading.rawValue)
        
        for (i,bullet) in magazine.bullets.reversed().enumerated() {
            var action = [SKAction]()
            let waitAction = SKAction.wait(forDuration: TimeInterval(reloadingTime * Double(i)))
            action.append(waitAction)
            action.append(bulletReloadingAction)
            action.append(SKAction.run {
                Audio.sharedInstance.playSound(soundFileName: Sound.reload.fileName)
            })
            action.append(SKAction.run {
                bullet.rereloaded()
            })
            if i == magazine.capacity - 1 {
                action.append(SKAction.run { [unowned self] in
                    self.fire.isReloading = false
                    self.stateMachine?.enter(ShootingStage.self)
                })
            }
            bullet.run(.sequence(action))
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ShootingStage.Type && !magazine.needReload() {
            return true
        }
        return false
    }
    
}
