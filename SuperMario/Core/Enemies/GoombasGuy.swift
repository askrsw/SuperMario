//
//  GoombasGuy.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/24.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GoombasGuy: EnemiesBaseNode {
    
    override var speedX: CGFloat {
        get {
            return 50.0
        }
    }
    
    override var shouldMirrorY: Bool {
        get {
            return true
        }
    }
    
    override var physicalShape: UIBezierPath {
        get {
            let point1 = CGPoint(x: -3, y: 8)
            let point2 = CGPoint(x: -8, y: 3)
            let point3 = CGPoint(x: -8, y: -5)
            let point4 = CGPoint(x: -5, y: -7)
            let point5 = CGPoint(x: 5, y: -7)
            let point6 = CGPoint(x: 8, y: -5)
            let point7 = CGPoint(x: 8, y: 3)
            let point8 = CGPoint(x: 3, y: 8)
            
            let shape = UIBezierPath()
            shape.move(to: point1)
            shape.addLine(to: point2)
            shape.addLine(to: point3)
            shape.addLine(to: point4)
            shape.addLine(to: point5)
            shape.addLine(to: point6)
            shape.addLine(to: point7)
            shape.addLine(to: point8)
            shape.addLine(to: point1)
            return shape
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func createPhysicsBody() {
        super.createPhysicsBody()
        
        if let alive = userData?["Alive"] as? Bool, alive == true {
            
        } else {
            removeFromParent()
        }
    }
    
    // MARK: Animation Stuff
    
    private static var sAnimation: SKAction!
    private static var sTexType = ""
    override var animation: SKAction {
        get {
            if GoombasGuy.sTexType != GameScene.currentTileType {
                GoombasGuy.sAnimation = makeAnimation(texName: "goombas", suffix: GameScene.currentTileType, count: 2, timePerFrame: 0.3)
                GoombasGuy.sTexType = GameScene.currentTileType
            }
            
            return GoombasGuy.sAnimation
        }
    }
}
