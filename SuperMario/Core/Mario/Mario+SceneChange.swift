//
//  Mario+SceneChange.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/23.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension Mario {
    
    func checkGadgetUnderFoot() -> Bool {
        guard let scene = GameManager.instance.currentScene else { return false }
        
        let rect = CGRect(x: position.x,
                          y: position.y - size.height * 0.5,
                          width: size.width, height: size.height)
        
        var gadget: SceneGadget? = nil
        scene.physicsWorld.enumerateBodies(in: rect) { (body, _) in
            if body.categoryBitMask == PhysicsCategory.Gadget {
                if let node = body.node {
                    gadget = node.userData?["param"] as? SceneGadget
                }
            }
        }
        
        if gadget == nil || gadget?.type != .horz {
            return false
        } else {
            let gadget = gadget!
            let left  = position.x - size.width * 0.5
            let right = position.x + size.width * 0.5
            let start = gadget.position.x - GameConstant.TileGridLength
            let end   = start + GameConstant.TileGridLength * 2.0
            
            if start <= left && right <= end {
                enterPipe(gadget: gadget)
                return true
            } else {
                return false
            }
        }
    }
    
    func didEnterNextScene(_ gadget: SceneGadget) {
        if gadget.popOut {
            pipingTime = true
            
            let cropNode = SKCropNode()
            let maskNode = SKShapeNode(rectOf: self.size)
            maskNode.fillColor = SKColor.white
            cropNode.maskNode = maskNode
            cropNode.zPosition = zPosition
            if marioPower == .A {
                let fixedPosition = CGPoint(x: gadget.destPostion.x, y: gadget.destPostion.y - size.height * 0.5)
                cropNode.position = fixedPosition
            } else {
                cropNode.position = gadget.destPostion
            }
            
            GameManager.instance.currentScene!.rootNode.addChild(cropNode)
            
            marioFacing = .forward
    
            let pBody = physicsBody
            physicsBody = nil
            move(toParent: cropNode)
            position = CGPoint(x: 0.0, y: -size.height)
            
            let moveAction = SKAction.moveTo(y: 0.0, duration: 0.75)
            run(moveAction) { [weak self] in
                self?.physicsBody = pBody
                self?.pipingTime = false
                self?.move(toParent: cropNode.parent!)
            }
        } else {
            position = gadget.destPostion
        }
    }
    
    func checkVertGadget(gadget: SceneGadget) {
        let bottom  = position.y - size.height * 0.5
        let top = position.y + size.height * 0.5
        let start = gadget.position.y - gadget.size.height * 0.5
        let end   = start + gadget.size.height

        if start <= bottom && top <= end {
            enterPipe(gadget: gadget)
        }
    }
    
    // MARK: Help Method
    
    fileprivate func enterPipe(gadget: SceneGadget) {
        pipingTime = true
        
        AudioManager.stopBackgroundMusic()
        AudioManager.play(sound: .EnPipe)
        
        let cropNode = SKCropNode()
        let maskNode = SKShapeNode(rectOf: self.size)
        maskNode.fillColor = SKColor.white
        cropNode.maskNode = maskNode
        cropNode.position = position
        cropNode.zPosition = zPosition
        parent!.addChild(cropNode)
        move(toParent: cropNode)
        
        let pBody = physicsBody
        physicsBody = nil
        movementStateMachine.enter(StillMoveState.self)
        
        let dstPostion = gadget.type == .horz ? CGPoint(x: 0.0, y: -size.height) : CGPoint(x: size.width, y: 0.0)
        let moveAction = SKAction.move(to: dstPostion, duration: 0.75)
        run(moveAction) { [weak self] in
            self?.physicsBody = pBody
            self?.pipingTime = false
            self?.removeFromParent()
            GameManager.instance.enterScene(gadget)
        }
    }
}
