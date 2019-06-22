//
//  Mario.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/18.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

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
                
            let tmp = marioMoveState
            marioMoveState = tmp
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
            
            if marioMoveState == .running || marioMoveState == .walking {
                run(moveAnimation, withKey: "moveAnimation")
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
            if moveFaster {
                return 180.0
            } else {
                return 120.0
            }
        }
    }
    
    var speedUpForce: CGVector {
        get {
            if moveFaster {
                return CGVector(dx: 360.0, dy: 0.0)
            } else {
                return CGVector(dx: 240.0, dy: 0.0)
            }
        }
    }
    
    var downWard: Bool = false {
        didSet {
            if downWard == true {
                guard marioPower != .A else { return }
                marioMoveState = .crouching
            } else {
                guard marioMoveState == .crouching else { return }
                if jumping {
                    marioMoveState = .jumping
                } else if speedX {
                    if moveFaster {
                        marioMoveState = .running
                    } else {
                        marioMoveState = .walking
                    }
                } else {
                    marioMoveState = .still
                }
            }
        }
    }
    
    var marioMoveState: MarioMoveState = .still {
        didSet {
            switch oldValue {
            case .walking: fallthrough
            case .running: removeAction(forKey: "moveAnimation")
            default: break
            }
            
            switch marioMoveState {
            case .still: texture = stillTexture
            case .jumping: texture = jumpingTexture
            case .walking: fallthrough
            case .running: run(moveAnimation, withKey: "moveAnimation")
            case .crouching: texture = crouchingTexture ?? stillTexture
            default: break
            }
        }
    }
    
    var jumping: Bool {
        get {
            return abs(physicsBody?.velocity.dy ?? 1.0) > 0.0
        }
    }
    
    init() {
        super.init(texture: stillTexture, color: SKColor.clear, size: stillTexture.size())
        physicsBody = makePhysicsBody()
        zPosition = 1000
        
        moveFaster = false
        marioPower = .A
        marioMoveState = .still
        marioFacing = .forward
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    // MARK: interface
    
    func update(deltaTime dt: CGFloat) {
        guard let physicsBody = physicsBody else { return }
        
        let curX = abs(physicsBody.velocity.dx)
        let vY = physicsBody.velocity.dy
        var vX: CGFloat = 0.0
        
        var force: CGVector = .zero
        if speedX {
            if curX < maxSpeedX {
                force = speedUpForce * physicsBody.mass * marioFacing.rawValue
            } else {
                vX = maxSpeedX
            }
        }
        
        if force != .zero {
            physicsBody.applyForce(force)
        } else {
            physicsBody.velocity = CGVector(dx: vX * marioFacing.rawValue, dy: vY)
        }
    
        guard marioMoveState != .crouching else { return }
        
        if jumping {
            if marioMoveState != .jumping {
                marioMoveState = .jumping
            }
            
            return
        }
        
        if speedX {
            if moveFaster {
                if marioMoveState != .running {
                    marioMoveState = .running
                }
            } else {
                if marioMoveState != .walking {
                    marioMoveState = .walking
                }
            }
        } else {
            if marioMoveState != .still {
                marioMoveState = .still
            }
        }
    }
}
