//
//  BrickSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class BrickSprite : SKSpriteNode {
    
    init(_ type: FragileGridType) {
        let texFileName = "brick" + type.rawValue
        let tex = SKTexture(imageNamed: texFileName)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        physicsBody = SKPhysicsBody(rectangleOf: tex.size())
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.Brick
        physicsBody!.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
}

extension BrickSprite: MarioBumpFragileNode {
    func marioBump() {
        print("mario bump brick")
    }
}
