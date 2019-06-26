//
//  BrickSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

fileprivate enum BrickTileType: String {
    case brick = "brick"
    case coinBrick = "coin"
    case starBrick = "star"
}

class BrickSprite : SKSpriteNode {
    fileprivate let brickTileType: BrickTileType
    let type: FragileGridType
    var empty: Bool = false
    var lastCoin: Bool = false
    var coinTimerSetted = false
    
    init(_ type: FragileGridType, _ tileName: String) {
        self.type = type
        self.brickTileType = BrickTileType(rawValue: tileName) ?? .brick
        
        let texFileName = "brick" + type.rawValue
        let tex = SKTexture(imageNamed: texFileName)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        let physicalSize = CGSize(width: tex.size().width, height: tex.size().height - 0.1)
        let physicalCenter = CGPoint(x: 0.0, y: -0.1 / 2.0)
        physicsBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.Brick
        physicsBody!.collisionBitMask = physicsBody!.collisionBitMask & ~PhysicsCategory.erasablePlat
        physicsBody!.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    // MARK: Animation Stuff
    
    private static var sShakeAnimation: SKAction!
    var shakeAnimation: SKAction {
        get {
            if BrickSprite.sShakeAnimation == nil {
                let vector = CGVector(dx: 0.0, dy: GameConstant.TileGridLength * 0.2)
                let moveByAction = SKAction.move(by: vector, duration: 0.075)
                moveByAction.timingMode = .easeOut
                let reverseAction = moveByAction.reversed()
                reverseAction.timingMode = .easeIn
                BrickSprite.sShakeAnimation = SKAction.sequence([moveByAction, reverseAction])
            }
            
            return BrickSprite.sShakeAnimation
        }
    }
}

extension BrickSprite: MarioBumpFragileNode {
    func marioBump() {
        guard self.empty != true else {
            AudioManager.play(sound: .HitHard)
            return
        }
        
        switch self.brickTileType {
        case .brick:
            self.normalBrickProcess()
        case .coinBrick:
            self.coinBrickProccess()
        case .starBrick:
            self.starBrickProcess()
        }
    }
    
    // MARK: Helper method
    
    private func normalBrickProcess() {
        if GameManager.instance.mario.marioPower != .A && GameManager.instance.mario.marioMoveState != .crouching {
            removeFromParent()
            AudioManager.play(sound: .BreakBrick)
            let position = CGPoint(x: self.position.x, y: self.position.y - GameConstant.TileGridLength * 0.5)
            let _ = BrickPieceSprite.spawnPieceGroup(self.type, position)
            
            if let scene = GameManager.instance.currentScene {
                scene.ErasePlatNode(self.position)
            }
        } else {
            self.run(shakeAnimation)
            AudioManager.play(sound: .HitHard)
        }
    }
    
    private func coinBrickProccess() {
        self.run(shakeAnimation)
        
        let coinFileName = "flycoin" + self.type.rawValue + "_1"
        let coin = SKSpriteNode(imageNamed: coinFileName)
        coin.zPosition = 1.0
        coin.position = CGPoint(x: 0.0, y: GameConstant.TileGridLength * 0.75)
        coin.run(GameAnimations.instance.flyCoinAnimation)
        self.addChild(coin)
        AudioManager.play(sound: .Coin)
        
        if self.lastCoin {
            let texFileName = "goldm" + self.type.rawValue + "_4"
            self.texture = SKTexture(imageNamed: texFileName)
            self.empty = true
        }
        
        if self.coinTimerSetted == false {
            delay(4.5) {
                self.lastCoin = true
            }
            
            self.coinTimerSetted = true
        }
    }
    
    private func starBrickProcess() {
        if let holder = GameManager.instance.currentScene?.movingSpriteHolder {
            let star = StarSprite(self.type)
            let position = CGPoint(x: self.position.x, y: self.position.y + GameConstant.TileGridLength)
            star.zPosition = self.zPosition
            star.cropNode.position = position + self.parent!.position
            holder.addChild(star.cropNode)
        }
        
        let texFileName = "goldm" + self.type.rawValue + "_4"
        self.texture = SKTexture(imageNamed: texFileName)
        self.empty = true
        
        AudioManager.play(sound: .SpawnPowerup)
    }
}
