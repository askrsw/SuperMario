//
//  StarSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/22.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class StarSprite: SKSpriteNode {
    let type: FragileGridType
    let animation: SKAction
    let cropNode = SKCropNode()
    
    var growing: Bool = true
    var velocityX: CGFloat = 100.0
    
    init(_ type: FragileGridType) {
        self.type = type
        
        let texFileName1 = "star" + type.rawValue + "_1"
        let tex1 = SKTexture(imageNamed: texFileName1)
        
        let texFileName2 = "star" + type.rawValue + "_2"
        let tex2 = SKTexture(imageNamed: texFileName2)
        
        let texFileName3 = "star" + type.rawValue + "_3"
        let tex3 = SKTexture(imageNamed: texFileName3)
        
        let texFileName4 = "star" + type.rawValue + "_4"
        let tex4 = SKTexture(imageNamed: texFileName4)
        let animAction = SKAction.animate(with: [tex1, tex2, tex3, tex4], timePerFrame: 0.25)
        self.animation = SKAction.repeatForever(animAction)
        
        super.init(texture: tex1, color: SKColor.clear, size: tex1.size())
        
        let maskNode = SKShapeNode(rectOf: tex1.size())
        maskNode.fillColor = SKColor.white
        cropNode.maskNode = maskNode
        cropNode.addChild(self)
        self.position = CGPoint(x: 0.0, y: -tex1.size().height)
        
        let moveToAction  = SKAction.move(to: .zero, duration: 0.5)
        let spawnedAction = SKAction.run { [weak self] in
            self?.finishSpawn()
        }
        self.run(SKAction.sequence([moveToAction, spawnedAction]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fallToGround() {
        guard let physicsBody = physicsBody else { return }
        let verticalForce = physicsBody.mass * 320.0
        physicsBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
    
    // MARK: Help method
    
    private func finishSpawn() {
        physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2 - 1.0)
        physicsBody!.allowsRotation = false
        physicsBody!.friction    = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.MarioPower
        physicsBody!.contactTestBitMask = PhysicsCategory.Solid | PhysicsCategory.Brick | PhysicsCategory.GoldMetal
        physicsBody!.collisionBitMask = PhysicsCategory.Solid | PhysicsCategory.Brick | PhysicsCategory.GoldMetal | PhysicsCategory.erasablePlat
        
        self.move(toParent: self.cropNode.parent!)
        self.cropNode.removeFromParent()
        
        self.run(self.animation)
        
        self.growing = false
    }
}

extension StarSprite: MarioBumpFragileNode {
    func marioBump() {
        self.removeAllActions()
        self.physicsBody = nil
        self.run(GameAnimations.instance.vanishAnimation)
        
        GameManager.instance.mario.powerfull = true
    }
}

extension StarSprite: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        if let physicsBody = physicsBody {
            physicsBody.velocity = CGVector(dx: velocityX, dy: physicsBody.velocity.dy)
        }
            
        if position.y < -self.size.height {
            removeFromParent()
        }
    }
}

extension StarSprite: SpriteReverseMovement {
    func reverseMovement(_ direction: CGVector) {
        if direction.dx > 0.1 {
            velocityX = 100.0
        } else if direction.dx < -0.1 {
            velocityX = -100.0
        }
    }
}
