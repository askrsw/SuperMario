//
//  MushroomSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/13.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class MushroomSprite: SKSpriteNode {
    let type: FragileGridType
    let isLifeMushroom: Bool
    let cropNode = SKCropNode()
    let animation: SKAction
    
    var growing: Bool = true
    var velocityX: CGFloat = 110.0
    var backup_physicsBody: SKPhysicsBody?
    
    init(_ type: FragileGridType, _ addLife: Bool) {
        self.type = type
        self.isLifeMushroom = addLife
        
        let wordRoot = "mushroom" + (self.isLifeMushroom ? "_life" : "")
        
        let texFileName1 = wordRoot + self.type.rawValue + "_1"
        let tex1 = SKTexture(imageNamed: texFileName1)
        
        let texFileName2 = wordRoot + self.type.rawValue + "_2"
        let tex2 = SKTexture(imageNamed: texFileName2)
        
        let animAction = SKAction.animate(with: [tex1, tex2], timePerFrame: 0.25)
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
    
    func finishSpawn() {
        let physicalCenter = CGPoint(x: 0.0, y: 1.0 / 2)
        var physicalSize = self.texture!.size()
        physicalSize.height -= 1.0
        
        physicsBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        physicsBody!.allowsRotation = false
        physicsBody!.friction    = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.MarioPower
        physicsBody!.contactTestBitMask = PhysicsCategory.Static
        physicsBody!.collisionBitMask = PhysicsCategory.Static | PhysicsCategory.ErasablePlat
        
        self.move(toParent: self.cropNode.parent!)
        self.cropNode.removeFromParent()
        
        self.run(self.animation, withKey: "animation")
        
        self.growing = false
    }
}

extension MushroomSprite: MarioBumpFragileNode {
    func marioBump() {
        self.removeAllActions()
        self.physicsBody = nil
        self.run(GameAnimations.instance.vanishAnimation)
        
        GameScene.addScore(score: ScoreConfig.hitPowerup, pos: position)
        
        if self.isLifeMushroom == false {
            GameManager.instance.mario.powerUpToB()
        } else {
            GameHUD.instance.marioLifeCount += 1
            AudioManager.play(sound: .AddLife)
        }
    }
}

extension MushroomSprite: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        if let physicsBody = physicsBody {
            physicsBody.velocity = CGVector(dx: velocityX, dy: physicsBody.velocity.dy)
        }
        
        if position.y < -self.size.height {
            removeFromParent()
        }
    }
}

extension MushroomSprite: SpriteReverseMovement {
    func reverseMovement(_ direction: CGVector) {
        if direction.dx > 0.1 {
            velocityX = 80.0
        } else if direction.dx < -0.1 {
            velocityX = -80.0
        }
    }
}

extension MushroomSprite: MarioShapeshifting {
    func marioWillShapeshift() {
        self.removeAction(forKey: "animation")
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
    }
    
    func marioDidShapeshift() {
        self.run(self.animation, withKey: "animation")
        (backup_physicsBody, physicsBody) = (physicsBody, backup_physicsBody)
    }
}
