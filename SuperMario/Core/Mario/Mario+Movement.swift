//
//  Mario+Movement.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/14.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit
import GameplayKit

extension Mario {
    
    // MARK: Movement statemachine defination
    
    class MovementState: GKState {
        let mario: Mario
        
        init(_ mario: Mario) {
            self.mario = mario
        }
        
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            if stateClass is CrouchingMoveState.Type && mario.marioPower == .A {
                return false
            }
            
            return true
        }
        
        func updateTextureOrAnimation() {
            mario.texture = mario.texture
            
            if let _ = mario.action(forKey: "moveAnimation") {
                mario.run(mario.moveAnimation, withKey: "moveAnimation")
            }
        }
        
        func MovementStateValue() -> MarioMoveState {
            return .still
        }
    }
    
    class StillMoveState: MovementState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            mario.texture = mario.stillTexture
        }
        
        override func MovementStateValue() -> MarioMoveState {
            return .still
        }
    }
    
    class WalkingMoveState: MovementState {
        override func willExit(to nextState: GKState) {
            super.willExit(to: nextState)
            mario.removeAction(forKey: "moveAnimation")
        }
        
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            mario.run(mario.moveAnimation, withKey: "moveAnimation")
        }
        
        override func MovementStateValue() -> MarioMoveState {
            return .walking
        }
    }
    
    class RunningMoveState: MovementState {
        override func willExit(to nextState: GKState) {
            super.willExit(to: nextState)
            mario.removeAction(forKey: "moveAnimation")
        }
        
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            mario.run(mario.moveAnimation, withKey: "moveAnimation")
        }
        
        override func MovementStateValue() -> MarioMoveState {
            return .running
        }
    }
    
    class SwimmingMoveState: MovementState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
        }
        
        override func MovementStateValue() -> MarioMoveState {
            return .swimming
        }
    }
    
    class JumpingMoveState: MovementState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            mario.texture = mario.jumpingTexture
        }
        
        override func MovementStateValue() -> MarioMoveState {
            return .jumping
        }
    }
    
    class CrouchingMoveState: MovementState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            mario.texture = mario.crouchingTexture ?? mario.stillTexture
            if let pBody = mario.physicsBody {
                mario.physicsBody = mario.makePhysicsBody(pBody.velocity, true)
            }
        }
        
        override func willExit(to nextState: GKState) {
            super.willExit(to: nextState)
            if let pBody = mario.physicsBody {
                mario.physicsBody = mario.makePhysicsBody(pBody.velocity, false)
            }
        }
        
        func leaveCrouchingMoveState() {
            if mario.jumping {
                stateMachine?.enter(JumpingMoveState.self)
            } else if mario.speedX {
                if mario.moveFaster {
                    stateMachine?.enter(RunningMoveState.self)
                } else {
                    stateMachine?.enter(WalkingMoveState.self)
                }
            } else {
                stateMachine?.enter(StillMoveState.self)
            }
        }
        
        override func MovementStateValue() -> MarioMoveState {
            return .crouching
        }
    }
    
    // MARK: Movement statement interface
    
    func createMovementStateMachine() {
        let still = StillMoveState(self)
        let walking = WalkingMoveState(self)
        let running = RunningMoveState(self)
        let swimming = SwimmingMoveState(self)
        let jumping = JumpingMoveState(self)
        let crouching = CrouchingMoveState(self)
        
        movementStateMachine = GKStateMachine(states: [still, walking, running, swimming, jumping, crouching])
        movementStateMachine.enter(StillMoveState.self)
    }
    
    func updateMovementStateMachine(deltaTime dt: CGFloat) {
        
        movementStateMachine.update(deltaTime: TimeInterval(dt))
        
        guard marioMoveState != .crouching else { return }
        
        if jumping {
            if marioMoveState != .jumping {
                movementStateMachine.enter(JumpingMoveState.self)
            }
            
            return
        }
        
        if speedX {
            if moveFaster {
                if marioMoveState != .running {
                    movementStateMachine.enter(RunningMoveState.self)
                }
            } else {
                if marioMoveState != .walking {
                    movementStateMachine.enter(WalkingMoveState.self)
                }
            }
        } else {
            if marioMoveState != .still {
                movementStateMachine.enter(StillMoveState.self)
            }
        }
    }
    
    func makePhysicsBody(_ velocity: CGVector = .zero, _ crouched: Bool = false) -> SKPhysicsBody {
        var physicalSize = CGSize.zero
        var physicalCenter = CGPoint.zero
        
        if crouched == false {
            switch marioPower {
            case .A:
                physicalSize = Mario.normalTextureA.size()
            case .B:
                physicalSize = Mario.normalTextureB.size()
            case .C:
                physicalSize = Mario.normalTextureC.size()
            }
            
            physicalSize.height -= 1.0
            
            if marioPower == .A {
                physicalSize.width  -= 4.0
            } else {
                physicalSize.width  -= 2.0
            }
            
            physicalCenter = CGPoint(x: 0.0, y: 1.0 / 2.0)
        } else {
            physicalSize = Mario.normalTextureA.size()
            physicalSize.height -= 1.0
            physicalSize.width  -= 2.0
            
            physicalCenter = CGPoint(x: 0.0, y: -GameConstant.TileGridLength / 2.0 + 1.0 / 2.0)
        }
        
        let ppBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        ppBody.allowsRotation = false
        ppBody.friction = 1.0
        ppBody.restitution = 0.0
        ppBody.categoryBitMask = PhysicsCategory.Mario
        ppBody.contactTestBitMask = PhysicsCategory.Brick | PhysicsCategory.GoldMetal | PhysicsCategory.MarioPower
        ppBody.collisionBitMask = PhysicsCategory.All & ~(PhysicsCategory.MarioPower & PhysicsCategory.MBullet)
        ppBody.velocity = velocity
        
        return ppBody
    }
    
    func updatePhysicsBodyState(deltaTime dt: CGFloat) {
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
    }
}
