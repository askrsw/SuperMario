//
//  BrickPieceSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/17.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class BrickPieceSprite: SKSpriteNode {
    
    private enum BrickPieceType {
        case LeftUp
        case RightUp
        case LeftDown
        case RightDown
    }
    
    private static var commonTexture: UIImage?
    private static var texType: FragileGridType?

    private init(_ type: BrickPieceType, _ pos: CGPoint) {
        let commonTexture = BrickPieceSprite.commonTexture!
        let halfWidth  = commonTexture.size.width * 0.5
        let halfHeight = commonTexture.size.height * 0.5
        var posDiff = CGPoint.zero
        var imgRect = CGRect.zero
        var force = CGVector.zero
        
        switch type {
        case .LeftUp:
            imgRect = CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight)
            posDiff = CGPoint(x: -halfWidth * 0.5, y: halfHeight * 0.5)
            force   = CGVector(dx: -1, dy: 2.5)
        case .RightUp:
            imgRect = CGRect(x: halfWidth, y: 0, width: halfWidth, height: halfHeight)
            posDiff = CGPoint(x: halfWidth * 0.5, y: halfHeight * 0.5)
            force   = CGVector(dx: 1.0, dy: 2.5)
        case .LeftDown:
            imgRect = CGRect(x: 0, y: halfHeight, width: halfWidth, height: halfHeight)
            posDiff = CGPoint(x: -halfWidth * 0.5, y: -halfHeight * 0.5)
            force   = CGVector(dx: -1.0, dy: 1.0)
        case .RightDown:
            imgRect = CGRect(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight)
            posDiff = CGPoint(x: halfWidth * 0.5, y: -halfHeight * 0.5)
            force   = CGVector(dx: 1.0, dy: 1.0)
        }
        let imgRef = commonTexture.cgImage?.cropping(to: imgRect)
        let tex = SKTexture(cgImage: imgRef!)
        super.init(texture: tex, color: .clear, size: tex.size())
        
        self.position = pos + posDiff
        self.zPosition = GameManager.instance.mario.zPosition + 1
        
        if let holder = GameManager.instance.currentScene?.movingSpriteHolder {
            holder.addChild(self)
        }
        
        physicsBody = SKPhysicsBody(rectangleOf: self.size)
        physicsBody?.categoryBitMask = PhysicsCategory.None
        physicsBody?.collisionBitMask = PhysicsCategory.None
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        
        let impulse = force * (physicsBody?.mass ?? 1.0) * 150.0
        physicsBody?.applyImpulse(impulse)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func spawnPieceGroup(_ type: FragileGridType, _ pos: CGPoint) -> [BrickPieceSprite] {
        
        if commonTexture == nil || texType != type {
            let imgFileName = "brick_frag" + type.rawValue
            commonTexture = UIImage(named: imgFileName)
            texType = type
        }
        
        let leftUp    = BrickPieceSprite(.LeftUp, pos)
        let rightUp   = BrickPieceSprite(.RightUp, pos)
        let leftDown  = BrickPieceSprite(.LeftDown, pos)
        let rightDown = BrickPieceSprite(.RightDown, pos)
        
        return [leftUp, rightUp, leftDown, rightDown]
    }
}

extension BrickPieceSprite: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        if position.y < -self.size.height {
            removeFromParent()
        }
    }
}
