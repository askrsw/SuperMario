//
//  Mario+Animation.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/18.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension Mario {
    
    static func makeAnimations(animType: MarioPower, timePerFrame: TimeInterval) -> SKAction {
        let mid = animType.rawValue
        
        let texWalk1 = SKTexture(imageNamed: "mario_" + mid + "_walk1")
        let texWalk2 = SKTexture(imageNamed: "mario_" + mid + "_walk2")
        let texWalk3 = SKTexture(imageNamed: "mario_" + mid + "_walk3")
        let animAction = SKAction.animate(with: [texWalk1, texWalk2, texWalk3], timePerFrame: timePerFrame)
        return SKAction.repeatForever(animAction)
    }
}
