//
//  GoldSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GoldSprite : SKSpriteNode {
    static private var animation: SKAction?
    
    init(_ type: FragileGridType) {
        let texFileName = "goldm" + type.rawValue + "_1"
        let tex = SKTexture(imageNamed: texFileName)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
            
        physicsBody = SKPhysicsBody(rectangleOf: tex.size())
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.GoldMetal
        physicsBody!.isDynamic = false
    
        self.run(GameAnimations.goldmAnimation)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
}

extension GoldSprite: MarioBumpFragileNode {
    func marioBump() {
        print("mario bump goldm")
    }
}
