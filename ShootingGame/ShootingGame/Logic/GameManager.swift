//
//  GameManager.swift
//  ShootingGame
//
//  Created by - Auditore on 2024/4/5.
//

import Foundation
import SpriteKit

class GameManager {
    unowned var scene: SKScene!
    
    var totalScore = 0
    var targetScore = 10
    var duckScore = 10
    var duckCount = 0
    var targetCount = 0
    var duckMoveDuration: TimeInterval!
    let ammunitionQuantity = 5
       var zPositionDecimal = 0.001 {
        didSet {
            if zPositionDecimal == 1 {
                zPositionDecimal = 0.001
            }
        }
    }
    
    var targetXposition:[Int] = [160, 240, 320, 400, 480, 560, 640]
    var usingTargetXposition = Array<Int>()
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func  GenerateDuck(hasTarget:Bool = false) -> Duck {
        var duck:SKSpriteNode
        var stick:SKSpriteNode
        var duckImageName:String
        var duckNodeName:String
        var texture = SKTexture()
        let node = Duck(hasTarget: hasTarget)
        
        if hasTarget {
            duckImageName = "duck_target/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed:duckImageName)
            duckNodeName = "duck_target"
        } else {
            duckImageName = "duck/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed:duckImageName)
            duckNodeName = "duck"
        }
        duck = SKSpriteNode(texture: texture)
        duck.name = duckNodeName
        duck.position = CGPoint(x: 0, y: 140)
        let physcisBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
        physcisBody.affectedByGravity = false
        physcisBody.isDynamic = false
        duck.physicsBody = physcisBody
        
        stick = SKSpriteNode(imageNamed: "stick/\(Int.random(in: 1...2))")
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        duck.xScale = 0.8
        duck.yScale = 0.8
        stick.xScale = 0.8
        stick.yScale = 0.8
        
        node.addChild(stick)
        node.addChild(duck)
        
        return node
    }
    
    
    func  GenerateTarget() -> Target {
        var target:SKSpriteNode
        var stick:SKSpriteNode
        let texture = SKTexture(imageNamed:"target/\(Int.random(in: 1...3))")
        let node = Target()
        
        target = SKSpriteNode(texture: texture)
        target.name = "target"
        target.position = CGPoint(x: 0, y: 95)
        
        stick = SKSpriteNode(imageNamed: "stick_metal")
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        target.xScale = 0.5
        target.yScale = 0.5
        stick.xScale = 0.5
        stick.yScale = 0.5
        
        node.addChild(stick)
        node.addChild(target)
        
        return node
    }
    
