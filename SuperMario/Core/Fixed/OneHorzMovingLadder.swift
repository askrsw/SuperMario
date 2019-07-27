//
//  OneHorzMovingLadder.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/27.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

fileprivate enum LadderMoveState {
    case moveRight
    case moveLeft
    case rightWait
    case leftWait
}

class OneHorzMovingLadder: SKSpriteNode {
    static var sLadderLength: Int = 0
    static var sLadderImage: UIImage!
    
    let maxWaitTime: CGFloat = 1.5
    let speedX: CGFloat = 64.0
    var maxX: CGFloat = 0.0
    var minX: CGFloat = 0.0
    var forward: Bool = false {
        didSet {
            if forward {
                moveState = .moveRight
            } else {
                moveState = .moveLeft
            }
        }
    }
    
    fileprivate var moveState: LadderMoveState = .moveLeft
    var waitTime: CGFloat = 0.0
    var marioShapeshift: Bool = false
    
    init(len: Int) {
        if OneVertMovingLadder.sLadderLength != len {
            OneVertMovingLadder.sLadderImage = makeRepeatGridImage(imageName: "ladder", count: len)
            OneVertMovingLadder.sLadderLength = len
        }
        
        let tex = SKTexture(image: OneVertMovingLadder.sLadderImage)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        zPosition = 100.0
        
        let physicalSize = CGSize(width: tex.size().width, height: 8.0)
        let physicalCenter = CGPoint(x: 0.0, y: 4.0)
        physicsBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        physicsBody?.categoryBitMask = PhysicsCategory.Solid
        physicsBody?.isDynamic = false
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OneHorzMovingLadder: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        guard dt < 0.25 else { return }
        guard !marioShapeshift else { return }
        
        switch moveState {
        case .moveRight:
            let deltaX = speedX * dt
            position.x += deltaX
            if position.x >= maxX {
                moveState = .rightWait
                waitTime = maxWaitTime
            }
            
            for body in physicsBody!.allContactedBodies() {
                if let node = body.node {
                    node.position.x += deltaX
                }
            }
        case .rightWait:
            waitTime -= dt
            if waitTime < 0.0 {
                moveState = .moveLeft
            }
        case .moveLeft:
            let deltaX = speedX * dt
            position.x -= deltaX
            if position.x <= minX {
                moveState = .leftWait
                waitTime = maxWaitTime
            }
            
            for body in physicsBody!.allContactedBodies() {
                if let node = body.node {
                    node.position.x -= deltaX
                }
            }
        case .leftWait:
            waitTime -= dt
            if waitTime < 0.0 {
                moveState = .moveRight
            }
        }
    }
}

extension OneHorzMovingLadder: MarioShapeshifting {
    func marioWillShapeshift() {
        self.marioShapeshift = true
    }
    
    func marioDidShapeshift() {
        self.marioShapeshift = false
    }
}
