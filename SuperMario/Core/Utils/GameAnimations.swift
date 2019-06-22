//
//  GameAnimations.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameAnimations {
    private init() {}
    
    private static var solidAnimationCreated = false
    static var goldmAnimation: SKAction       = SKAction()
    static var flyCoinAnimation: SKAction     = SKAction()
    static var brickShakeAnimation: SKAction  = SKAction()
    static var marioFlashAnimation: SKAction  = SKAction()
    static var vanishAnimation: SKAction      = SKAction()
    static var bulletAnimation: SKAction      = SKAction()
    static var bulletFlashAnimation: SKAction = SKAction()
    
    static func updateGoldAnimation(_ suffix: String) {
        let texFileName1 = "goldm" + suffix + "_1"
        let tex1 = SKTexture(imageNamed: texFileName1)
        
        let texFileName2 = "goldm" + suffix + "_2"
        let tex2 = SKTexture(imageNamed: texFileName2)
        
        let texFileName3 = "goldm" + suffix + "_3"
        let tex3 = SKTexture(imageNamed: texFileName3)
        
        goldmAnimation = SKAction.repeatForever(SKAction.animate(with: [tex1, tex2, tex3], timePerFrame: 0.5))
    }
    
    static func updateFlyCoinAnimation(_ suffix: String) {
        let texFileName1 = "flycoin" + suffix + "_1"
        let tex1 = SKTexture(imageNamed: texFileName1)
        
        let texFileName2 = "flycoin" + suffix + "_2"
        let tex2 = SKTexture(imageNamed: texFileName2)
        
        let texFileName3 = "flycoin" + suffix + "_3"
        let tex3 = SKTexture(imageNamed: texFileName3)
        
        let texFileName4 = "flycoin" + suffix + "_4"
        let tex4 = SKTexture(imageNamed: texFileName4)
        
        let flyAnimation = SKAction.animate(with: [tex4, tex3, tex2, tex1], timePerFrame: 0.2 / 4)
        
        let vector = CGVector(dx: 0.0, dy: GameConstant.TileGridLength * (2.5 - 0.75))
        let moveByAction = SKAction.move(by: vector, duration: 0.2)
        let animAction = SKAction.repeat(flyAnimation, count: 1)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.2)
        let groupAction = SKAction.group([moveByAction, animAction, fadeOutAction])
        let removeAction = SKAction.removeFromParent()
        flyCoinAnimation = SKAction.sequence([groupAction, removeAction])
    }
    
    static func updateBrickShakeAnimation() {
        let vector = CGVector(dx: 0.0, dy: GameConstant.TileGridLength * 0.2)
        let moveByAction = SKAction.move(by: vector, duration: 0.075)
        moveByAction.timingMode = .easeOut
        let reverseAction = moveByAction.reversed()
        reverseAction.timingMode = .easeIn
        brickShakeAnimation = SKAction.sequence([moveByAction, reverseAction])
    }
    
    static func updateMarioFlashAnimation() {
        let fadeOut = SKAction.fadeOut(withDuration: GameConstant.marioFlashTimeUnit)
        let fadeIn  = fadeOut.reversed()
        marioFlashAnimation = SKAction.sequence([fadeOut, fadeIn])
    }
    
    static func updateVanishAnimation() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let remove  = SKAction.removeFromParent()
        vanishAnimation = SKAction.sequence([fadeOut, remove])
    }
    
    static func updateBulletAnimation() {
        let tex1 = SKTexture(imageNamed: "fire_bullet_1")
        let tex2 = SKTexture(imageNamed: "fire_bullet_2")
        let tex3 = SKTexture(imageNamed: "fire_bullet_3")
        let tex4 = SKTexture(imageNamed: "fire_bullet_4")
        
        bulletAnimation = SKAction.animate(with: [tex1, tex2, tex3, tex4], timePerFrame: 0.1)
    }
    
    static func updateBulletFlashAnimation() {
        let scaleExpand = SKAction.scale(to: 1.25, duration: 0.075)
        scaleExpand.timingMode = .easeIn
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.025)
        fadeOutAction.timingMode = .easeOut
        
        let removeAction = SKAction.removeFromParent()
        
        bulletFlashAnimation = SKAction.sequence([scaleExpand, fadeOutAction, removeAction])
    }
    
    static func updateStoredAnimations(_ suffix: String) {
        updateGoldAnimation(suffix)
        updateFlyCoinAnimation(suffix)
        
        if solidAnimationCreated == false {
            updateBrickShakeAnimation()
            updateMarioFlashAnimation()
            updateVanishAnimation()
            updateBulletAnimation()
            updateBulletFlashAnimation()
            
            solidAnimationCreated = true
        }
        
    }
}
