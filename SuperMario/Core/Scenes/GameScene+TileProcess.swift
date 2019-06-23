//
//  GameScene+TileProcess.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/22.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene {
    
#if DEBUG
    func drawColumnNumber() {
        let y: CGFloat = 24.0
        var x: CGFloat = 8.0
        var index: Int = 0
        while x < sceneWidth {
            let label = SKLabelNode(text: "\(index)")
            label.fontSize = 10.0
            label.fontColor = SKColor.white
            label.position = CGPoint(x: x, y: y)
            rootNode!.addChild(label)
            
            x += GameConstant.TileGridLength
            index += 1
        }
    }
#endif
    
    func loadBrickGridTile() {
        if let brickTileMapNode = rootNode!.childNode(withName: "brick_grid") as? SKTileMapNode {
            let tileType = FragileGridType(rawValue: self.tileType)!
            
            for column in 0 ..< brickTileMapNode.numberOfColumns {
                for row in 0 ..< brickTileMapNode.numberOfRows {
                    guard let tile = brickTileMapNode.tileDefinition(atColumn: column, row: row) else { continue }
                    let center = brickTileMapNode.centerOfTile(atColumn: column, row: row)
                    
                    let brick = BrickSprite(tileType, tile.name ?? "")
                    brick.position = CGPoint(x: center.x, y: center.y + GameConstant.TileYOffset)
                    
                    brickSpriteHolder.addChild(brick)
                }
            }
            
            brickTileMapNode.removeFromParent()
        }
    }
    
    func loadGoldGridTile() {
        if let goldTileMapNode = rootNode!.childNode(withName: "gold_grid") as? SKTileMapNode {
            let tileType = FragileGridType(rawValue: self.tileType)!
            
            for column in 0 ..< goldTileMapNode.numberOfColumns {
                for row in 0 ..< goldTileMapNode.numberOfRows {
                    guard let tile = goldTileMapNode.tileDefinition(atColumn: column, row: row) else { continue }
                    let center = goldTileMapNode.centerOfTile(atColumn: column, row: row)
                    
                    let goldMetal = GoldSprite(tileType, tile.name ?? "")
                    goldMetal.position = CGPoint(x: center.x, y: center.y + GameConstant.TileYOffset)
                    
                    goldSpriteHolder.addChild(goldMetal)
                }
            }
            
            goldTileMapNode.removeFromParent()
        }
    }
    
    func loadCoinGridTile() {
        if let coinTileMapNode = rootNode!.childNode(withName: "coin_grid") as? SKTileMapNode {
            let tileType = FragileGridType(rawValue: self.tileType)!
            
            for column in 0 ..< coinTileMapNode.numberOfColumns {
                for row in 0 ..< coinTileMapNode.numberOfRows {
                    guard let _ = coinTileMapNode.tileDefinition(atColumn: column, row: row) else { continue }
                    let center = coinTileMapNode.centerOfTile(atColumn: column, row: row)
                    
                    let coin = CoinSprite(tileType)
                    coin.position = CGPoint(x: center.x, y: center.y + GameConstant.TileYOffset)
                    
                    coinSpriteHolder.addChild(coin)
                }
            }
            
            coinTileMapNode.removeFromParent()
        }
    }
}
