//
//  Mario.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/18.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit
import GameplayKit

enum MarioPower:String {
    case A = "a"
    case B = "b"
    case C = "c"
}

enum MarioFacing:CGFloat {
    case forward  = 1.0
    case backward = -1.0
}

enum MarioMoveState:Int {
    case still     = 0
    case walking   = 1
    case running   = 2
    case swimming  = 3
    case jumping   = 4
    case crouching = 5
}

class Mario: SKSpriteNode {
    static let walkAnimationA = Mario.makeAnimations(animType: .A, timePerFrame: 0.1)
    static let walkAnimationB = Mario.makeAnimations(animType: .B, timePerFrame: 0.1)
    static let walkAnimationC = Mario.makeAnimations(animType: .C, timePerFrame: 0.1)
    static let runAnimationA  = Mario.makeAnimations(animType: .A, timePerFrame: 0.075)
    static let runAnimationB  = Mario.makeAnimations(animType: .B, timePerFrame: 0.075)
    static let runAnimationC  = Mario.makeAnimations(animType: .C, timePerFrame: 0.075)
    
    static let normalTextureA = SKTexture(imageNamed: "mario_a_normal1")
    static let normalTextureB = SKTexture(imageNamed: "mario_b_normal1")
    static let normalTextureC = SKTexture(imageNamed: "mario_c_normal1")
    
    static let jumpingTextureA = SKTexture(imageNamed: "mario_a_jump")
    static let jumpingTextureB = SKTexture(imageNamed: "mario_b_jump")
    static let jumpingTextureC = SKTexture(imageNamed: "mario_c_jump")
    
    static let crouchingTextureB = SKTexture(imageNamed: "mario_b_down1")
    static let crouchingTextureC = SKTexture(imageNamed: "mario_c_down1")
    
    static let deadMarioTexture = SKTexture(imageNamed: "mario_a_dead")
    
    var stillTexture = normalTextureA
    var jumpingTexture = jumpingTextureA
    var crouchingTexture: SKTexture?
    var moveAnimation = walkAnimationA
    
    var speedX: Bool = false
    var underWater: Bool = false
    
    var shapeshifting: Bool = false {
        didSet {
            if shapeshifting {
                GameScene.marioWillShapeshift()
            } else {
                GameScene.marioDidShapeshift()
            }
        }
    }
    
    var pipingTime: Bool = false {
        didSet {
            speedX   = false
            downWard = false
        }
    }
    
    var movementStateMachine: GKStateMachine!
    
    var marioPower: MarioPower = .A {
        didSet {
            guard oldValue != marioPower else { return }
            
            switch marioPower {
            case .A:
                stillTexture = Mario.normalTextureA
                jumpingTexture = Mario.jumpingTextureA
                crouchingTexture = nil
                moveAnimation = moveFaster ? Mario.runAnimationA : Mario.walkAnimationA
            case .B:
                stillTexture = Mario.normalTextureB
                jumpingTexture = Mario.jumpingTextureB
                crouchingTexture = Mario.crouchingTextureB
                moveAnimation = moveFaster ? Mario.runAnimationB : Mario.walkAnimationB
            case .C:
                stillTexture = Mario.normalTextureC
                jumpingTexture = Mario.jumpingTextureC
                crouchingTexture = Mario.crouchingTextureC
                moveAnimation = moveFaster ? Mario.runAnimationC : Mario.walkAnimationC
            }

            if let movementState = movementStateMachine.currentState as? MovementState {
                movementState.updateTextureOrAnimation()
            }
            
            texture = stillTexture
            size = stillTexture.size()
            physicsBody = makePhysicsBody()
        }
    }
    
    var moveFaster: Bool = false {
        didSet {
            switch marioPower {
            case .A:
                moveAnimation = moveFaster ? Mario.runAnimationA : Mario.walkAnimationA
            case .B:
                moveAnimation = moveFaster ? Mario.runAnimationB : Mario.walkAnimationB
            case .C:
                moveAnimation = moveFaster ? Mario.runAnimationC : Mario.walkAnimationC
            }
            
            if powerfull == false && pipingTime == false {
                if !GameScene.levelFinished {
                    GameScene.playBackgroundMusc(moveFaster, true)
                }
            }
        }
    }
    
    var marioFacing: MarioFacing = .forward {
        didSet {
            xScale = marioFacing.rawValue
        }
    }
    
    var maxSpeedX: CGFloat {
        get {
            if moveFaster && marioMoveState != .crouching {
                return 200.0
            } else {
                return 120.0
            }
        }
    }
    
    var speedUpForce: CGVector {
        get {
            if moveFaster && marioMoveState != .crouching {
                return CGVector(dx: 360.0, dy: 0.0)
            } else {
                return CGVector(dx: 240.0, dy: 0.0)
            }
        }
    }
    
    var downWard: Bool = false {
        didSet {
            if downWard == true {
                if checkGadgetUnderFoot() == false {
                    movementStateMachine.enter(CrouchingMoveState.self)
                }
            } else {
                if let crouchingState = movementStateMachine.currentState as? CrouchingMoveState {
                    crouchingState.leaveCrouchingMoveState()
                }
            }
        }
    }
    
    var marioMoveState: MarioMoveState {
        get {
            let state = movementStateMachine.currentState as! MovementState
            return state.MovementStateValue()
        }
    }
    
    var jumping: Bool {
        get {
            return abs(physicsBody?.velocity.dy ?? 0.0) > 0.0
        }
    }
    
