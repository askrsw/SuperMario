//
//  RotateFireballs.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class RotateFireballs: SKNode {
    static var sSixFireBalls: UIImage!
    
    let sixFireBalls: SKSpriteNode
    let rotateSpeed: CGFloat = π * 2 / 4.0
    
    init(startAngle: CGFloat) {
        if RotateFireballs.sSixFireBalls == nil {
            RotateFireballs.sSixFireBalls = makeRepeatGridImage(imageName: "fire_bullet_4", count: 6)
        }
        
        let tex = SKTexture(image: RotateFireballs.sSixFireBalls)
        sixFireBalls = SKSpriteNode(texture: tex)
        super.init()
        
        sixFireBalls.anchorPoint = CGPoint(x: 1.0 / 12.0, y: 0.5)
        sixFireBalls.zRotation = startAngle
        addChild(sixFireBalls)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RotateFireballs: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        sixFireBalls.zRotation -= (rotateSpeed * dt)
    }
}
