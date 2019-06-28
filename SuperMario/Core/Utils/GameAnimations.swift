//
//  GameAnimations.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameAnimations {
    static let instance = GameAnimations()
    private init() {}
    
    private static var sFlyCoinAnimation: SKAction!
    private static var sFlyCoinTexType = ""
    var flyCoinAnimation: SKAction {
        get {
            if GameAnimations.sFlyCoinTexType != GameScene.currentTileType {
                let tmpAnimation = makeAnimation(texName: "flycoin", suffix: GameScene.currentTileType, count: 4, timePerFrame: 0.2/4, repeatForever: false)
                let vector = CGVector(dx: 0.0, dy: GameConstant.TileGridLength * (2.5 - 0.75))
                let moveByAction = SKAction.move(by: vector, duration: 0.2)
                let animAction = SKAction.repeat(tmpAnimation, count: 1)
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.2)
                let groupAction = SKAction.group([moveByAction, animAction, fadeOutAction])
                let removeAction = SKAction.removeFromParent()
                GameAnimations.sFlyCoinAnimation = SKAction.sequence([groupAction, removeAction])
            }
            
            return GameAnimations.sFlyCoinAnimation
        }
    }
    
    private static var sFlashAnimation: SKAction!
    var flashAnimation: SKAction {
        get {
            if GameAnimations.sFlashAnimation == nil {
                let fadeOut = SKAction.fadeOut(withDuration: GameConstant.marioFlashTimeUnit)
                let fadeIn  = fadeOut.reversed()
                GameAnimations.sFlashAnimation = SKAction.sequence([fadeOut, fadeIn])
            }
            
            return GameAnimations.sFlashAnimation
        }
    }
    
    private static var sVanishAnimation: SKAction!
    var vanishAnimation: SKAction {
        get {
            if GameAnimations.sVanishAnimation == nil {
                let fadeOut = SKAction.fadeOut(withDuration: 0.25)
                let remove  = SKAction.removeFromParent()
                GameAnimations.sVanishAnimation = SKAction.sequence([fadeOut, remove])
            }
            
            return GameAnimations.sVanishAnimation
        }
    }
    
    private static var sFlyScoreAnimation: SKAction!
    var flyScoreAnimation: SKAction {
        get {
            if GameAnimations.sFlyScoreAnimation == nil {
                let upDir = CGVector(dx: 0.0, dy: GameConstant.TileGridLength * 2.5)
                let moveBy = SKAction.move(by: upDir, duration: 0.5)
                let wait = SKAction.wait(forDuration: 0.25)
                let fadeOut = SKAction.fadeOut(withDuration: 0.25)
                let fadeSquence = SKAction.sequence([wait, fadeOut])
                let group = SKAction.group([moveBy, fadeSquence])
                let remove = SKAction.removeFromParent()
                GameAnimations.sFlyScoreAnimation = SKAction.sequence([group, remove])
            }
            
            return GameAnimations.sFlyScoreAnimation
        }
    }
}
