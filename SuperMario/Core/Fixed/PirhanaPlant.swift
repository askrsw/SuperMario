//
//  PirhanaPlant.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/4.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

fileprivate enum PirhanaMoveState {
    case sleep
    case moveUp
    case moveDown
    case show
    case dead
}

class PirhanaPlant: SKNode {
    let tileType: String
    let cropNode = SKCropNode()
    let pirhanaNode: SKSpriteNode
    
    let xStart: CGFloat
    let xEnd: CGFloat
    let speedY: CGFloat = 8.0
    let maxSleepTime: CGFloat = 3.0
    let maxShowTime: CGFloat = 1.0
    
    var active: Bool = false {
        didSet {
            if oldValue == active {
                return
            }
            
            if active {
                pirhanaNode.run(animation, withKey: "animation")
            } else {
                pirhanaNode.removeAction(forKey: "animation")
            }
        }
    }
    
    fileprivate var moveState: PirhanaMoveState = .sleep
    var sleepTime: CGFloat = 0.0
    var showTime: CGFloat = 0.0
    var marioShapeshift: Bool = false
    
    init(tileType: String, xStart: CGFloat, xEnd: CGFloat) {
        self.tileType = tileType
        self.xStart = xStart * GameConstant.TileGridLength
        self.xEnd   = xEnd * GameConstant.TileGridLength
        
        let texFileName = "pirhana" + tileType + "_1"
        let tex = SKTexture(imageNamed: texFileName)
        pirhanaNode = SKSpriteNode(texture: tex)
        super.init()
        
        let maskNode = SKShapeNode(rectOf: tex.size())
        maskNode.fillColor = SKColor.white
        maskNode.position = CGPoint(x: 0.0, y: tex.size().height * 0.5)
        cropNode.maskNode = maskNode
        cropNode.addChild(pirhanaNode)
        
        let physicsSize = CGSize(width: tex.size().width, height: tex.size().height)
        let physicsCenter = CGPoint(x: 0.0, y: physicsSize.height * 0.5)
        pirhanaNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        pirhanaNode.position = CGPoint(x: 0.0, y: -tex.size().height)
        pirhanaNode.physicsBody = SKPhysicsBody(rectangleOf: physicsSize, center: physicsCenter)
        pirhanaNode.physicsBody!.categoryBitMask = PhysicsCategory.EPirhana
        pirhanaNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        pirhanaNode.physicsBody!.contactTestBitMask = PhysicsCategory.Mario | PhysicsCategory.MBullet
        pirhanaNode.physicsBody!.isDynamic = false
        
        self.addChild(cropNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contactWithMario() {
        if GameManager.instance.mario.powerfull {
            _ = hitByBullet()
        } else {
            guard moveState != .sleep else { return }
            GameManager.instance.mario.collideWithEnemy()
        }
    }
    
    func hitByBullet() -> Bool {
        guard moveState != .sleep else { return false }
        
        moveState = .dead
        GameScene.addScore(score: ScoreConfig.treadGoombas, pos: position)
        
        pirhanaNode.physicsBody = nil
        pirhanaNode.removeAllActions()
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.125)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([fadeOut, remove]))
        
        return true
    }
    
    // MARK: Help method
    
    private static var sTexType = ""
    private static var sAnimation: SKAction!
    var animation: SKAction {
        get {
            if PirhanaPlant.sTexType != tileType {
                PirhanaPlant.sAnimation = makeAnimation(texName: "pirhana", suffix: tileType, count: 2, timePerFrame: 0.5)
                PirhanaPlant.sTexType = tileType
            }
            
            return PirhanaPlant.sAnimation
        }
    }
}

extension PirhanaPlant: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        if (xStart < 0.0 || GameManager.instance.mario.posX > (xStart - GameScene.halfScaledSceneWdith)) && (xEnd < 0.0 || GameManager.instance.mario.posX < (xEnd + GameScene.halfScaledSceneWdith)) {
            active = true
        } else {
            active = false
        }
        
        guard active else { return }
        guard dt < 0.25 else { return }
        guard !marioShapeshift else { return }
        
        switch moveState {
        case .sleep:
            sleepTime -= dt
            let unitL = GameConstant.TileGridLength
            let mPosX = GameManager.instance.mario.posX
            let mPosRight = mPosX + unitL * 0.5
            let mPosLeft  = mPosX - unitL * 0.5
            if mPosRight < position.x - unitL || mPosLeft > position.x + unitL {
                if sleepTime < 0.0 {
                    moveState = .moveUp
                }
            }
        case .moveUp:
            pirhanaNode.position.y += ( speedY * dt)
            if pirhanaNode.position.y > 0.0 {
                pirhanaNode.position.y = 0.0
                moveState = .show
                showTime = maxShowTime
            }
        case .show:
            showTime -= dt
            if showTime < 0.0 {
                moveState = .moveDown
            }
        case .moveDown:
            pirhanaNode.position.y -= (speedY * dt)
            if pirhanaNode.position.y < -pirhanaNode.size.height {
                pirhanaNode.position.y = -pirhanaNode.size.height
                moveState = .sleep
                sleepTime = maxSleepTime
            }
        case .dead:
            break
        }
    }
}

extension PirhanaPlant: MarioShapeshifting {
    func marioWillShapeshift() {
        self.removeAction(forKey: "animation")
        self.marioShapeshift = true
    }
    
    func marioDidShapeshift() {
        self.run(self.animation, withKey: "animation")
        self.marioShapeshift = false
    }
}
