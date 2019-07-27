//
//  RotateFireballs.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class RotateFireballs: SKNode {
    static var sFireBalls: UIImage!
    
    let fireBalls: SKSpriteNode
    let rotateSpeed: CGFloat = π * 2 / 2.5
    var marioShapeshift: Bool = false
    private var fireBallCount: Int = 6
    
    init(startAngle: CGFloat) {
        if RotateFireballs.sFireBalls == nil {
            RotateFireballs.sFireBalls = makeRepeatGridImage(imageName: "fire_bullet_4", count: 6)
        }
        
        let tex = SKTexture(image: RotateFireballs.sFireBalls)
        fireBalls = SKSpriteNode(texture: tex)
        super.init()
        
        fireBalls.anchorPoint = CGPoint(x: 0.5 / CGFloat(fireBallCount), y: 0.5)
        fireBalls.zRotation = startAngle
        addChild(fireBalls)
        
        makePhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contactWithMario() {
        if !GameManager.instance.mario.powerfull {
            GameManager.instance.mario.collideWithEnemy()
        }
    }
    
    // MARK: Helper Stuff
    
    private func makePhysicsBody() {
        var ballBodies: Array<SKPhysicsBody> = []
        var x: CGFloat = 0.0
        for _ in 1...fireBallCount {
            let center = CGPoint(x: x, y: 0.0)
            let body = SKPhysicsBody(circleOfRadius: 4, center: center)
            ballBodies.append(body)
            
            x += 8
        }

        let body = SKPhysicsBody(bodies: ballBodies)
        body.categoryBitMask    = PhysicsCategory.EPirhana
        body.contactTestBitMask = PhysicsCategory.Mario
        body.collisionBitMask   = PhysicsCategory.None
        body.restitution = 0.0
        body.friction = 1.0
        body.isDynamic = false
        
        fireBalls.physicsBody = body
    }
}

extension RotateFireballs: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        guard !marioShapeshift else { return }
        
        fireBalls.zRotation -= (rotateSpeed * dt)
    }
}

extension RotateFireballs: MarioShapeshifting {
    func marioWillShapeshift() {
        self.marioShapeshift = true
    }
    
    func marioDidShapeshift() {
        self.marioShapeshift = false
    }
}
