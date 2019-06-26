//
//  GoldSprite.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

fileprivate enum GoldTileType: String {
    case gold = "goldm"
    case power = "mushroom"
    case lifeAdd = "mushroom_life"
}

class GoldSprite : SKSpriteNode {
    fileprivate let goldTileType: GoldTileType
    let type: FragileGridType
    var empty: Bool = false
    
    init(_ type: FragileGridType, _ tileName: String) {
        self.type = type
        self.goldTileType = GoldTileType(rawValue: tileName) ?? .gold
        
        let texFileName = "goldm" + type.rawValue + "_1"
        let tex = SKTexture(imageNamed: texFileName)
        super.init(texture: tex, color: SKColor.clear, size: tex.size())
        
        if self.goldTileType == .lifeAdd {
            self.alpha = 0.0
        }

        let physicalSize = CGSize(width: tex.size().width, height: tex.size().height - 0.1)
        let physicalCenter = CGPoint(x: 0.0, y: -0.1 / 2.0)
        physicsBody = SKPhysicsBody(rectangleOf: physicalSize, center: physicalCenter)
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 0.0
        physicsBody!.categoryBitMask = PhysicsCategory.GoldMetal
        physicsBody!.collisionBitMask = physicsBody!.collisionBitMask & ~PhysicsCategory.erasablePlat
        physicsBody!.isDynamic = false
    
        run(animation, withKey: "animation")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented.")
    }
    
    // MARK: Animation Stuff
    
    private static var sAnimation: SKAction!
    private static var sTexType = ""
    var animation: SKAction {
        get {
            if GoldSprite.sTexType != GameScene.currentTileType {
                GoldSprite.sAnimation = makeAnimation(texName: "goldm", suffix: GameScene.currentTileType, count: 3, timePerFrame: 0.5)
                GoldSprite.sTexType = GameScene.currentTileType
            }
            
            return GoldSprite.sAnimation
        }
    }
}

extension GoldSprite: MarioBumpFragileNode {
    
    func marioBump() {
        if self.empty == false {
            let texFileName = "goldm" + self.type.rawValue + "_4"
            self.texture = SKTexture(imageNamed: texFileName)
            self.removeAction(forKey: "animation")
            
            switch self.goldTileType {
            case .gold:
                spawnCoinFlyAnimation()
            case .power:
                spawnPowerUpSprite(false)
                break
            case .lifeAdd:
                spawnPowerUpSprite(true)
                break
            }
            
            self.empty = true
        } else {
            AudioManager.play(sound: .HitHard)
        }
    }
    
    // MARK: Helper Method
    
    private func spawnCoinFlyAnimation() {
        let coinFileName = "flycoin" + self.type.rawValue + "_1"
        let coin = SKSpriteNode(imageNamed: coinFileName)
        coin.zPosition = 1.0
        coin.position = CGPoint(x: 0.0, y: GameConstant.TileGridLength * 0.75)
        coin.run(GameAnimations.instance.flyCoinAnimation)
        self.addChild(coin)
        
        AudioManager.play(sound: .Coin)
    }
    
    private func spawnPowerUpSprite(_ lifeMushroom: Bool) {
        if lifeMushroom == false && GameManager.instance.mario.marioPower != .A {
            if let holder = GameManager.instance.currentScene?.staticSpriteHolder {
                let flower = FlowerSprite(self.type)
                let position = CGPoint(x: self.position.x, y: self.position.y + GameConstant.TileGridLength)
                flower.zPosition = self.zPosition
                flower.cropNode.position = position + self.parent!.position
                holder.addChild(flower.cropNode)
            }
            
        } else {
            if let holder = GameManager.instance.currentScene?.movingSpriteHolder {
                let mushroom = MushroomSprite(self.type, lifeMushroom)
                let position = CGPoint(x: self.position.x, y: self.position.y + GameConstant.TileGridLength)
                mushroom.zPosition = self.zPosition
                mushroom.cropNode.position = position + self.parent!.position
                holder.addChild(mushroom.cropNode)
            }
            
            if lifeMushroom == true {
                let fadeIn = SKAction.fadeIn(withDuration: 0.125)
                self.run(fadeIn)
            }
        }
        
        AudioManager.play(sound: .SpawnPowerup)
    }
}
