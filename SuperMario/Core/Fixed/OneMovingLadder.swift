//
//  OneMovingLadder.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/6.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

fileprivate enum LadderMoveState {
    case moveUp
    case moveDown
    case upWait
    case downWait
}

class OneMovingLadder: SKSpriteNode {
    static var sLadderLength: Int = 0
    static var sLadderImage: UIImage!
    
    let maxWaitTime: CGFloat = 1.5
    let speedY: CGFloat = 48.0
    var maxY: CGFloat = 0.0
    var minY: CGFloat = 0.0
    var downward: Bool = false {
        didSet {
            if downward {
                moveState = .moveDown
            } else {
                moveState = .moveUp
            }
        }
    }
    
    fileprivate var moveState: LadderMoveState = .moveUp
    var waitTime: CGFloat = 0.0
    var marioShapeshift: Bool = false
    
    init(len: Int) {
        if OneMovingLadder.sLadderLength != len {
            OneMovingLadder.sLadderImage = makeRepeatGridImage(imageName: "ladder", count: len)
            OneMovingLadder.sLadderLength = len
        }
        
        let tex = SKTexture(image: OneMovingLadder.sLadderImage)
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

extension OneMovingLadder: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        guard dt < 0.25 else { return }
        guard !marioShapeshift else { return }
        
        switch moveState {
        case .moveUp:
            position.y += (speedY * dt)
            if position.y >= maxY {
                moveState = .upWait
                waitTime = maxWaitTime
            }
        case .upWait:
            waitTime -= dt
            if waitTime < 0.0 {
                moveState = .moveDown
            }
        case .moveDown:
            let deltaY = speedY * dt
            position.y -= deltaY
            if position.y <= minY {
                moveState = .downWait
                waitTime = maxWaitTime
            }
            
            for body in physicsBody!.allContactedBodies() {
                if let node = body.node {
                    node.position.y -= deltaY
                }
            }
        case .downWait:
            waitTime -= dt
            if waitTime < 0.0 {
                moveState = .moveUp
            }
        }
    }
}

extension OneMovingLadder: MarioShapeshifting {
    func marioWillShapeshift() {
        self.marioShapeshift = true
    }
    
    func marioDidShapeshift() {
        self.marioShapeshift = false
    }
}
