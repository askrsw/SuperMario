//
//  EnemiesBaseNode.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/24.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

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
    
    var physicalShape: UIBezierPath {
        get {
            return UIBezierPath()
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        run(animation)
    }
    
    // MARK: interface
    
    func createPhysicsBody() {
        physicsBody = SKPhysicsBody(polygonFrom: physicalShape.cgPath)
        physicsBody!.categoryBitMask = PhysicsCategory.Evildoer
        physicsBody!.collisionBitMask = physicsBody!.collisionBitMask & ~( PhysicsCategory.MarioPower | PhysicsCategory.Coin | PhysicsCategory.Gadget | PhysicsCategory.EBullet)
        physicsBody!.contactTestBitMask = PhysicsCategory.Solid | PhysicsCategory.Brick | PhysicsCategory.GoldMetal | PhysicsCategory.Mario | PhysicsCategory.MBullet | PhysicsCategory.Evildoer
        physicsBody!.restitution = 0.0
        physicsBody!.friction = 1.0
        physicsBody!.allowsRotation = false
    }
    
    func update(deltaTime dt: CGFloat) {
        if let physicsBody = physicsBody {
            let velocityX = speedX * (self.faceLeft ? -1.0 : 1.0)
            physicsBody.velocity = CGVector(dx: velocityX, dy: physicsBody.velocity.dy)
        }
        
        if position.y < -self.size.height {
            removeFromParent()
        }
    }
    
    func collideWithEnemy() {
        //guard let physicsBody = physicsBody else { return }
        let delta = GameConstant.TileGridLength * 0.25 * (faceLeft ? -1.0 : 1.0)
        position = CGPoint(x: position.x + delta, y: position.y)
    }
}
