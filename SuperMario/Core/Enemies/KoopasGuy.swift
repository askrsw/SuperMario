//
//  KoopasGuy.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/27.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

enum KoopasState: Int {
    case normal
    case stillShell
    case movingShell
    case fly
}

class KoopasGuy: EnemiesBaseNode {
    
    var state: KoopasState = .normal
    
    override var speedX: CGFloat {
        get {
            switch state {
            case .normal:
                return 50.0
            case .stillShell:
                return 0.0
            case .movingShell:
                return 150.0
            case .fly:
                return 0.0
            }
        }
    }
    
    override var shouldMirrorY: Bool {
        get {
            return true
        }
    }
    
    override var physicalShapeParam: PhysicalShapeParam {
        get {
            let pSize = CGSize(width: 16, height: 13)
            let pCenter = CGPoint(x: 0, y: 0.5)
            return PhysicalShapeParam(size: pSize, center: pCenter)
        }
    }
    
    override func isBeingSteppedOn(_ point: CGPoint) -> Bool {
        if point.y > 4 {
            return true
        } else {
            return false
        }
    }
    
    override func beSteppedOn() {
        switch state {
        case .normal:
            shapeShiftToStillShell()
            GameScene.addScore(score: ScoreConfig.treadNormalKoopas, pos: position)
        case .stillShell:
            shapeshiftToMovingShell()
            GameScene.addScore(score: ScoreConfig.treadStillKoopas, pos: position)
        case .movingShell:
            shapeShiftToStillShell()
            GameScene.addScore(score: ScoreConfig.treadMovingKoopas, pos: position)
        case .fly:
            break
        }
    }
    
    override func postPhysicsProcess() {
        if state != .stillShell && state != .fly {
            super.postPhysicsProcess()
        }
    }
    
    override func beforeKilledByBullet() {
        super.beforeKilledByBullet()
        
        let texName = "koopas" + texType + "_5"
        let tex = SKTexture(imageNamed: texName)
        self.texture = tex
        self.size = tex.size()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    // MARK: Help method
    
    private func shapeshiftToMovingShell() {
        let texFileName = "koopas" + texType + "_5"
        let tex = SKTexture(imageNamed: texFileName)
        self.texture = tex
        self.faceLeft = true    // a joke, you must set this value with reverse
        
        physicsBody!.categoryBitMask  = PhysicsCategory.EShell
        physicsBody!.collisionBitMask = PhysicsCategory.Static | PhysicsCategory.ErasablePlat
        physicsBody!.contactTestBitMask = PhysicsCategory.Mario | PhysicsCategory.MBullet | PhysicsCategory.EShell | PhysicsCategory.Evildoer
        
        removeAllActions()
        
        state = .movingShell
    }
    
    private func shapeShiftToStillShell() {
        let texFileName = "koopas" + texType + "_5"
        let tex = SKTexture(imageNamed: texFileName)
        self.texture = tex
        self.size = tex.size()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        physicsBody!.categoryBitMask = PhysicsCategory.Evildoer
        physicsBody!.collisionBitMask = PhysicsCategory.Static | PhysicsCategory.ErasablePlat | PhysicsCategory.Evildoer
        physicsBody!.contactTestBitMask = PhysicsCategory.Mario | PhysicsCategory.MBullet | PhysicsCategory.Evildoer
        
        let wait = SKAction.wait(forDuration: 10.0)
        let block = SKAction.run { [weak self] in
            self?.shapeShiftToNormal()
        }
        let squence = SKAction.sequence([wait, block])
        
        removeAction(forKey: "animation")
        run(squence, withKey: "shapeShiftToNormal")
        
        state = .stillShell
    }
    
    private func shapeShiftToNormal() {
        let block = SKAction.run { [weak self] in
            let texFileName = "koopas" + (self?.texType ?? "_a") + "_1"
            let tex = SKTexture(imageNamed: texFileName)
            self?.texture = tex
            
            self?.size = tex.size()
            self?.anchorPoint = CGPoint(x: 0.5, y: 0.3333)
            self?.run((self?.animation)!, withKey: "animation")
            self?.state = .normal
        }
        let squence = SKAction.sequence([shellToNormalAnimation, block])
        run(squence, withKey: "shapeShiftingToNormal")
    }
    
    // MARK: Animation Stuff
    
    private static var sTexType = ""
    private static var sAnimation: SKAction!
    private static var sShellToNormalAnimation: SKAction!
    override var animation: SKAction {
        get {
            if KoopasGuy.sTexType != texType {
                KoopasGuy.sAnimation = makeAnimation(texName: "koopas", suffix: texType, count: 2, timePerFrame: 0.1)
                KoopasGuy.makeShellToNormalAnimation(texType)
                KoopasGuy.sTexType = texType
            }
            
            if alive {
                switch state {
                case .normal:
                    return KoopasGuy.sAnimation
                default:
                    break;
                }
            }
            
            return SKAction()
        }
    }
    
    var shellToNormalAnimation: SKAction {
        if KoopasGuy.sTexType != texType {
            KoopasGuy.sAnimation = makeAnimation(texName: "koopas", suffix: texType, count: 2, timePerFrame: 0.3)
            KoopasGuy.makeShellToNormalAnimation(texType)
            KoopasGuy.sTexType = texType
        }
        
        return KoopasGuy.sShellToNormalAnimation
    }
    
    private static func makeShellToNormalAnimation(_ texType: String) {
        let texName1 = "koopas" + texType + "_5"
        let tex1 = SKTexture(imageNamed: texName1)
        
        let texName2 = "koopas" + texType + "_6"
        let tex2 = SKTexture(imageNamed: texName2)
        
        let tAnimation = SKAction.animate(with: [tex1, tex2], timePerFrame: 0.15)
        sShellToNormalAnimation = SKAction.repeat(tAnimation, count: 10)
    }
}
