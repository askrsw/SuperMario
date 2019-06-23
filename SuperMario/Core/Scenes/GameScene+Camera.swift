//
//  GameScene+Camera.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/23.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    func setCamera() {
        guard let camera = camera else { return }
        
        camera.xScale = 1.0 / scaleFactor
        camera.yScale = 1.0 / scaleFactor
        
        halfCameraViewWidth = size.width * 0.5
        
        if size.width < sceneWidth * scaleFactor {
            let zeroDistance = SKRange(constantValue: 0)
            let marioConstraint = SKConstraint.distance(zeroDistance, to: mario)
            let xRange = SKRange(lowerLimit: size.width * 0.5 / scaleFactor, upperLimit: (sceneWidth - size.width * 0.5 / scaleFactor))
            let yRange = SKRange(constantValue: size.height * 0.5 / scaleFactor)
            let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
            camera.constraints = [marioConstraint, edgeConstraint]
        } else {
            camera.position = CGPoint(x: sceneWidth * 0.5, y: GameConstant.OriginalSceneHeight * 0.5)
        }
        
        setDirButton()
        setActionButton()
    }
    
    fileprivate func setDirButton() {
        dirButton.name = "dir_button"
        dirButton.xScale = scaleFactor
        dirButton.yScale = scaleFactor
            
        let marginLeft = 24.0 * scaleFactor
        let marginBottom = 60.0 * scaleFactor
        let radius = GameConstant.directionButtonCircleRadius * scaleFactor
        
        let posX = -size.width * 0.5 + radius + marginLeft
        let posY = -size.height * 0.5 + radius + marginBottom
        dirButton.position = CGPoint(x: posX, y: posY)
        
        camera!.addChild(dirButton)
    
        dirButton.didMoveToScene()
    }
    
    fileprivate func setActionButton() {
        let marginRight = 24.0 * scaleFactor
        let marginBottom = 24.0 * scaleFactor
        let horzSpace = 18.0 * scaleFactor
        let vertSpace = 6.0 * scaleFactor
        let radius = GameConstant.actionButtonCircleRadius * scaleFactor
        
        let dX = size.width * 0.5 - radius - marginRight
        let dY = -size.height * 0.5 + radius + marginBottom
        buttonD.xScale = scaleFactor
        buttonD.yScale = scaleFactor
        buttonD.position = CGPoint(x: dX, y: dY)
        camera!.addChild(buttonD)
        
        let cX = dX - radius - horzSpace - radius
        let cY = dY + radius + radius
        buttonC.xScale = scaleFactor
        buttonC.yScale = scaleFactor
        buttonC.position = CGPoint(x: cX, y: cY)
        camera!.addChild(buttonC)
        
        let aX = cX
        let aY = cY + radius + vertSpace * 1.5 + radius
        buttonA.xScale = scaleFactor
        buttonA.yScale = scaleFactor
        buttonA.position = CGPoint(x: aX, y: aY)
        camera!.addChild(buttonA)
        
        let bX = dX
        let bY = dY + radius + vertSpace * 1.5 + radius
        buttonB.xScale = scaleFactor
        buttonB.yScale = scaleFactor
        buttonB.position = CGPoint(x: bX, y: bY)
        camera!.addChild(buttonB)
        
        buttonA.didMoveToScene()
        buttonB.didMoveToScene()
        buttonC.didMoveToScene()
        buttonD.didMoveToScene()
    }
}
