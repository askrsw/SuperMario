//
//  EBulletSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/19.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class EBulletSprite: SKSpriteNode {
    let dir: CGFloat
    let texType: String = "a"
    var backup_physicsBody: SKPhysicsBody?
    var dead: Bool = false
    
    init(faceTo dir: CGFloat, shootPos pos: CGPoint) {
        self.dir = dir
        let tex = SKTexture(imageNamed: "ebullet_a_1")
        super.init(texture: tex, color: .clear, size: tex.size())
        
        anchorPoint = CGPoint(x: 0.5, y: 0.75)
        
        if dir < 0 {
            let x = pos.x - GameConstant.TileGridLength
            let y = pos.y + GameConstant.TileGridLength * 0.5
            position = CGPoint(x: x, y: y)
        }
        
        zPosition = GameManager.instance.mario.zPosition + 1.0
        
        makePhysicsBody()
        
        run(rotateAction, withKey: "rotation")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contactWithMario() {
        if !GameManager.instance.mario.powerfull {
            GameManager.instance.mario.collideWithEnemy()
        }
        
        removeFromParent()
    }
    
    func contactWithStatic() {
        physicsBody?.categoryBitMask = PhysicsCategory.None
        physicsBody?.collisionBitMask = PhysicsCategory.Static
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.velocity = .zero
        dead = true
        removeAction(forKey: "rotation")
        self.run(deleteAction)
    }
    
    func applyImpulse() {
        if let physicsBody = physicsBody {
            let forceY: CGFloat = physicsBody.mass * 150.0
            let forceX: CGFloat = physicsBody.mass * 200.0 * dir
            physicsBody.applyImpulse(CGVector(dx: forceX, dy: forceY))
            
            //let point = CGPoint(x: 0.0, y: 4.0)
            let torque: CGFloat = physicsBody.mass
            physicsBody.applyTorque(torque)
        }
    }
    
    // MARK: Helper Method
    
    private func makePhysicsBody() {
        let size1 = CGSize(width: 2.0, height: 16.0)
        let body1 = SKPhysicsBody(rectangleOf: size1)
        
        let size2 = CGSize(width: 6, height: 6)
        let center2 = CGPoint(x: 0.0, y: 4.0)
        let body2 = SKPhysicsBody(rectangleOf: size2, center: center2)
        
        let body = SKPhysicsBody(bodies: [body1, body2])
        body.categoryBitMask    = PhysicsCategory.EBullet
        body.contactTestBitMask = PhysicsCategory.Static | PhysicsCategory.Mario
        body.collisionBitMask   = PhysicsCategory.Static
        body.restitution = 0.0
        body.friction = 1.0
        
        physicsBody = body
    }
    
    private static var sDeleteAction: SKAction!
    private var deleteAction: SKAction {
        get {
            if EBulletSprite.sDeleteAction == nil {
                let wait = SKAction.wait(forDuration: 0.25)
                let remove = SKAction.removeFromParent()
                EBulletSprite.sDeleteAction = SKAction.sequence([wait, remove])
            }
            
            return EBulletSprite.sDeleteAction
        }
    }
    
    private static var sRotateAction: SKAction!
    private var rotateAction: SKAction {
        get {
            if EBulletSprite.sRotateAction == nil {
                let rotate = SKAction.rotate(byAngle: π * 2.0, duration: 0.35)
                EBulletSprite.sRotateAction = SKAction.repeatForever(rotate)
            }
            
            return EBulletSprite.sRotateAction
        }
    }
}

extension EBulletSprite: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        if position.y < -self.size.height {
            removeFromParent()
            return
        }
    }
}

extension EBulletSprite: MarioShapeshifting {
    func marioWillShapeshift() {
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
        
        if !dead {
            removeAction(forKey: "rotation")
        }
    }
    
    func marioDidShapeshift() {
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
        
        if !dead {
            run(rotateAction, withKey: "rotation")
        }
    }
}
