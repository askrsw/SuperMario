//
//  GameScene+Static.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/28.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene {
    static var soundPlayNode: SKNode {
        get {
            return currentInstance!.soundPlayNode
        }
    }
    
    static var physicsWorld: SKPhysicsWorld {
        get {
            return currentInstance!.physicsWorld
        }
    }
    
    static var rootNode: SKNode {
        get {
            return currentInstance!.rootNode
        }
    }
    
    static var currentTileType: String {
        get {
            return currentInstance!.tileType
        }
    }
    
    static var halfCameraViewWidth: CGFloat {
        get {
            return currentInstance!.halfCameraViewWidth
        }
    }
    
    static var halfScaledSceneWdith: CGFloat {
        get {
            return currentInstance!.halfScaledSceneWdith
        }
    }
    
    static var camera: SKCameraNode {
        get {
            return currentInstance!.camera!
        }
    }
    
    static func checkRectForShake(rect: CGRect) {
        currentInstance!.checkRectForShake(rect: rect)
    }
    
    static func ErasePlatNode(_ pos: CGPoint, _ index: Int) {
        currentInstance!.ErasePlatNode(pos, index)
    }

    static func addBullet(_ bullet: BulletSprite) {
        currentInstance!.bulletSpriteHolder.addChild(bullet)
    }
    
    static func addStar(_ star: SKNode) {
        currentInstance!.movingSpriteHolder.addChild(star)
    }
    
    static func addBrickPiece(_ piece: BrickPieceSprite) {
        currentInstance!.movingSpriteHolder.addChild(piece)
    }
    
    static func addMushroom(_ mushroom: SKNode) {
        currentInstance!.movingSpriteHolder.addChild(mushroom)
    }
    
    static func addFlower(_ flower: SKNode) {
        currentInstance!.staticSpriteHolder.addChild(flower)
    }
    
    static func marioWillShapeshift() {
        currentInstance!.marioWillShapeshift()
    }
    
    static func marioDidShapeshift() {
       currentInstance!.marioDidShapeshift()
    }
    
    static func playBackgroundMusc(_ rapid: Bool = false, _ remainRatio: Bool = false) {
        currentInstance!.playBackgroundMusc(rapid, remainRatio)
    }
    
    static func marioIsPowerfull() {
        currentInstance!.marioIsPowerfull()
    }
    
    static func addScore(score: Int, pos: CGPoint) {
        currentInstance!.addScore(score: score, pos: pos)
    }
    
    static func setTileTypeDictionary(index: Int, type: TileGridType) {
        guard currentInstance!.verticalPhysicsLine else { return }
        
        if type == .None {
            currentInstance!.tileTypeDict.removeValue(forKey: index)
        } else {
            currentInstance!.tileTypeDict[index] = type
        }
    }
}
