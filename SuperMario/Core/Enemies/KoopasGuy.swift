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
            let texFileName = "koopas" + texType + "_1"
            let tex = SKTexture(imageNamed: texFileName)
            self.texture = tex
            self.size = tex.size()
            self.flyCancelled = true
            self.physicsBody?.affectedByGravity = true
            self.removeAction(forKey: "animation")
        }
    }
    
    override func update(deltaTime dt: CGFloat) {
        guard state == .fly else {
            return super.update(deltaTime: dt)
        }
        
        guard active else {
            if xStart < 0.0 || GameManager.instance.mario.posX > (xStart - GameScene.halfScaledSceneWdith) {
                createPhysicsBody()
                active = true
            }
            
            return
        }
        
        if position.y < -self.size.height {
            removeFromParent()
            return
        }
        
        guard !flyCancelled else { return }
        
        if let physicsBody = physicsBody, physicsBody.categoryBitMask != PhysicsCategory.None {
            let velocityY: CGFloat = speedY * (self.downward ? -1.0 : 1.0)
            physicsBody.velocity = CGVector(dx: 0.0, dy: velocityY)
        }
    }
    
    override func createPhysicsBody() {
        super.createPhysicsBody()
        
        if state == .fly {
            physicsBody?.affectedByGravity = false
        }
    }
    
    override func postPhysicsProcess() {
        guard active else { return }
        
        if state != .stillShell && state != .fly {
            super.postPhysicsProcess()
        } else if state == .fly {
            if !flyCancelled {
                if position.y > maxY {
                    downward = true
                } else if position.y < minY {
                    downward = false
                }
            } else {
                if abs(physicsBody!.velocity.dy) < 1e-1 {
                    state = .normal
                    flyCancelled = false
                    self.run(animation, withKey: "animation")
                }
            }
        }
    }
    
    override func beforeKilledByBullet() {
        super.beforeKilledByBullet()
        
        let texName = "koopas" + texType + "_5"
        let tex = SKTexture(imageNamed: texName)
        self.texture = tex
        self.size = tex.size()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody?.affectedByGravity = true
    }
    
    var maxY: CGFloat!
    var minY: CGFloat!
    var flyCancelled: Bool = false
    let speedY: CGFloat = 40.0
    var downward: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let flying = userData?["flying"] as? Bool, flying {
            let maxY = userData!["maxY"] as! CGFloat
            let minY = userData!["minY"] as! CGFloat
            
            self.maxY = maxY * GameConstant.TileGridLength + GameConstant.TileYOffset
            self.minY = minY * GameConstant.TileGridLength + GameConstant.TileYOffset
            self.state = .fly
            
            run(animation, withKey: "animation")
        }
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
            self?.state = .normal
            let texFileName = "koopas" + (self?.texType ?? "_a") + "_1"
            let tex = SKTexture(imageNamed: texFileName)
            self?.texture = tex
            
            self?.size = tex.size()
            self?.anchorPoint = CGPoint(x: 0.5, y: 0.3333)
            self?.run((self?.animation)!, withKey: "animation")
        }
        let squence = SKAction.sequence([shellToNormalAnimation, block])
        run(squence, withKey: "shapeShiftingToNormal")
    }
    
    // MARK: Animation Stuff
    
    private static var sTexType = ""
    private static var sAnimation: SKAction!
    private static var sFlyAnimation: SKAction!
    private static var sShellToNormalAnimation: SKAction!
    override var animation: SKAction {
        get {
            if KoopasGuy.sTexType != texType {
                KoopasGuy.sAnimation = makeAnimation(texName: "koopas", suffix: texType, count: 2, timePerFrame: 0.1)
                KoopasGuy.sShellToNormalAnimation = makeAnimation(texName: "koopas", suffix: texType, count: 2, timePerFrame: 0.3, startIndex: 5)
                KoopasGuy.sFlyAnimation = makeAnimation(texName: "koopas", suffix: texType, count: 2, timePerFrame: 0.3, startIndex: 3)
                KoopasGuy.sTexType = texType
            }
            
            if flyCancelled {
                return SKAction()
            }
            
            if alive {
                switch state {
                case .normal:
                    return KoopasGuy.sAnimation
                case .fly:
                    return KoopasGuy.sFlyAnimation
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
            KoopasGuy.sShellToNormalAnimation = makeAnimation(texName: "koopas", suffix: texType, count: 2, timePerFrame: 0.3, startIndex: 5)
            KoopasGuy.sTexType = texType
        }
        
        return KoopasGuy.sShellToNormalAnimation
    }
}
