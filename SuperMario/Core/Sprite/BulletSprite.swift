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
    
    init(faceTo dir: MarioFacing, marioPos pos: CGPoint) {
        velocityX = 260.0 * dir.rawValue
        
        let tex = SKTexture(imageNamed: "fire_bullet_1")
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        run(GameAnimations.bulletAnimation)
        
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
        flashSprite.run(GameAnimations.bulletFlashAnimation)
        parent!.addChild(flashSprite)
        
        removeFromParent()
    }
    
    func fallToGround() {
        guard let physicsBody = physicsBody else { return }
        let verticalForce = physicsBody.mass * 240.0
        physicsBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
    
    // MARK: Helper Method
    
    private func makePhysicsBody( ) {
        physicsBody = SKPhysicsBody(circleOfRadius: self.size.width * 0.5)
        physicsBody!.categoryBitMask = PhysicsCategory.MBullet
        physicsBody!.contactTestBitMask = PhysicsCategory.Brick | PhysicsCategory.Solid | PhysicsCategory.GoldMetal
        physicsBody!.collisionBitMask = PhysicsCategory.Solid | PhysicsCategory.Brick | PhysicsCategory.GoldMetal | PhysicsCategory.erasablePlat
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
            let scene = GameManager.instance.currentScene!
            let camera = scene.camera!
            let cameraPos = camera.convert(position, from: parent)
            
            if abs(cameraPos.x) > scene.halfCameraViewWidth + size.width * 4 {
                removeFromParent()
            }
        }
    }
}
