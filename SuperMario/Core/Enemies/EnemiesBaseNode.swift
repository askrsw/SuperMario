//
//  EnemiesBaseNode.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/24.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

struct PhysicalShapeParam {
    let size: CGSize
    let center: CGPoint
}

class EnemiesBaseNode: SKSpriteNode {
    
    var speedX: CGFloat {
        get {
            return 0.0
        }
    }
    
    var shouldMirrorY: Bool {
        get {
            return true
        }
    }
    
    var physicalShapeParam: PhysicalShapeParam {
        get {
            return PhysicalShapeParam(size: .zero, center: .zero)
        }
    }
    
    var faceLeft: Bool = true {
        didSet {
            if shouldMirrorY {
                if faceLeft {
                    xScale = 1.0
                } else {
                    xScale = -1.0
                }
            }
        }
    }
    
    var animation: SKAction {
        get {
            return SKAction()
        }
    }
    
    var active: Bool = false
    var xStart: CGFloat = -1.0
    var posXBefore: CGFloat = 0.0
    var backup_physicsBody: SKPhysicsBody?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let xStart = userData?["xStart"] as! Int32
        if xStart > 0 {
            self.xStart = CGFloat(xStart) * GameConstant.TileGridLength
        }
        
        run(animation, withKey: "animation")
    }
    
    // MARK: interface
    
    func update(deltaTime dt: CGFloat) {
        guard active else {
            if xStart < 0.0 || GameManager.instance.mario.position.x > (xStart - GameManager.instance.currentScene!.halfScaledSceneWdith) {
                createPhysicsBody()
                active = true
            }
            
            return
        }
        
        posXBefore = position.x
        
        if let physicsBody = physicsBody, physicsBody.categoryBitMask != PhysicsCategory.None {
            let velocityX: CGFloat = speedX * (self.faceLeft ? -1.0 : 1.0)
            physicsBody.velocity = CGVector(dx: velocityX, dy: physicsBody.velocity.dy)
        }
        
        if position.y < -self.size.height {
            removeFromParent()
        }
    }
    
    func postPhysicsProcess() {
        guard active else { return }
        guard let pbody = physicsBody, pbody.categoryBitMask != PhysicsCategory.None else { return }
        
        let delta = abs(position.x - posXBefore)
        if delta < 5e-2 {
            self.faceLeft = !self.faceLeft
        }
    }
    
    func contactWithMario(point contactPoint: CGPoint, normal contactNormal: CGVector) {
        let fixedPoint = CGPoint(x: GameManager.instance.mario.position.x, y: contactPoint.y)
        let localPoint = self.convert(fixedPoint, from: GameManager.instance.currentScene!)
        if GameManager.instance.mario.powerfull {
            hitByBullet()
        } else if abs(contactNormal.dy) > 0.5 && isBeingSteppedOn(localPoint) {
            GameManager.instance.mario.bounceALittle()
            beSteppedOn()
        } else {
            GameManager.instance.mario.collideWithEnemy()
        }
    }
    
    func hitByBullet() {
        beforeKilledByBullet()
        
        physicsBody!.categoryBitMask = PhysicsCategory.None
        physicsBody!.contactTestBitMask = PhysicsCategory.None
        physicsBody!.collisionBitMask = PhysicsCategory.None
        physicsBody!.velocity = .zero
        
        let verticalForce = physicsBody!.mass * 270.0
        physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
    
    func shakedByBottomSupport() {
        hitByBullet()
    }
    
    // MARK: Help method
    
    func isBeingSteppedOn(_ point: CGPoint) -> Bool {
        return false
    }
    
    func beSteppedOn() { }
    
    func beforeKilledByBullet() {
        self.removeAllActions()
    }
    
    private func createPhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOf: physicalShapeParam.size, center: physicalShapeParam.center)
        physicsBody!.categoryBitMask = PhysicsCategory.Evildoer
        physicsBody!.collisionBitMask = PhysicsCategory.Static | PhysicsCategory.ErasablePlat | PhysicsCategory.Evildoer
        physicsBody!.contactTestBitMask = PhysicsCategory.Mario | PhysicsCategory.MBullet
        physicsBody!.restitution = 0.0
        physicsBody!.friction = 1.0
        physicsBody!.allowsRotation = false
    }
}

extension EnemiesBaseNode: MarioShapeshifting {
    func marioWillShapeshift() {
        self.removeAction(forKey: "animation")
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
    }
    
    func marioDidShapeshift() {
        self.run(self.animation, withKey: "animation")
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
    }
}
