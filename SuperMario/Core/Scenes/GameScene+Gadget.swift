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
    case poleBase = "poleBase"
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
            case .poleBase:
                return CGSize(width: ratio, height: ratio)
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
            case .poleBase:
                return CGSize(width: ratio, height: ratio)
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
            let dest = gadget["dest"] as? String ?? ""
            let popOut = gadget["popOut"] as? Bool ?? false
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
            
            if type == .poleBase {
                if let withFlag = gadget["withFlag"] as? Bool, withFlag {
                    let flagPos = gadget["flag_pos"] as! Dictionary<String, CGFloat>
                    let ratio = GameConstant.TileGridLength
                    let offset = GameConstant.TileYOffset
                    let x = flagPos["x"]! * ratio
                    let y = flagPos["y"]! * ratio + offset
                    let sprite = SKSpriteNode(imageNamed: "flag_a_1")
                    sprite.position = CGPoint(x: x, y: y)
                    sprite.zPosition = 500.0
                    rootNode.addChild(sprite)
                    poledFlagNode = sprite
                    
                    let poleFlagUserData = NSMutableDictionary()
                    
                    let flagBotoomPos = CGPoint(x: x, y: node.position.y + ratio)
                    poleFlagUserData["flag_bottom_pos"] = flagBotoomPos
                    
                    let poleBodySize = CGSize(width: 6.0, height: y - node.position.y + ratio)
                    let body = SKPhysicsBody(rectangleOf: poleBodySize)
                    body.categoryBitMask = PhysicsCategory.Solid
                    body.isDynamic = false
                    let poleX = node.position.x
                    let poleY = (node.position.y - offset + y) * 0.5
                    let poleNode = SKNode()
                    poleNode.position = CGPoint(x: poleX, y: poleY)
                    poleNode.physicsBody = body
                    poleFlagUserData["pole_node"] = poleNode
                    rootNode.addChild(poleNode)
                    
                    let castleFlagPos = gadget["castle_flag_pos"] as! Dictionary<String, CGFloat>
                    let castleFlagX = castleFlagPos["x"]! * ratio
                    let castleFlagY = castleFlagPos["y"]! * ratio + offset
                    poleFlagUserData["castle_flag_pos"] = CGPoint(x: castleFlagX, y: castleFlagY)
                    
                    poledFlagNode?.userData = poleFlagUserData
                }
            }
        }
    }
    
    func startAutoWalkAfterFinishLevel(dstPos: CGPoint) {
        levelFinished = true
        AudioManager.stopBackgroundMusic()
        GameHUD.instance.pauseTimer()
        
        dirButton.touchesCancelled([], with: nil)
        if buttonA.actived {
            buttonA.actived = false
        }
        if buttonB.actived {
            buttonB.actived = false
        }
        
        dirButton.removeFromParent()
        buttonA.removeFromParent()
        buttonB.removeFromParent()
        buttonC.removeFromParent()
        buttonD.removeFromParent()
        
        marioAutoWalkDest = dstPos
        
        if let sprite = poledFlagNode {
            AudioManager.play(sound: .DownFlag)
        
            let flagBottomPos = sprite.userData!["flag_bottom_pos"] as! CGPoint
            let moveAction = SKAction.move(to: flagBottomPos, duration: 0.75)
            moveAction.timingMode = .easeIn
            let block = SKAction.run { [weak self] in
                if let node = sprite.userData?["pole_node"] as? SKNode {
                    node.removeFromParent()
                }
                self?.marioAutoWalk = true
            }
            sprite.run(SKAction.sequence([moveAction, block]))
        } else {
            delay(0.5) {
                self.marioAutoWalk = true
            }
        }
    }
    
    func marioAutoWalkingUpdate() {
        if marioAutoWalk && !marioAutoWalkFinished {
            if mario.posX < marioAutoWalkDest.x {
                mario.directionAction(ButtonDirectionCategory.Right)
            } else {
                mario.directionAction(ButtonDirectionCategory.None)
                marioAutoWalkFinished = true
                if let sprite = poledFlagNode {
                    mario.removeFromParent()
                    let castleFlagPos = sprite.userData!["castle_flag_pos"] as! CGPoint
                    let flag = makeCastleFlagNode(pos: castleFlagPos)
                    rootNode.addChild(flag)
                    AudioManager.play(sound: .LevelFinish)
                    delay(2.5) {
                        AudioManager.play(music: .StatsTime, false)
                        self.convertLeftTimeToScore(GameHUD.instance.timeCount)
                    }
                } else {
                    delay(5.5) {
                        GameManager.instance.finishLevel()
                    }
                }
            }
        }
    }
    
    func makeCastleFlagNode(pos: CGPoint) -> SKCropNode {
        let flagNode = SKSpriteNode(imageNamed: "flag_a_2")
        let cropNode = SKCropNode()
        let maskNode = SKShapeNode(rectOf: flagNode.size)
        maskNode.fillColor = .white
        maskNode.lineWidth = 0.0
        cropNode.maskNode = maskNode
        cropNode.addChild(flagNode)
        flagNode.position = CGPoint(x: 0.0, y: -flagNode.size.height * 0.5)
        cropNode.position = pos
        let moveAction = SKAction.move(to: .zero, duration: 0.5)
        flagNode.run(moveAction)
        return cropNode
    }
    
    func convertLeftTimeToScore(_ count: Int) {
        GameHUD.instance.timeCount = count
        if count <= 0 {
            AudioManager.stopBackgroundMusic()
            GameManager.instance.finishLevel()
        } else {
            delay(0.01) {
                self.convertLeftTimeToScore(count - 1)
            }
        }
    }
}
