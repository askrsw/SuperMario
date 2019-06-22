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

    func loadSolidPhysicsEdge() {
        guard let edgeArray = GameScene.readPhysicsJsonData(file: physicsDescFileName) else {
            fatalError("Can not load physics desc file.")
        }
        
        let gridRatio = GameConstant.TileGridLength
        let tileYOffset = GameConstant.TileYOffset
        let yFixup: CGFloat = 0.0 //GameConstant.groundYFixup
        
        var vertPhysicsBodies = [SKPhysicsBody]()
        var horzPhysicsBodies = [SKPhysicsBody]()
        
        for edge in edgeArray {
            let posDict = edge["pos"] as! Dictionary<String, CGFloat>
            let type = PhysicsSolidEdgeType(rawValue: edge["type"] as! String)!
            let len  = edge["len"] as! CGFloat
            let posX = posDict["x"]!
            let posY = posDict["y"]!
            var horzPadding: CGFloat = 0.0
            if edge["horzPadding"] != nil {
                horzPadding = edge["horzPadding"] as! CGFloat
            }
            
            switch type {
            case .verticalLeftLine:
                let point1 = CGPoint(x: posX * gridRatio + horzPadding, y: posY * gridRatio + tileYOffset)
                let point2 = CGPoint(x: point1.x, y: point1.y + len * gridRatio + yFixup)
                let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
                vertPhysicsBodies.append(pp_body)
            case .verticalRightLine:
                let point1 = CGPoint(x: (posX + 1) * gridRatio + horzPadding, y: posY * gridRatio + tileYOffset)
                let point2 = CGPoint(x: point1.x, y: point1.y + len * gridRatio + yFixup)
                let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
                vertPhysicsBodies.append(pp_body)
            case .groundLine: fallthrough
            case .pipeTopGroundLine:
                var point1 = CGPoint(x: posX * gridRatio, y: (posY + 1) * gridRatio + tileYOffset + yFixup)
                var point2 = CGPoint(x: point1.x + len * gridRatio, y: point1.y)
                
                let leftPadding = edge["leftPadding"] as? CGFloat
                if leftPadding != nil {
                    point1.x += leftPadding!
                }
                
                let rightPadding = edge["rightPadding"] as? CGFloat
                if rightPadding != nil {
                    point2.x += rightPadding!
                }
                
                let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
                
                horzPhysicsBodies.append(pp_body)
            case .pipeLeftSideLine:
                let path = GameScene.makeLeftPipeSideLinePath(posX, posY, len)
                let pp_body = SKPhysicsBody(edgeChainFrom: path)
                vertPhysicsBodies.append(pp_body)
            case .pipeRightSideLine:
                let path = GameScene.makeRightPipeSideLinePath(posX, posY, len)
                let pp_body = SKPhysicsBody(edgeChainFrom: path)
                vertPhysicsBodies.append(pp_body)
            case .horzPlatformLine:
                let param = ErasablePlatLineParam(gridX: posX, gridY: posY, len: len)
                makeErasablePlatNode(param: param)
            }
        }
        
        if horzPhysicsBodies.count > 0 {
            let horzPhysHostNode = SKNode()
            let body = SKPhysicsBody(bodies: horzPhysicsBodies)
            body.categoryBitMask = PhysicsCategory.Solid
            body.isDynamic = false
            body.friction = 0.0
            body.restitution = 0.0
            horzPhysHostNode.physicsBody = body
            self.rootNode!.addChild(horzPhysHostNode)
        }
        
        if vertPhysicsBodies.count > 0 {
            let vertPhysHostNode = SKNode()
            let body = SKPhysicsBody(bodies: vertPhysicsBodies)
            body.categoryBitMask = PhysicsCategory.Solid
            body.isDynamic = false
            body.friction = 0.0
            body.restitution = 0.0
            vertPhysHostNode.physicsBody = body
            self.rootNode!.addChild(vertPhysHostNode)
        }
    }
    
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

    // MARK: helper method
    
    static fileprivate func makeLeftPipeSideLinePath(_ gridX: CGFloat, _ gridY: CGFloat, _ len: CGFloat) -> CGPath {
        let x1 = gridX * GameConstant.TileGridLength + 2.0
        let y1 = gridY * GameConstant.TileGridLength + GameConstant.TileYOffset
        let x2 = x1
        let y2 = y1 + GameConstant.TileGridLength * (len - 1.0) + 2.0
        let x3 = x1 - 2.0
        let y3 = y2
        let x4 = x3
        let y4 = y2 + GameConstant.TileGridLength - 2.0 + GameConstant.groundYFixup
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        path.addLine(to: CGPoint(x: x3, y: y3))
        path.addLine(to: CGPoint(x: x4, y: y4))
        return path.cgPath
    }
    
    static fileprivate func makeRightPipeSideLinePath(_ gridX: CGFloat, _ gridY: CGFloat, _ len: CGFloat) -> CGPath {
        let x1 = (gridX + 1) * GameConstant.TileGridLength - 2.0
        let y1 = gridY * GameConstant.TileGridLength + GameConstant.TileYOffset
        let x2 = x1
        let y2 = y1 + GameConstant.TileGridLength * (len - 1.0) + 2.0
        let x3 = x1 + 2.0
        let y3 = y2
        let x4 = x3
        let y4 = y2 + GameConstant.TileGridLength - 2.0 + GameConstant.groundYFixup
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        path.addLine(to: CGPoint(x: x3, y: y3))
        path.addLine(to: CGPoint(x: x4, y: y4))
        return path.cgPath
    }
    
    static fileprivate func readPhysicsJsonData(file name:String) -> Array<Dictionary<String, Any>>? {
        let filePath = Bundle.main.path(forResource: name, ofType: "geojson")
        let url = URL(fileURLWithPath: filePath!)
        
        do {
            let data = try Data(contentsOf: url)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let jsonArr = jsonData as! Array<Dictionary<String, Any>>
            return jsonArr
        } catch let error as Error? {
            print("Error when load data from bundle:", error as Any)
            return nil
        }
    }
}
