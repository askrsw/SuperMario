//
//  ActionButton.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/23.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

enum ButtonActionType:String {
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
}

class ActionButton: SKNode {

    let actionType: ButtonActionType
    let circleStrokeShape = SKShapeNode(circleOfRadius: GameConstant.actionButtonCircleRadius)
    let circleFillShape = SKShapeNode(circleOfRadius: GameConstant.actionButtonCircleRadius - 1.5)
    let buttonLabel = SKLabelNode(fontNamed: GameConstant.actionButtonFontName)
    
    var actived: Bool = false {
        didSet {
            if actived == false {
                circleFillShape.alpha = 0.1
                buttonLabel.fontColor = SKColor(white: 1.0, alpha: 0.75)
            } else {
                circleFillShape.alpha = 0.5
                buttonLabel.fontColor = SKColor(white: 1.0, alpha: 1.0)
            }
            
            switch actionType {
            case .A:
                GameManager.instance.mario.turbo(actived)
            
            case .B:
            #if DEBUG
                if actived {
                    GameScene.rootNode.alpha = 0.0
                    GameScene.currentInstance?.vertIndexLabelHolder.alpha = 0.0
                } else {
                    GameScene.rootNode.alpha = 1.0
                    GameScene.currentInstance?.vertIndexLabelHolder.alpha = 1.0
                }
            #else
                break
            #endif
                
            default:
                break
            }
        }
    }
    
    init(actionType: ButtonActionType) {
        self.actionType = actionType
        super.init()
        
        circleStrokeShape.fillColor = SKColor.clear
        circleStrokeShape.strokeColor = SKColor.white
        circleStrokeShape.lineWidth = 1.0
        circleStrokeShape.zPosition = 0
        addChild(circleStrokeShape)
        
        circleFillShape.fillColor = .white
        circleFillShape.lineWidth = 0.0
        circleFillShape.zPosition = 1
        circleFillShape.alpha = 0.1
        addChild(circleFillShape)
        
        buttonLabel.text = actionType.rawValue
        buttonLabel.fontSize = GameConstant.actionButtonFontSize
        buttonLabel.fontColor = SKColor(white: 1.0, alpha: 0.75)
        buttonLabel.zPosition = 2
        addChild(buttonLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    func didMoveToScene() {
        let posX: CGFloat = 0.0
        let posY: CGFloat = -buttonLabel.frame.height / 2.0
        buttonLabel.position = CGPoint(x: posX, y: posY)
        
        isUserInteractionEnabled = true
    }
    
    // MARK: Touch event process
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            switch actionType {
            case .C:
                GameManager.instance.mario.fire()
            case .D:
                GameManager.instance.mario.jumpHigh()
            default:
                actived = !actived
            }
        }
    }
}
