//
//  GameAnimations.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameAnimations {
    private init() {}
    
    static var goldmAnimation: SKAction = SKAction()
    static func updateGoldAnimation(_ suffix: String) {
        let texFileName1 = "goldm" + suffix + "_1"
        let tex1 = SKTexture(imageNamed: texFileName1)
        
        let texFileName2 = "goldm" + suffix + "_2"
        let tex2 = SKTexture(imageNamed: texFileName2)
        
        let texFileName3 = "goldm" + suffix + "_3"
        let tex3 = SKTexture(imageNamed: texFileName3)
        
        goldmAnimation = SKAction.repeatForever(SKAction.animate(with: [tex1, tex2, tex3], timePerFrame: 0.5))
    }
}
