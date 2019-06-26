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
    
    var stillTexture = normalTextureA
    var jumpingTexture = jumpingTextureA
    var crouchingTexture: SKTexture?
    var moveAnimation = walkAnimationA
    
    var lifeCount: Int = 3
    
    var speedX: Bool = false
    var underWater: Bool = false
    var shapeshifting: Bool = false
    
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
                let scene = GameManager.instance.currentScene!
                scene.playBackgroundMusc(moveFaster, true)
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
            let scene = GameManager.instance.currentScene!
            
            if powerfull == true {
                let animation = SKAction.repeatForever(GameAnimations.instance.flashAnimation)
                self.run(animation, withKey: "marioFlash")
                
                delay(10.0) {
                    self.powerfull = false
                }
                
                scene.marioIsPowerfull()
            } else {
                self.removeAction(forKey: "marioFlash")
                self.alpha = 1.0
                scene.playBackgroundMusc(moveFaster, false)
            }
        }
    }
    
    init() {
        super.init(texture: stillTexture, color: SKColor.clear, size: stillTexture.size())
        
        zPosition = 1000
        
        moveFaster = false
        marioPower = .A
        marioFacing = .forward
        
        createMovementStateMachine()
        
        physicsBody = makePhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    // MARK: interface
    
    func update(deltaTime dt: CGFloat) {
        updatePhysicsBodyState(deltaTime: dt)
        updateMovementStateMachine(deltaTime: dt)
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
