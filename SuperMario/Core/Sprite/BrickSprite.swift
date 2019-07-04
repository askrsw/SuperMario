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
    case power = "mushroom"
    case lifeAdd = "mushroom_life"
}

class BrickSprite : SKSpriteNode {
    fileprivate let brickTileType: BrickTileType
    let type: FragileGridType
    let index: Int
    var empty: Bool = false
    var lastCoin: Bool = false
    var coinTimerSetted = false
    
    init(_ type: FragileGridType, _ tileName: String, _ index: Int) {
        self.type = type
        self.brickTileType = BrickTileType(rawValue: tileName) ?? .brick
        self.index = index
        
        let texFileName = "brick" + type.rawValue
        let tex = SKTexture(imageNamed: texFileName)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        let physicalSize = CGSize(width: tex.size().width, height: tex.size().height - 0.1)
        let physicalCenter = CGPoint(x: 0.0, y: -0.1 / 2.0)
        physicsBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.Brick
        physicsBody!.collisionBitMask = physicsBody!.collisionBitMask & ~(PhysicsCategory.ErasablePlat | PhysicsCategory.EBarrier)
        physicsBody!.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    func turnIntoPieces() {
        AudioManager.play(sound: .BreakBrick)
        let position = CGPoint(x: self.position.x, y: self.position.y - GameConstant.TileGridLength * 0.5)
        let _ = BrickPieceSprite.spawnPieceGroup(self.type, position)
        
        GameScene.setTileTypeDictionary(index: index, type: .None)
        GameScene.ErasePlatNode(self.position, index)
        
        GameScene.addScore(score: ScoreConfig.brickBreak, pos: position)
        
        removeFromParent()
        
        let pos = CGPoint(x: position.x, y: position.y + GameConstant.TileGridLength)
        if let coin = GameScene.currentInstance?.coinSpriteHolder.atPoint(pos) as? CoinSprite {
            coin.marioBump()
        }
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
        case .power:
            self.spawnPowerUpSprite(false)
        case .lifeAdd:
            self.spawnPowerUpSprite(true)
        }
        
        checkContactPhysicsBody()
    }
    
    // MARK: Helper method
    
    private func checkContactPhysicsBody() {
        let half_w = size.width * 0.49
        let half_h = size.height * 0.5
        let rect = CGRect(x: position.x - half_w, y: position.y + half_h, width: size.width * 0.98, height: 1.0)
        
        GameScene.checkRectForShake(rect: rect)
    }
    
    private func normalBrickProcess() {
        if GameManager.instance.mario.marioPower != .A && GameManager.instance.mario.marioMoveState != .crouching {
            turnIntoPieces()
        } else {
            self.run(shakeAnimation)
            AudioManager.play(sound: .HitHard)
            
            let pos = CGPoint(x: position.x, y: position.y + GameConstant.TileGridLength)
            if let coin = GameScene.currentInstance?.coinSpriteHolder.atPoint(pos) as? CoinSprite {
                coin.marioBump()
            }
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
        
        let pos = CGPoint(x: position.x, y: position.y + GameConstant.TileGridLength * 0.75)
        GameScene.addScore(score: ScoreConfig.hitOutBonus, pos: pos)
        GameHUD.instance.coinCount += 1
        
        if self.lastCoin {
            let texFileName = "goldm" + self.type.rawValue + "_4"
            self.texture = SKTexture(imageNamed: texFileName)
            self.empty = true
            
            GameScene.setTileTypeDictionary(index: index, type: .Solid)
        }
        
        if self.coinTimerSetted == false {
            delay(4.5) {
                self.lastCoin = true
            }
            
            self.coinTimerSetted = true
        }
    }
    
    private func starBrickProcess() {
        let star = StarSprite(self.type)
        let position = CGPoint(x: self.position.x, y: self.position.y + GameConstant.TileGridLength)
        star.zPosition = self.zPosition
        star.cropNode.position = position + self.parent!.position
        GameScene.addStar(star.cropNode)
        
        let texFileName = "goldm" + self.type.rawValue + "_4"
        self.texture = SKTexture(imageNamed: texFileName)
        self.empty = true
        
        AudioManager.play(sound: .SpawnPowerup)
        
        let pos = CGPoint(x: position.x, y: position.y + GameConstant.TileGridLength * 0.75)
        GameScene.addScore(score: ScoreConfig.hitOutBonus, pos: pos)
        
        GameScene.setTileTypeDictionary(index: index, type: .Solid)
    }
    
    private func spawnPowerUpSprite(_ lifeMushroom: Bool) {
        if lifeMushroom == false && GameManager.instance.mario.marioPower != .A {
            let flower = FlowerSprite(self.type)
            let position = CGPoint(x: self.position.x, y: self.position.y + GameConstant.TileGridLength)
            flower.zPosition = self.zPosition
            flower.cropNode.position = position + self.parent!.position
            GameScene.addFlower(flower.cropNode)
        } else {
            let mushroom = MushroomSprite(self.type, lifeMushroom)
            let position = CGPoint(x: self.position.x, y: self.position.y + GameConstant.TileGridLength)
            mushroom.zPosition = self.zPosition
            mushroom.cropNode.position = position + self.parent!.position
            GameScene.addMushroom(mushroom.cropNode)
            
            if lifeMushroom == true {
                let fadeIn = SKAction.fadeIn(withDuration: 0.125)
                self.run(fadeIn)
            }
        }
        
        AudioManager.play(sound: .SpawnPowerup)
        
        let texFileName = "goldm" + self.type.rawValue + "_4"
        self.texture = SKTexture(imageNamed: texFileName)
        self.empty = true
    }
}
