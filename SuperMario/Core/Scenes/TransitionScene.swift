//
//  TransitionScene.swift
//  SuperMario
//
//  Created by haharsw on 2019/8/8.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class TransitionScene: SKScene {
    
    var mainTitle: String?
    var nextLevel: Int = 0
    var forMarioDied: Bool = false
    var gameSceneName: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scaleMode = .resizeFill
        
        let height = UIScreen.main.bounds.height
        let scaleFactor = height / GameConstant.OriginalSceneHeight
        size = UIScreen.main.bounds.size
        if let camera = camera {
            camera.zPosition = 2000
            camera.xScale = 1.0 / scaleFactor
            camera.yScale = 1.0 / scaleFactor
            camera.position = CGPoint(x: GameConstant.OriginalSceneWidth * 0.5, y: GameConstant.OriginalSceneHeight * 0.5)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        if let camera = camera {
            GameHUD.instance.move(toParent: camera)
            GameHUD.instance.position = .zero
        }
        
        if let title = mainTitle {
            let mainTitleLabel = SKLabelNode()
            mainTitleLabel.text = title
            mainTitleLabel.fontName = GameConstant.hudLabelFontName
            mainTitleLabel.fontSize = GameConstant.hudLabelFontSize * 1.5
            mainTitleLabel.fontColor = .white
            mainTitleLabel.horizontalAlignmentMode = .center
            mainTitleLabel.verticalAlignmentMode = .center
            self.addChild(mainTitleLabel)
            
            mainTitleLabel.position = CGPoint(x: GameConstant.OriginalSceneWidth * 0.5, y: GameConstant.OriginalSceneHeight * 0.5)
        }
        
        delay(3.0) {
            if !self.forMarioDied {
                GameManager.instance.start(level: self.nextLevel)
            } else {
                GameManager.instance.marioNewBorn()
            }
        }
    }
}
