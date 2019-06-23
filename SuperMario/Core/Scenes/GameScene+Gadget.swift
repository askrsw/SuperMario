//
//  GameScene+Gadget.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/23.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

enum SceneGadgetType: String {
    case horz = "horzGaget"
    case vert = "vertGaget"
}

struct SceneGadget {
    let type: SceneGadgetType
    let gridX: CGFloat
    let gridY: CGFloat
    let destSceneName: String
    let destX: CGFloat
    let destY: CGFloat
    let popOut: Bool
    
    var size: CGSize {
        get {
            let ratio = GameConstant.TileGridLength
            switch type {
            case .horz:
                return CGSize(width: ratio * 2.0, height: ratio * 0.3)
            case .vert:
                return CGSize(width: ratio * 0.3, height: ratio * 2.0 * 1.1)
            }
        }
    }
    
    var physicalSize: CGSize {
        get {
            let ratio = GameConstant.TileGridLength
            switch type {
            case .horz:
                return CGSize(width: ratio * 2.0 * 0.8, height: ratio * 0.3)
            case .vert:
                return CGSize(width: ratio * 0.3, height: ratio * 2.0 * 0.8)
            }
        }
    }
    
    var position: CGPoint {
        get {
            let ratio = GameConstant.TileGridLength
            let offet = GameConstant.TileYOffset
            let x = (gridX + 1.0) * ratio
            let y = gridY * ratio + offet
            return CGPoint(x: x, y: y)
        }
    }
    
    var destPostion: CGPoint {
        get {
            let ratio = GameConstant.TileGridLength
            let offet = GameConstant.TileYOffset
            let x = destX * ratio
            let y = destY * ratio + offet
            return CGPoint(x: x, y: y)
        }
    }
}

extension GameScene {
    
    func loadPhysicsGadets(_ gadetArray: Array<Dictionary<String, Any>>) {
        for gadget in gadetArray {
            let type = SceneGadgetType(rawValue: gadget["type"] as! String)!
            let dest = gadget["dest"] as! String
            let popOut = gadget["popOut"] as! Bool
            let pos = gadget["pos"] as! Dictionary<String, CGFloat>
            let gridX = pos["x"]!
            let gridY = pos["y"]!
            let dstPos = gadget["dst_pos"] as! Dictionary<String, CGFloat>
            let destX = dstPos["x"]!
            let destY = dstPos["y"]!
            
            let param = SceneGadget(type: type, gridX: gridX, gridY: gridY, destSceneName: dest, destX: destX, destY: destY, popOut: popOut)
            
            let body = SKPhysicsBody(rectangleOf: param.physicalSize)
            body.categoryBitMask = PhysicsCategory.Gadget
            body.collisionBitMask = PhysicsCategory.None
            body.isDynamic = false
            
            let node = SKNode()
            node.position = param.position
            node.physicsBody = body
            node.userData = ["param": param]
            gadgetNodeHolder.addChild(node)
        }
    }
}
