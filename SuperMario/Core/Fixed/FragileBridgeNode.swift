//
//  FragileBridgeNode.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/12.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class FragileBridgeNode: SKNode {
    
    let count: Int
    var bridgeSections: Array<SKSpriteNode> = []
    let bridgeChain: SKSpriteNode
    let switchNode: SKSpriteNode
    let switchAnimation: SKAction
    var boss: BowserGuy? = BowserGuy()
    var leftX: CGFloat  = 0.0
    var rightX: CGFloat = 0.0
    var switchRect: CGRect = .zero
    var destroyed: Bool = false
    var marioDestPostion: CGPoint = .zero
    
    override var position: CGPoint {
        didSet {
            leftX = position.x
            rightX = leftX + GameConstant.TileGridLength * CGFloat(count + 1)
        
            let x = leftX + GameConstant.TileGridLength * CGFloat(count) + 1.5
            let y = position.y + GameConstant.TileGridLength * 1.5
            switchRect = CGRect(x: x, y: y, width: GameConstant.TileGridLength - 3.0, height: GameConstant.TileGridLength)
        }
    }
    
    var active: Bool = false {
        didSet {
            if oldValue != active {
                if active {
                    switchNode.run(switchAnimation, withKey: "animation")
                } else {
                    switchNode.removeAction(forKey: "animation")
                }
                
                boss?.active = active
            }
        }
    }
    
    init(count: Int, tileType: String) {
        self.count = count
        
        let texChain = SKTexture(imageNamed: "bridge_chain")
        bridgeChain = SKSpriteNode(texture: texChain)
        
        let texName1 = "switch_" + tileType + "_1"
        let texSwitch1 = SKTexture(imageNamed: texName1)
        
        let texName2 = "switch_" + tileType + "_2"
        let texSwitch2 = SKTexture(imageNamed: texName2)
        
        let texName3 = "switch_" + tileType + "_3"
        let texSwitch3 = SKTexture(imageNamed: texName3)
        
        switchNode = SKSpriteNode(texture: texSwitch1)
        let animation = SKAction.animate(with: [texSwitch1, texSwitch2, texSwitch3], timePerFrame: 0.75)
        switchAnimation = SKAction.repeatForever(animation)
        
        super.init()
        
        let texBridge = SKTexture(imageNamed: "bridge")
        let unitL = texBridge.size().width
        var xPos = unitL * 0.5
        for _ in 1...count {
            let bridgeNode = SKSpriteNode(texture: texBridge)
            bridgeNode.position = CGPoint(x: xPos, y: 0.0)
            bridgeSections.append(bridgeNode)
            addChild(bridgeNode)
            
            xPos += unitL
        }
        
        bridgeChain.position = CGPoint(x: xPos - unitL, y: unitL)
        addChild(bridgeChain)
        
        switchNode.position = CGPoint(x: xPos, y: unitL * 2.0)
        addChild(switchNode)
        
        boss!.bridge = self
        boss!.position = CGPoint(x: unitL * 10.0, y: unitL * 1.5)
        addChild(boss!)
        
        physicsBody = makePhysicsBody(start: 0, end: count)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Help method
    
    private func makePhysicsBody(start: Int, end: Int) -> SKPhysicsBody {
        let unitL = GameConstant.TileGridLength
        let point1 = CGPoint(x: CGFloat(start) * unitL, y: unitL * 0.5)
        let point2 = CGPoint(x: CGFloat(end) * unitL, y: unitL * 0.5)
        let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
        pp_body.categoryBitMask = PhysicsCategory.Solid
        pp_body.isDynamic = false
        pp_body.restitution = 0.0
        pp_body.friction = 0.0
        return pp_body
    }
}

extension FragileBridgeNode: MovingSpriteNode {
    func update(deltaTime dt: CGFloat) {
        let mario = GameManager.instance.mario
        if (mario.posX > (leftX - GameScene.halfScaledSceneWdith)) && (mario.posX < (rightX + GameScene.halfScaledSceneWdith)) {
            active = true
        } else {
            active = false
        }
        
        guard active else { return }
        
        //let point1 = CGPoint(x: mario.leftX, y: mario.bottomY)
        //let point2 = CGPoint(x: mario.rightX, y: mario.bottomY)
        //if switchRect.contains(point1) || switchRect.contains(point2) {
        if switchRect.intersects(mario.frame) {
            if !destroyed {
                destroyed = true
                destroyBridge()
            }
        }
        
        boss?.update(deltaTime: dt)
    }
    
    // MARK: Help method
    
    fileprivate func destroyBridge() {
        let remove = SKAction.removeFromParent()
        let moveDown = SKAction.moveTo(y: -position.y, duration: 0.1)
        moveDown.timingMode = .easeIn
        var actrualAction = SKAction.sequence([moveDown, remove])
        let wait = SKAction.wait(forDuration: 0.05)
        weak var weakScene = GameScene.currentInstance
        let block = SKAction.run { [weak self] in
            if let parent = self?.parent {
                self?.boss?.move(toParent: parent)
                self?.switchNode.move(toParent: parent)
                if let dstPos = self?.marioDestPostion {
                    weakScene?.startAutoWalkAfterFinishLevel(dstPos: dstPos)
                }
            }
            self?.run(remove)
        }
        
        AudioManager.stopBackgroundMusic()
        AudioManager.play(sound: .BreakBridge)
        
        boss?.ossify()
        
        let count = bridgeSections.count
        for index in 0 ..< count {
            if index != count - 1 {
                bridgeSections[index].run(actrualAction)
                actrualAction = SKAction.sequence([wait, actrualAction])
            } else {
                actrualAction = SKAction.sequence([actrualAction, block])
                bridgeSections[index].run(actrualAction)
            }
        }
    }
}