    var powerfull: Bool = false {
        didSet {
            guard oldValue != powerfull else { return }
            
            if powerfull == true {
                let animation = SKAction.repeatForever(GameAnimations.instance.flashAnimation)
                self.run(animation, withKey: "marioFlash")
                
                delay(10.0) {
                    self.powerfull = false
                }
                
                GameScene.marioIsPowerfull()
                physicsBody!.collisionBitMask = physicsBody!.collisionBitMask & ~(PhysicsCategory.Enemy)
            } else {
                self.removeAction(forKey: "marioFlash")
                self.alpha = 1.0
                if !GameScene.levelFinished {
                    GameScene.playBackgroundMusc(moveFaster, false)
                }
                physicsBody!.collisionBitMask = physicsBody!.collisionBitMask | PhysicsCategory.Enemy
            }
        }
    }
    
    var undead: Bool = false {
        didSet {
            if undead {
                let animation = SKAction.repeatForever(GameAnimations.instance.flashAnimation)
                self.run(animation, withKey: "marioFlash")
                
                delay(3.0) {
                    self.undead = false
                }
            } else {
                self.removeAction(forKey: "marioFlash")
                self.alpha = 1.0
            }
        }
    }
    
    var posX: CGFloat {
        get {
            if let scene = GameScene.currentInstance, let parent = parent {
                return scene.convert(position, from: parent).x
            } else {
                return 0.0
            }
        }
    }
    
    var leftX: CGFloat {
        get {
            if let scene = GameScene.currentInstance, let parent = parent {
                return scene.convert(position, from: parent).x - GameConstant.TileGridLength * 0.5
            } else {
                return 0.0
            }
        }
    }
    
    var rightX: CGFloat {
        get {
            if let scene = GameScene.currentInstance, let parent = parent {
                return scene.convert(position, from: parent).x + GameConstant.TileGridLength * 0.5
            } else {
                return 0.0
            }
        }
    }
    
    var bottomY: CGFloat {
        get {
            if let scene = GameScene.currentInstance, let parent = parent {
                let posY = scene.convert(position, from: parent).y + GameConstant.TileGridLength * 0.5
                if marioPower != .A && marioMoveState != .crouching {
                    return posY - GameConstant.TileGridLength
                } else {
                    return posY - GameConstant.TileGridLength * 0.5
                }
            } else {
                return 0.0
            }
        }
    }
    
    var died: Bool = false
    
    init() {
        super.init(texture: stillTexture, color: SKColor.clear, size: stillTexture.size())
        zPosition = 1000
        
        moveFaster = false
        marioFacing = .forward
        createMovementStateMachine()
        physicsBody = makePhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    // MARK: interface
    
    func update(deltaTime dt: CGFloat) {
        guard !died else {
            if position.y < -self.size.height * 2 {
                physicsBody = nil
                removeFromParent()
                GameManager.instance.marioDied()
            }
            return
        }
        
        let sceneHeight = GameConstant.OriginalSceneHeight
        if (position.y < -sceneHeight * 0.5) || (position.y > sceneHeight * 1.5) {
            AudioManager.stopBackgroundMusic()
            died = true
            physicsBody = nil
            removeFromParent()
            GameManager.instance.marioDied()
            return
        }
        
        updatePhysicsBodyState(deltaTime: dt)
        updateMovementStateMachine(deltaTime: dt)
    }
    
    func collideWithEnemy() {
        if !undead {
            switch marioPower {
            case .A:
                marioDied()
            case .B:
                powerDownToA()
            case .C:
                powerDownToB()
            }
        }
    }
    
    func marioDied() {
        died = true
        
        AudioManager.stopBackgroundMusic()
        removeAllActions()
        texture = Mario.deadMarioTexture
        size = Mario.deadMarioTexture.size()
        if GameHUD.instance.marioLifeCount > 1 {
            AudioManager.play(sound: .MarioDeathShort)
        } else {
            AudioManager.play(sound: .MarioDeathLong)
        }
        
        if let pBody = physicsBody {
            pBody.categoryBitMask = PhysicsCategory.None
            pBody.collisionBitMask = PhysicsCategory.None
            pBody.contactTestBitMask = PhysicsCategory.None
            pBody.affectedByGravity = true
            
            let vector = CGVector(dx: 0.0, dy: pBody.velocity.dy)
            pBody.velocity = vector
            
            let verticalForce = pBody.mass * 350.0
            pBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
        }
    }
    
    func newBorn(pos: CGPoint) {
        position = pos
        died = false
        pipingTime = false
        moveFaster = false
        marioPower = .A
        marioFacing = .forward
        powerfull = false
        undead = false
        speedX = false
        texture = Mario.normalTextureA
        size = Mario.normalTextureA.size()
        physicsBody = makePhysicsBody()
    }
    
    // MARK: Help method
    
    fileprivate static func makeAnimations(animType: MarioPower, timePerFrame: TimeInterval) -> SKAction {
        let mid = animType.rawValue
        
        let texWalk1 = SKTexture(imageNamed: "mario_" + mid + "_walk1")
        let texWalk2 = SKTexture(imageNamed: "mario_" + mid + "_walk2")
        let texWalk3 = SKTexture(imageNamed: "mario_" + mid + "_walk3")
        let animAction = SKAction.animate(with: [texWalk1, texWalk2, texWalk3], timePerFrame: timePerFrame)
        return SKAction.repeatForever(animAction)
    }
}
