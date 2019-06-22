//
//  FlowerSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/13.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class FlowerSprite: SKSpriteNode {
    let type: FragileGridType
    let cropNode = SKCropNode()
    let animation: SKAction
    
    var growing: Bool = true
    
    init(_ type: FragileGridType) {
        self.type = type
        
        let texFileName1 = "flower" + type.rawValue + "_1"
        let tex1 = SKTexture(imageNamed: texFileName1)
        
        let texFileName2 = "flower" + type.rawValue + "_2"
        let tex2 = SKTexture(imageNamed: texFileName2)
        
        let texFileName3 = "flower" + type.rawValue + "_3"
        let tex3 = SKTexture(imageNamed: texFileName3)
        
        let texFileName4 = "flower" + type.rawValue + "_4"
        let tex4 = SKTexture(imageNamed: texFileName4)
        
        let animAction = SKAction.animate(with: [tex1, tex2, tex3, tex4], timePerFrame: 0.2)
        let animCountAction = SKAction.repeat(animAction, count: 15)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
        let fadeInAction  = SKAction.fadeIn(withDuration: 0.1)
        let flashAction = SKAction.sequence([fadeOutAction, fadeInAction])
        let flahCountAction = SKAction.repeat(flashAction, count: 20)
        let waitAction = SKAction.wait(forDuration: 8.0)
        let squeneFlashAction = SKAction.sequence([waitAction, flahCountAction])
        let groupAction = SKAction.group([animCountAction, squeneFlashAction])
        let removeAction = SKAction.removeFromParent()
        self.animation = SKAction.sequence([groupAction, removeAction])
        
        super.init(texture: tex1, color: SKColor.clear, size: tex1.size())
        
        let maskNode = SKShapeNode(rectOf: tex1.size())
        maskNode.fillColor = SKColor.white
        cropNode.maskNode = maskNode
        cropNode.addChild(self)
        self.position = CGPoint(x: 0.0, y: -tex1.size().height)
        
        let moveToAction = SKAction.move(to: .zero, duration: 0.5)
        let spawnedAction = SKAction.run { [weak self] in
            self?.finishSpawn()
        }
        
        self.run(SKAction.sequence([moveToAction, spawnedAction]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func finishSpawn() {
        physicsBody = SKPhysicsBody(rectangleOf: self.size)
        physicsBody!.categoryBitMask = PhysicsCategory.MarioPower
        physicsBody!.isDynamic = false
        
        self.move(toParent: self.cropNode.parent!)
        self.cropNode.removeFromParent()
        
        self.run(self.animation)
        
        self.growing = false
    }
}

extension FlowerSprite: MarioBumpFragileNode {
    func marioBump() {
        self.removeAllActions()
        self.physicsBody = nil
        self.run(GameAnimations.vanishAnimation)
        
        GameManager.instance.mario.powerUpToC()
    }
}
