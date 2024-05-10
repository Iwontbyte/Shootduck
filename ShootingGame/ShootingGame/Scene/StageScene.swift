//
//  StageScene.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/6.
//

import Foundation
import SpriteKit
import GameplayKit

class StageScene: SKScene {
    
    var rifle:SKSpriteNode?
    var crosshair:SKSpriteNode?
    var duckScoreNode:SKNode!
    var targetScoreNode:SKNode!
    var fire = FireButton()
    var touchesDiff:(CGFloat,CGFloat)?
    var magazineManager: Magazine!
    var gameStateMachine: GKStateMachine!
    var manager: GameManager!
    var selectedNode:[UITouch: SKSpriteNode] = [:]
    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        print("123")
    }
    override func didMove(to view: SKView) {
        manager = GameManager(scene: self)
        
        loadUI()
        Audio.sharedInstance.playSound(soundFileName: Sound.musicLoop.fileName)
        Audio.sharedInstance.player(with: Sound.musicLoop.fileName)?.volume = 0.3
        Audio.sharedInstance.player(with: Sound.musicLoop.fileName)?.numberOfLoops = -1
        
        gameStateMachine = GKStateMachine(states: [
            ReadyStage(fire: fire, magazine: magazineManager),
            ShootingStage(fire: fire, magazine: magazineManager),
            ReloadingStage(fire: fire, magazine: magazineManager)
        ])
        gameStateMachine.enter(ReadyStage.self)
        
        manager.activeDucks()
        manager.activeTargets()
    }
}

// MARK - TOUCHES
extension StageScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let crosshair = crosshair else {
            return
        }
        for touch in touches {
            let location = touch.location(in: self)
            if let node = self.atPoint(location) as? SKSpriteNode {
                if !selectedNode.values.contains(crosshair) && !(node is FireButton) {
                    selectedNode[touch] = crosshair
                    let xDiff = touch.location(in: self).x - crosshair.position.x
                    let yDiff = touch.location(in: self).y - crosshair.position.y
                    touchesDiff = (xDiff,yDiff)
                }
                
                //Actual shooting
                if node is FireButton {
                    selectedNode[touch] = fire
                    if !fire.isReloading {
                        fire.isPressed = true
                        magazineManager.shoot()
                        Audio.sharedInstance.playSound(soundFileName: Sound.hit.fileName)
                        //Check reloading
                        if magazineManager.needReload() {
                            gameStateMachine.enter(ReloadingStage.self)
                        }
                        //find shoot node
                        let shootNode = manager.findShotNode(at: crosshair.position)
                        
                        guard let (scoreText,shotImageName) = manager.findTextAndImageName(for: shootNode.name) else {
                            return
                        }
                        //Add shot image
                        manager.addShot(image: shotImageName, to: shootNode, on: crosshair.position)
                        
                        //Add Score image
                        manager.addTextNode(on: crosshair.position, from: scoreText)
                        Audio.sharedInstance.playSound(soundFileName: Sound.score.fileName)
                        
                        manager.update(text: String(manager.duckCount * manager.duckScore), node: &duckScoreNode)
                        manager.update(text: String(manager.targetCount * manager.targetScore), node: &targetScoreNode)
                        
                        //after shoot
                        shootNode.physicsBody = nil
                        if let node = shootNode.parent {
                            node.run(.sequence([
                                .wait(forDuration: 0.2),
                                .scaleY(to: 0.0, duration: 0.2)
                            ]))
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let crosshair = crosshair,let touchesDiff = touchesDiff else {
            return
        }
        for touch in touches {
            let location = touch.location(in: self)
            if let node = selectedNode[touch] {
                if node.name != "fire" {
                    let newCrosshairPosition = CGPoint(x: location.x - touchesDiff.0, y: location.y - touchesDiff.1)
                    crosshair.position = newCrosshairPosition
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNode[touch] != nil {
                if let fire = selectedNode[touch] as? FireButton {
                    fire.isPressed = false
                }
                selectedNode[touch]  = nil
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        syncRiflePosition()
        setBoundry()
    }
}


extension StageScene {
    func loadUI() {
        if let scene =  scene {
            rifle = childNode(withName: "rifle") as? SKSpriteNode
            crosshair = childNode(withName: "crosshair") as? SKSpriteNode
            crosshair?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        }
        
        fire.position = CGPoint(x: 720 , y: 90)
        fire.zPosition = 11
        fire.xScale = 1.6
        fire.yScale = 1.6
        addChild(fire)
        
        // Add icons
        let duckIcon = SKSpriteNode(imageNamed: Texture.duckIcon.imageName)
        duckIcon.position = CGPoint(x: 36, y: 365)
        duckIcon.zPosition = 11
        addChild(duckIcon)
        
        let targetIcon = SKSpriteNode(imageNamed: Texture.targetIcon.imageName)
        targetIcon.position = CGPoint(x: 36, y: 325)
        targetIcon.zPosition = 11
        addChild(targetIcon)
        
        duckScoreNode = manager.generateTextNode(from: "0")
        duckScoreNode.position = CGPoint(x: 60, y: 365)
        duckScoreNode.zPosition = 11
        duckScoreNode.xScale = 0.5
        duckScoreNode.yScale = 0.5
        addChild(duckScoreNode)
        
        targetScoreNode = manager.generateTextNode(from: "0")
        targetScoreNode.position = CGPoint(x: 60, y: 325)
        targetScoreNode.zPosition = 11
        targetScoreNode.xScale = 0.5
        targetScoreNode.yScale = 0.5
        addChild(targetScoreNode)
        
        let magazine = SKNode()
        magazine.position = CGPoint(x: 760, y: 30)
        magazine.zPosition = 11
        
        var bullets = [Bullet]()
        for i in 0...manager.ammunitionQuantity - 1 {
            let bullet = Bullet()
            bullet.position = CGPoint(x: -30 * i, y: 0)
            bullets.append(bullet)
            magazine.addChild(bullet)
        }
        
        magazineManager = Magazine(bullets: bullets)
        addChild(magazine)
    }
    
    func syncRiflePosition() {
        if let rifle = rifle, let crosshair = crosshair {
            rifle.position.x = crosshair.position.x + 100
        }
    }
    
    func setBoundry() {
        guard let scene = scene else { return }
        guard let crosshair = crosshair else { return }
        
        if crosshair.position.x < scene.frame.minX {
            crosshair.position.x = scene.frame.minX
        }
        
        if crosshair.position.x > scene.frame.maxX {
            crosshair.position.x = scene.frame.maxX
        }
        
        if crosshair.position.y < scene.frame.minY {
            crosshair.position.y = scene.frame.minY
        }
        
        if crosshair.position.y > scene.frame.maxY {
            crosshair.position.y = scene.frame.maxY
        }
        
    }
}
