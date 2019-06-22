//
//  BrickSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class BrickSprite : SKSpriteNode {
    
    let type: FragileGridType
    let tileName: String
    
    init(_ type: FragileGridType, _ tileName: String) {
        self.type = type
        self.tileName = tileName
        
        let texFileName = "brick" + type.rawValue
        let tex = SKTexture(imageNamed: texFileName)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        let physicalSize = CGSize(width: tex.size().width, height: tex.size().height - 0.1)
        let physicalCenter = CGPoint(x: 0.0, y: -0.1 / 2.0)
        physicsBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.Brick
        physicsBody!.collisionBitMask = physicsBody!.collisionBitMask & ~(PhysicsCategory.erasablePlat)
        physicsBody!.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
}

extension BrickSprite: MarioBumpFragileNode {
    func marioBump() {
        if GameManager.instance.mario.marioPower != .A {
            removeFromParent()
            AudioManager.play(sound: .BreakBrick)
            let position = CGPoint(x: self.position.x, y: self.position.y - GameConstant.TileGridLength * 0.5)
            let _ = BrickPieceSprite.spawnPieceGroup(self.type, position)
            
            if let scene = GameManager.instance.currentScene {
                scene.ErasePlatNode(self.position)
            }
        } else {
            self.run(GameAnimations.brickShakeAnimation)
            AudioManager.play(sound: .HitHard)
        }
    }
}
