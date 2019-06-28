//
//  BulletSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/17.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class BulletSprite: SKSpriteNode {
    
    let velocityX: CGFloat
    var backup_physicsBody: SKPhysicsBody?
    
    init(faceTo dir: MarioFacing, marioPos pos: CGPoint) {
        velocityX = 260.0 * dir.rawValue
        
        let tex = SKTexture(imageNamed: "fire_bullet_1")
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        run(animation, withKey: "animation")
        
        let unitL = GameConstant.TileGridLength
        if dir == .forward {
            let x = pos.x + unitL * 0.25
            let y = pos.y + unitL * 0.45
            position = CGPoint(x: x, y: y)
        } else {
            let x = pos.x - unitL * 0.25
            let y = pos.y + unitL * 0.45
            position = CGPoint(x: x, y: y)
        }
        
        zPosition = GameManager.instance.mario.zPosition + 1
        
        makePhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hitSolidPhysicsBody() {
        AudioManager.play(sound: .HitHard)
        
        let xDiff: CGFloat = size.width * 0.5 * velocityX.sign()
        let flashSprite = SKSpriteNode(imageNamed: "bullet_flash")
        flashSprite.zPosition = zPosition
        flashSprite.position  = CGPoint(x: position.x + xDiff, y: position.y)
        flashSprite.run(flashAnimation)
        parent!.addChild(flashSprite)
        
        removeFromParent()
    }
    
    func hitEnemy() {
        removeFromParent()
        
        AudioManager.play(sound: .FireHitEvil)
    }
    
    func fallToGround() {
        guard let physicsBody = physicsBody else { return }
        let verticalForce = physicsBody.mass * 240.0
        physicsBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
    
    // MARK: Animation Stuff
    
    private static var sAnimation: SKAction!
    var animation: SKAction {
        get {
            if BulletSprite.sAnimation == nil {
                BulletSprite.sAnimation = makeAnimation(texName: "fire_bullet", suffix: "", count: 4, timePerFrame: 0.05)
            }
            
            return BulletSprite.sAnimation
        }
    }
    
    private static var sFlashAnimation: SKAction!
    var flashAnimation: SKAction {
        get {
            if BulletSprite.sFlashAnimation == nil {
                let scaleExpand = SKAction.scale(to: 1.25, duration: 0.075)
                scaleExpand.timingMode = .easeIn
                
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.025)
                fadeOutAction.timingMode = .easeOut
                
                let removeAction = SKAction.removeFromParent()
                
                BulletSprite.sFlashAnimation = SKAction.sequence([scaleExpand, fadeOutAction, removeAction])
            }
            
            return BulletSprite.sFlashAnimation
        }
    }
    
    // MARK: Helper Method
    
    private func makePhysicsBody( ) {
        physicsBody = SKPhysicsBody(circleOfRadius: self.size.width * 0.5)
        physicsBody!.categoryBitMask = PhysicsCategory.MBullet
        physicsBody!.contactTestBitMask = PhysicsCategory.Static
        physicsBody!.collisionBitMask = PhysicsCategory.Static | PhysicsCategory.ErasablePlat
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 0.0
    }
}

extension BulletSprite: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        if let physicsBody = physicsBody {
            physicsBody.velocity = CGVector(dx: velocityX, dy: physicsBody.velocity.dy)
        }
        
        if position.y < -self.size.height {
            removeFromParent()
            return
        }
        
        if let parent = parent {
            let cameraPos = GameScene.camera.convert(position, from: parent)
            if abs(cameraPos.x) > GameScene.halfCameraViewWidth + size.width * 4 {
                removeFromParent()
            }
        }
    }
}

extension BulletSprite: MarioShapeshifting {
    func marioWillShapeshift() {
        self.removeAction(forKey: "animation")
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
    }
    
    func marioDidShapeshift() {
        self.run(self.animation, withKey: "animation")
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
    }
}

