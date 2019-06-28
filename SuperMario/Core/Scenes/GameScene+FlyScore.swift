//
//  GameScene+FlyScore.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/28.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    func addScore(score: Int, pos: CGPoint) {
        let label = SKLabelNode(text: "\(score)")
        label.fontName = GameConstant.flyScoreFontName
        label.fontSize = GameConstant.flyScoreFontSize
        label.horizontalAlignmentMode = .center
        label.alpha = 0.75
        label.position = pos
        
        flyScoreHolder.addChild(label)
        label.run(GameAnimations.instance.flyScoreAnimation)
        delay(0.35) {
            GameHUD.instance.score += score
        }
    }
}