    func activeDucks(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block:{ _ in
            let duck = self.GenerateDuck(hasTarget: Bool.random())
            duck.position = CGPoint(x: -10, y: Int.random(in: 60...90))
            duck.zPosition = Int.random(in: 0...1) == 0 ? 4 : 6
            duck.zPosition += CGFloat(self.zPositionDecimal)
            self.zPositionDecimal += 0.001
            
            self.scene.addChild(duck)
            
            if duck.hasTarget {
                self.duckMoveDuration = TimeInterval(Int.random(in: 3...5))
            } else {
                self.duckMoveDuration = TimeInterval(Int.random(in: 4...7))
            }
            
            
            duck.run(.sequence([
                .moveTo(x: 850, duration: self.duckMoveDuration),
                .removeFromParent()
            ]
            ))
        })
    }
    
    func activeTargets() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block:{ _ in
            let target = self.GenerateTarget()
            var xpositon = self.targetXposition.randomElement()!
            
            while self.usingTargetXposition.contains(xpositon){
                xpositon = self.targetXposition.randomElement()!
            }
            
            let physcisBody = SKPhysicsBody(circleOfRadius: 71/2)
            physcisBody.affectedByGravity = false
            physcisBody.isDynamic = false
            physcisBody.allowsRotation = false
            
            self.usingTargetXposition.append(xpositon)
            
            target.position = CGPoint(x: xpositon, y: Int.random(in: 120...145))
            target.zPosition = 1
            
            self.scene.addChild(target)
            
            target.run(.sequence([
                .scaleY(to: 1, duration: 0.2),
                .run {
                    if let node = target.childNode(withName: "target") {
                        node.physicsBody = physcisBody
                    }
                },
                .wait(forDuration: TimeInterval(Int.random(in: 2...4))),
                .scaleY(to: 0, duration: 0.2),
                .removeFromParent(),
                .run{
                    self.usingTargetXposition.remove(at: self.usingTargetXposition.firstIndex(of: xpositon)!)
                }
                
            ])
            )})
    }
    
    
    func addShot(image: String, to node: SKSpriteNode, on position: CGPoint) {
        let convertedPosition = scene.convert(position, to: node)
        let shot = SKSpriteNode(imageNamed: image)
        
        shot.position = convertedPosition
        node.addChild(shot)
        shot.run(.sequence([
            .wait(forDuration: 2),
            .fadeAlpha(to: 0.0, duration: 0.3),
            .removeFromParent()
        ]))
        
    }
    
    func findShotNode(at position:CGPoint) -> SKSpriteNode {
        var shotNode = SKSpriteNode()
        var biggestzPosition: CGFloat = 0.0
        
        scene.physicsWorld.enumerateBodies(at: position, using: { (body, pointer) in
            guard let node = body.node as? SKSpriteNode else { return }
            if node.name == "duck" || node.name == "duck_target" || node.name == "target" {
                if let parentNode = node.parent {
                    if parentNode.zPosition  > biggestzPosition {
                        biggestzPosition = parentNode.zPosition
                        shotNode = node
                    }
                }
            }
        })
        return shotNode
    }
    
    func findTextAndImageName(for nodeName: String?) -> (String, String)? {
        var scoreText = ""
        var shotImageName = ""
        
        switch nodeName {
        case "duck":
            scoreText = "+\(duckScore)"
            duckCount += 1
            totalScore += duckScore
            shotImageName = Texture.shotBlue.imageName
        case "duck_target":
            scoreText = "+\(duckScore + targetScore)"
            duckCount += 1
            targetCount += 1
            totalScore += duckScore + targetScore
            shotImageName = Texture.shotBlue.imageName
        case "target":
            scoreText = "+\(targetScore)"
            targetCount += 1
            totalScore += targetScore
            shotImageName = Texture.shotBrown.imageName
        default:
            return nil
        }
        return  (scoreText,shotImageName)
    }
    
    
    func generateTextNode(from text: String, leadingAnchorPoint: Bool = true) -> SKNode {
        let node = SKNode()
        var width: CGFloat = 0.0
        
        for character in text {
            var characterNode = SKSpriteNode()
            
            if character == "0" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.zero.textureName)
            } else if character == "1" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.one.textureName)
            } else if character == "2" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.two.textureName)
            } else if character == "3" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.three.textureName)
            } else if character == "4" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.four.textureName)
            } else if character == "5" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.five.textureName)
            } else if character == "6" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.six.textureName)
            } else if character == "7" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.seven.textureName)
            } else if character == "8" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.eight.textureName)
            } else if character == "9" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.nine.textureName)
            } else if character == "+" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.plus.textureName)
            } else if character == "*" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.multiplication.textureName)
            } else {
                continue
            }
            
            node.addChild(characterNode)
            
            characterNode.anchorPoint = CGPoint(x: 0, y: 0.5)
            characterNode.position = CGPoint(x: width, y: 0.0)
            
            width += characterNode.size.width
        }
        
        if leadingAnchorPoint {
            return node
        } else {
            let anotherNode = SKNode()
            anotherNode.addChild(node)
            node.position = CGPoint(x: -width/2, y: 0)
            return anotherNode
        }
    }
    
    func addTextNode(on position: CGPoint, from text: String) {
        let scorePosition = CGPoint(x: position.x + 10, y: position.y + 30)
        let scoreNode = generateTextNode(from: text)
        scoreNode.position = scorePosition
        scoreNode.zPosition = 9
        scoreNode.xScale = 0.5
        scoreNode.yScale = 0.5
        scene.addChild(scoreNode)
        scoreNode.run(.sequence([
            .wait(forDuration: 0.5),
            .fadeOut(withDuration: 0.2),
            .removeFromParent()]))
    }
    
    func update(text: String, node: inout SKNode, leadingAnchorPoint: Bool = true) {
        let position = node.position
        let zPositon = node.zPosition
        let xScale = node.xScale
        let yScale = node.yScale
        
        node.removeFromParent()
        
        node = generateTextNode(from: text, leadingAnchorPoint: leadingAnchorPoint)
        node.position = position
        node.zPosition = zPositon
        node.xScale = xScale
        node.yScale = yScale
        
        scene.addChild(node)
    }
}


