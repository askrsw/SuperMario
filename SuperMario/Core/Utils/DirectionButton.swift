//
//  DirectionButton.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/20.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class DirectionButton: SKNode {
    let circlePannel = SKShapeNode(circleOfRadius: GameConstant.directionButtonCircleRadius)
    let indicator    = SKShapeNode(circleOfRadius: GameConstant.directionButtonSmallCircleRadius)
    let fadeOne      = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
    let originalState: SKAction

    var actionType: UInt32 = ButtonDirectionCategory.None {
        didSet {
            GameManager.instance.mario.directionAction(actionType)
        }
    }
    
    override init() {
        let fadeHalf = SKAction.fadeAlpha(to: 0.5, duration: 0.15)
        let moveToZero = SKAction.move(to: .zero, duration: 0.15)
        moveToZero.timingMode = .easeInEaseOut
        originalState = SKAction.group([fadeHalf, moveToZero])
        
        super.init()
        
        circlePannel.fillColor = SKColor(white: 0.95, alpha: 0.1)
        circlePannel.strokeColor = SKColor.white
        circlePannel.lineWidth = 1
        addChild(circlePannel)
        
        indicator.fillColor = SKColor.yellow
        indicator.lineWidth = 0.0
        indicator.alpha = 0.5
        circlePannel.addChild(indicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    // MARK: interface
    
    func didMoveToScene() {
        let range = SKRange.init(lowerLimit: 0, upperLimit: GameConstant.directionButtonCircleRadius)
        let constraint = SKConstraint.distance(range, to: CGPoint.zero)
        indicator.constraints = [constraint]
        
        self.isUserInteractionEnabled = true
    }
    
    // MARK: Touch event process
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            indicator.run(fadeOne, withKey: "stateChange")
            circlePannel.fillColor = SKColor(white: 0.95, alpha: 0.25)
            
            let touchPoint = touch.location(in: self)
            indicator.position = touchPoint
            checkTouchType(touchPoint)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            indicator.position = touchPoint
            checkTouchType(touchPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionType = ButtonDirectionCategory.None
        indicator.run(originalState, withKey: "stateChange")
        circlePannel.fillColor = SKColor(white: 0.95, alpha: 0.1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionType = ButtonDirectionCategory.None
        indicator.run(originalState, withKey: "stateChange")
        circlePannel.fillColor = SKColor(white: 0.95, alpha: 0.1)
    }
    
    // MARK: Helper Method
    
    func checkTouchType(_ touchPoint: CGPoint) {
        let angle = touchPoint.angle
        
        if -π/6.0 <= angle && angle <= π/6.0 {
            actionType = ButtonDirectionCategory.Right
        } else if π/6.0 <= angle && angle <= π/3.0 {
            actionType = ButtonDirectionCategory.Right | ButtonDirectionCategory.Up
        } else if π/3.0 <= angle && angle <= 2*π/3.0 {
            actionType = ButtonDirectionCategory.Up
        } else if 2*π/3.0 <= angle && angle <= 5*π/6.0 {
            actionType = ButtonDirectionCategory.Left | ButtonDirectionCategory.Up
        } else if angle >= 5*π/6.0 || angle <= -5*π/6.0 {
            actionType = ButtonDirectionCategory.Left
        } else if -5*π/6.0 <= angle && angle <= -2*π/3.0 {
            actionType = ButtonDirectionCategory.Left | ButtonDirectionCategory.Down
        } else if -2*π/3.0 <= angle && angle <= -π/3.0 {
            actionType = ButtonDirectionCategory.Down
        } else {
            actionType = ButtonDirectionCategory.Right | ButtonDirectionCategory.Down
        }
    }
}
