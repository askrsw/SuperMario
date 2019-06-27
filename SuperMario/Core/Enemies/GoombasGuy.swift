//
//  GoombasGuy.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/24.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GoombasGuy: EnemiesBaseNode {
    
    override var speedX: CGFloat {
        get {
            return 50.0
        }
    }
    
    override var shouldMirrorY: Bool {
        get {
            return true
        }
    }
    
    override var physicalShapeParam: PhysicalShapeParam {
        get {
            let pSize = CGSize(width: 16, height: 14)
            let pCenter = CGPoint(x: 0, y: 1)
            return PhysicalShapeParam(size: pSize, center: pCenter)
        }
    }
    
    override func isBeingSteppedOn(_ point: CGPoint) -> Bool {
        if point.y > self.size.height * 0.25 {
            return true
        } else {
            return false
        }
    }
    
    override func beSteppedOn() {
        let deadTexFileName = "goombas" + GameScene.currentTileType + "_3"
        let deadTex = SKTexture(imageNamed: deadTexFileName)
        self.texture = deadTex
        self.size = deadTex.size()
        
        let physicalSize = CGSize(width: size.width, height: size.height * 0.5)
        let physicalCenter = CGPoint(x: 0.0, y: size.height * -0.25)
        self.physicsBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        self.physicsBody!.categoryBitMask = PhysicsCategory.None
        self.physicsBody!.contactTestBitMask = PhysicsCategory.None
        self.physicsBody!.collisionBitMask = PhysicsCategory.Static
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.friction = 1.0
        self.removeAllActions()
        
        AudioManager.play(sound: .TreadEvil)
        
        self.run(flaserDeathAction)
    }
    
    override func update(deltaTime dt: CGFloat) {
        super.update(deltaTime: dt)
        //removeFromParent()
    }
    
    // MARK: Animation Stuff
    
    private static var sFlaserDeathAction: SKAction?
    private var flaserDeathAction: SKAction {
        get {
            if GoombasGuy.sFlaserDeathAction == nil {
                let wait = SKAction.wait(forDuration: 1.0)
                let fadeOut = SKAction.fadeOut(withDuration: 1.0)
                let remove = SKAction.removeFromParent()
                GoombasGuy.sFlaserDeathAction = SKAction.sequence([wait, fadeOut, remove])
            }
            
            return GoombasGuy.sFlaserDeathAction!
        }
    }
    
    private static var sTexType = ""
    private static var sAnimation: SKAction!
    override var animation: SKAction {
        get {
            if GoombasGuy.sTexType != GameScene.currentTileType {
                GoombasGuy.sAnimation = makeAnimation(texName: "goombas", suffix: GameScene.currentTileType, count: 2, timePerFrame: 0.3)
                GoombasGuy.sTexType = GameScene.currentTileType
            }
            
            return GoombasGuy.sAnimation
        }
    }
}
