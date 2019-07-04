//
//  PirhanaPlant.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/4.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class PirhanaPlant: SKNode {
    let tileType: String
    let cropNode = SKNode()
    let pirhanaNode: SKSpriteNode
    
    init(tileType: String) {
        self.tileType = tileType
        let texFileName = "pirhana" + tileType + "_1"
        let tex = SKTexture(imageNamed: texFileName)
        pirhanaNode = SKSpriteNode(texture: tex)
        super.init()
        
        let maskNode = SKShapeNode(rectOf: tex.size())
        maskNode.fillColor = SKColor.white
        cropNode.addChild(pirhanaNode)
        
        pirhanaNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        pirhanaNode.position = .zero
        
        self.addChild(cropNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Help method
    
    private static var sTexType = ""
    private static var sAnimation: SKAction!
    var animation: SKAction {
        get {
            if PirhanaPlant.sTexType != tileType {
                PirhanaPlant.sAnimation = makeAnimation(texName: "pirhana", suffix: tileType, count: 2, timePerFrame: 0.3)
                PirhanaPlant.sTexType = tileType
            }
            
            return PirhanaPlant.sAnimation
        }
    }
}

extension PirhanaPlant: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        
    }
}
