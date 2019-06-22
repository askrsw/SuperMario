//
//  Mario+Movement.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/14.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension Mario {
    
    func makePhysicsBody(_ velocity: CGVector = .zero ) -> SKPhysicsBody {
        var physicalSize = CGSize.zero
        
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
        
        let physicalCenter = CGPoint(x: 0.0, y: 1.0 / 2.0)
        
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
}
