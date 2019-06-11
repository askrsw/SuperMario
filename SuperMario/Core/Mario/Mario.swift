//
//  Mario.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/18.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

enum MarioPower:Int {
    case A = 1
    case B = 2
    case C = 3
}

enum MarioFacing:Int {
    case forward  = 0
    case backward = 1
}

enum MarioMoveState:Int {
    case still    = 0
    case walking  = 1
    case running  = 2
    case swimming = 3
}

class Mario: SKSpriteNode {
    var velocity: CGFloat = 0.0
    
    var marioPower:     MarioPower     = .A
    var marioFacing:    MarioFacing    = .forward
    var marioMoveState: MarioMoveState = .swimming
    
    init() {
        let tex = SKTexture(imageNamed: "mario_a_normal1")
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        physicsBody = SKPhysicsBody(polygonFrom: marioPhysicsPath(tex.size()))
        physicsBody!.allowsRotation = false
        physicsBody!.friction = 0.75
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.Mario
        physicsBody!.contactTestBitMask = PhysicsCategory.All
        physicsBody!.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    // MARK: interface
    
    func update(deltaTime dt: CGFloat) {
        guard let physicsBody = physicsBody else { return }
        let vX = velocity * 30.0
        let vY = physicsBody.velocity.dy
        physicsBody.velocity = CGVector(dx: vX, dy: vY)
    }
    
    func directionAction(_ dir: UInt32) {
        switch dir {
        case ButtonDirectionCategory.Left:
            velocity = -5
        case ButtonDirectionCategory.Up:
            break
        case ButtonDirectionCategory.Left | ButtonDirectionCategory.Up:
            break
        case ButtonDirectionCategory.Right:
            velocity = 5
        case ButtonDirectionCategory.Right | ButtonDirectionCategory.Up:
            break
        case ButtonDirectionCategory.Down:
            break
        case ButtonDirectionCategory.Right | ButtonDirectionCategory.Down:
            break
        case ButtonDirectionCategory.Left | ButtonDirectionCategory.Down:
            break
        case ButtonDirectionCategory.None:
            velocity = 0.0
        default:
            break;
        }
    }
    
    // acceleration
    func turbo(_ v: Bool) {
        print("turbo:\(v)")
    }
    
    func jump(_ v: Bool) {
        print("jump:\(v)")
    }
    
    func jumpHigh() {
        guard let physicsBody = physicsBody else { return }
        let verticalForce = physicsBody.mass * 400.0
        physicsBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
    
    func fire() {
       print("fire")
    }
    
    // MARK: Physics body
    
    func marioPhysicsPath(_ size: CGSize) -> CGPath {
        let x = -size.width * 0.5 + 1.5
        let y = -size.height * 0.5 + 1.0
        let w = size.width - 1.5 * 2.0
        let h = size.height - 1.0 * 2.0
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4.0)
        return path.cgPath
    }
}
