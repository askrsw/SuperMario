//
//  CoinSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/23.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class CoinSprite: SKSpriteNode {
    let type: FragileGridType
    
    init(_ type: FragileGridType) {
        self.type = type
        
        let texFileName = "coin" + type.rawValue + "_1"
        let tex = SKTexture(imageNamed: texFileName)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        let rect = CGRect(x: -size.width * 0.4, y: -size.height * 0.5, width: size.width * 0.8, height: size.height)
        let path = UIBezierPath(ovalIn: rect)
        physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
        physicsBody!.isDynamic = false
        physicsBody!.categoryBitMask = PhysicsCategory.Coin
        physicsBody!.collisionBitMask = PhysicsCategory.None
        
        self.run(animation, withKey: "animation")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Animation Stuff
    
    private static var sAnimation: SKAction!
    private static var sTexType = ""
    var animation: SKAction {
        get {
            if CoinSprite.sTexType != GameScene.currentTileType {
                CoinSprite.sAnimation = makeAnimation(texName: "coin", suffix: GameScene.currentTileType, count: 4, timePerFrame: 0.5)
                CoinSprite.sTexType = GameScene.currentTileType
            }
            
            return CoinSprite.sAnimation
        }
    }
}

extension CoinSprite: MarioBumpFragileNode {
    func marioBump() {
        self.removeAllActions()
        self.physicsBody = nil
        self.run(GameAnimations.instance.vanishAnimation)
        
        AudioManager.play(sound: .Coin)
    }
}

extension CoinSprite: MarioShapeshifting {
    func marioWillShapeshift() {
        self.removeAction(forKey: "animation")
    }
    
    func marioDidShapeshift() {
        self.run(animation, withKey: "animation")
    }
}

