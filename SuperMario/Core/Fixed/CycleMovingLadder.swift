//
//  CycleMovingLadder.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/4.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class CycleMovingLadder: SKNode {
    
    var array: Array<SKSpriteNode> = []
    let maxPosY: CGFloat
    let minPosY: CGFloat
    let ladderLength: Int
    var marioShapeshift: Bool = false
    
    init(posX: CGFloat, len: Int, count: Int) {
        let unitH = GameConstant.OriginalSceneHeight / CGFloat(count)
        ladderLength = len
        maxPosY = unitH * CGFloat(count + 1) + GameConstant.TileYOffset
        minPosY = -GameConstant.TileGridLength * 0.25 + GameConstant.TileYOffset
        super.init()
        
        let tex = SKTexture(image: texImage)
        let baseX = tex.size().width * 0.5 + posX * GameConstant.TileGridLength
        let baseY = minPosY
        let physicalSize = CGSize(width: tex.size().width, height: 8.0)
        for i in 0 ... count {
            let posX = baseX
            let posY = baseY + CGFloat(i) * unitH
        
            let ladder = SKSpriteNode(texture: tex)
            ladder.anchorPoint = CGPoint(x: 0.5, y: 0.75)
            ladder.position = CGPoint(x: posX, y: posY)
            ladder.physicsBody = SKPhysicsBody(rectangleOf: physicalSize)
            ladder.physicsBody?.categoryBitMask = PhysicsCategory.Solid
            ladder.physicsBody?.isDynamic = false
            ladder.physicsBody?.friction  = 0.0
            ladder.physicsBody?.restitution = 0.0
            
            addChild(ladder)
            array.append(ladder)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var speedY: CGFloat {
        get {
            return 80.0
        }
    }
    
    // MARK: Help method
    
    static var sLadderLength: Int = 0
    static var sLadderImage: UIImage!
    private var texImage: UIImage {
        get {
            if CycleMovingLadder.sLadderLength != ladderLength {
                let rawImage = UIImage(named: "ladder")
                let unitL = GameConstant.TileGridLength
                let imgSize = CGSize(width: unitL * CGFloat(ladderLength), height: unitL)
                UIGraphicsBeginImageContext(imgSize)
                for i in 0 ..< ladderLength {
                    let rect = CGRect(x: unitL * CGFloat(i), y: 0, width: unitL, height: unitL)
                    rawImage?.draw(in: rect)
                }
                CycleMovingLadder.sLadderImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                CycleMovingLadder.sLadderLength = ladderLength
            }
            
            return CycleMovingLadder.sLadderImage
        }
    }
}

extension CycleMovingLadder: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        guard dt < 0.25 else { return }
        guard !marioShapeshift else { return }
        
        let delta = speedY * dt
        
        for ladder in array {
            ladder.position.y += delta
            
            if ladder.position.y > maxPosY {
                let diff = maxPosY - minPosY
                
                // terrific
                ladder.position.y = ladder.position.y.truncatingRemainder(dividingBy: diff)
            }
        }
    }
}

extension CycleMovingLadder: MarioShapeshifting {
    func marioWillShapeshift() {
        self.marioShapeshift = true
    }
    
    func marioDidShapeshift() {
        self.marioShapeshift = false
    }
}
