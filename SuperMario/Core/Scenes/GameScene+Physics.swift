//
//  GameScene+Physics.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

enum TileGridType: Int {
    case None  = 0
    case Brick = 1
    case Solid = 2
}

struct ErasablePlatLineParam {
    var gridX: CGFloat
    let gridY: CGFloat
    var len:   CGFloat
    
    var position1: CGPoint {
        get {
            let gridRatio = GameConstant.TileGridLength
            let tileYOffset = GameConstant.TileYOffset
            return CGPoint(x: gridX * gridRatio, y: (gridY + 1.0) * gridRatio + tileYOffset)
        }
    }
    
    var position2: CGPoint {
        get {
            let gridRatio = GameConstant.TileGridLength
            return CGPoint(x: position1.x + len * gridRatio, y: position1.y)
        }
    }
}

enum VerticalDummyLineSide {
    case left
    case right
}

struct VerticalDummyLine {
    let side: VerticalDummyLineSide
    let gridX: CGFloat
    var gridY: CGFloat
    var len:   CGFloat
    
    var nodePosition: CGPoint {
        get {
            let x = (gridX + (side == .left ? -0.25: 1.25)) * GameConstant.TileGridLength
            let y = (gridY + len * 0.5) * GameConstant.TileGridLength + GameConstant.TileYOffset
            return CGPoint(x: x, y: y)
        }
    }
    
    var nodeSize: CGSize {
        get {
            let width = GameConstant.TileGridLength * 0.5
            let height = len * GameConstant.TileGridLength
            return CGSize(width: width, height: height)
        }
    }
    
    var physicalPosition1: CGPoint {
        get {
            let x = (side == .left ? 0.25 : -0.25) * GameConstant.TileGridLength
            let y = -len * 0.5 * GameConstant.TileGridLength + 4.0
            return CGPoint(x: x, y: y)
        }
    }
    
    var physicalPosition2: CGPoint {
        get {
            let x = physicalPosition1.x
            let y = physicalPosition1.y + nodeSize.height - 5.0
            return CGPoint(x: x, y: y)
        }
    }
}

extension GameScene {
    func makeErasablePlatNode(param: ErasablePlatLineParam) {
        let node = SKNode()
        node.physicsBody = makeErasablePlatPhysics(param.position1, param.position2)
        node.userData = NSMutableDictionary(dictionary: ["param" : param])
        erasablePlatHolder.addChild(node)
    }
    
    func makeVerticalDummyLineNode(param: VerticalDummyLine) {
        let node = SKShapeNode(rectOf: param.nodeSize)
        node.physicsBody = makeVerticalDummyLinePhysics(param.physicalPosition1, param.physicalPosition2)
        node.position = param.nodePosition
        node.zPosition = 900
        node.lineWidth = 0.0
        node.alpha = 0.0
        node.userData = NSMutableDictionary(dictionary: ["param" : param])
        erasablePlatHolder.addChild(node)
        
    #if DEBUG
        node.alpha = 0.5
        if param.side == .left {
            node.fillColor = .red
        } else {
            node.fillColor = .blue
        }
    #endif
    }
    
    func ErasePlatNode(_ pos: CGPoint, _ index: Int) {
        ErasePlatPhysicsNode(pos)
        
        if verticalPhysicsLine {
            EraseVerticalDummyPhysicsLineNode(pos, index: index)
        }
    }
    
    func loadPhysicsDesc() {
        let jsonDict = GameScene.readPhysicsJsonData(file: physicsDescFileName)
        
        if let physicalShapes = jsonDict["shapes"] as? Array<Dictionary<String, Any>> {
            loadSolidPhysicsEdges(physicalShapes)
        }
        
        if let physicalGadgets = jsonDict["gadgetes"] as? Array<Dictionary<String, Any>> {
            loadPhysicsGadets(physicalGadgets)
        }
        
        if let physicalLadders = jsonDict["ladders"] as? Array<Dictionary<String, Any>> {
            loadPhysicsLadders(physicalLadders)
        }
        
        if let pirhanas = jsonDict["pirhanas"] as? Array<Dictionary<String, Any>> {
            loadPirhanaPlant(pirhanas)
        }
        
        if let singleladders = jsonDict["singlevertladders"] as? Array<Dictionary<String, Any>> {
            loadSingleVertPhysicsLadders(singleladders)
        }
        
        if let singleladders = jsonDict["singlehorzladders"] as? Array<Dictionary<String, Any>> {
            loadSingleHorzPhysicsLadders(singleladders)
        }
        
        if let rotatefireballs = jsonDict["rotatefireballs"] as? Array<Dictionary<String, Any>> {
            loadRotateFireBalls(rotatefireballs)
        }
        
        if let bridges = jsonDict["bridges"] as? Array<Dictionary<String, Any>> {
            loadBridges(bridges)
        }
    }
    
    func checkRectForShake(rect: CGRect) {
        physicsWorld.enumerateBodies(in: rect) { (body, _) in
            if let node = body.node as? EnemiesBaseNode {
                node.shakedByBottomSupport()
            }
        }
    }
    
    // MARK: Helper method
    
    fileprivate func EraseVerticalDummyPhysicsLineNode(_ pos: CGPoint, index: Int) {
        let leftIndex = index - GameConstant.sceneRowCount
        let rightIndex = index + GameConstant.sceneRowCount
        let unitL = GameConstant.TileGridLength
        
        if tileTypeDict[leftIndex] == nil {
            let testPoint = CGPoint(x: pos.x - unitL * 0.75, y: pos.y)
            EraseLastVerticalDummySectionLine(testPoint)
        } else {
            let testPoint = CGPoint(x: pos.x - unitL * 0.25, y: pos.y)
            ReshapeVerticalDummySectionLine(point: testPoint, index: leftIndex, side: .right)
        }
        
        if tileTypeDict[rightIndex] == nil {
            let testPoint = CGPoint(x: pos.x + unitL * 0.75, y: pos.y)
            EraseLastVerticalDummySectionLine(testPoint)
        } else {
            let testPoint = CGPoint(x: pos.x + unitL * 0.25, y: pos.y)
            ReshapeVerticalDummySectionLine(point: testPoint, index: rightIndex, side: .left)
        }
    }
    
    fileprivate func EraseLastVerticalDummySectionLine(_ point: CGPoint) {
        if let shape = erasablePlatHolder.atPoint(point) as? SKShapeNode {
            shape.removeFromParent()
            var param = shape.userData!["param"] as! VerticalDummyLine
            param.gridY += 1
            param.len   -= 1
            if param.len > 0.5 {
                makeVerticalDummyLineNode(param: param)
            }
        }
    }
    
    fileprivate func ReshapeVerticalDummySectionLine(point: CGPoint, index: Int, side: VerticalDummyLineSide) {
        let unitL = GameConstant.TileGridLength
        let topPoint = CGPoint(x: point.x, y: point.y + unitL)
        let bottomPoint = CGPoint(x: point.x, y: point.y - unitL)
        
        if let top = erasablePlatHolder.atPoint(topPoint) as? SKShapeNode, let bottom = erasablePlatHolder.atPoint(bottomPoint) as? SKShapeNode {
            let topParam = top.userData!["param"] as! VerticalDummyLine
            var bottomParam = bottom.userData!["param"] as! VerticalDummyLine
            bottomParam.len += 1 + topParam.len
            top.removeFromParent()
            bottom.removeFromParent()
            makeVerticalDummyLineNode(param: bottomParam)
        } else if let top = erasablePlatHolder.atPoint(topPoint) as? SKShapeNode {
            var topParam = top.userData!["param"] as! VerticalDummyLine
            topParam.len += 1
            topParam.gridY -= 1
            top.removeFromParent()
            makeVerticalDummyLineNode(param: topParam)
        } else if let bottom = erasablePlatHolder.atPoint(topPoint) as? SKShapeNode {
            var bottomParam = bottom.userData!["param"] as! VerticalDummyLine
            bottomParam.len += 1
            bottom.removeFromParent()
            makeVerticalDummyLineNode(param: bottomParam)
        } else {
            let gridX = index / GameConstant.sceneRowCount
            let gridY = index % GameConstant.sceneRowCount
            let param = VerticalDummyLine(side: side, gridX: CGFloat(gridX), gridY: CGFloat(gridY), len: 1.0)
            makeVerticalDummyLineNode(param: param)
        }
    }
    
    fileprivate func ErasePlatPhysicsNode(_ pos: CGPoint) {
        let unitL = GameConstant.TileGridLength
        let rect = CGRect(x: pos.x - 0.5, y: pos.y, width: 1.0, height: unitL)
        
        // Warning: Very Important when you can not delete or edit current
        //          physics body during the physicsWorld.enumerateBodies method.
        //          Or you will get a confused result that likes a bug. For
        //          this issue I have debugged and tested about one and a half days.
        var willBeRemovedNodes: Array<SKNode> = []
        
        physicsWorld.enumerateBodies(in: rect) { [weak self] (body, _) in
            if body.categoryBitMask == PhysicsCategory.ErasablePlat {
                if let node = body.node {
                    let gridX: CGFloat = floor(pos.x / unitL)
                    let gridY: CGFloat = round((pos.y - unitL * 0.25) / unitL)
                    
                    if let ret = self?.rebuildErasePlatNode(node, X: gridX, Y: gridY), ret {
                        willBeRemovedNodes.append(node)
                    }
                }
            }
        }
        
        for node in willBeRemovedNodes {
            node.physicsBody = nil
            node.removeFromParent()
        }
    }
    
    fileprivate func makeErasablePlatPhysics(_ pos1: CGPoint, _ pos2: CGPoint) -> SKPhysicsBody {
        let body = SKPhysicsBody(edgeFrom: pos1, to: pos2)
        body.categoryBitMask = PhysicsCategory.ErasablePlat
        body.collisionBitMask = body.collisionBitMask & ~PhysicsCategory.ErasablePlat
        body.isDynamic = false
        body.friction = 0.0
        body.restitution = 0.0
        
        return body
    }
    
    fileprivate func makeVerticalDummyLinePhysics(_ pos1: CGPoint, _ pos2: CGPoint) -> SKPhysicsBody {
        let body = SKPhysicsBody(edgeFrom: pos1, to: pos2)
        body.categoryBitMask = PhysicsCategory.DummyVertLine
        body.collisionBitMask = body.collisionBitMask & ~PhysicsCategory.DummyVertLine
        body.isDynamic = false
        body.friction = 0.0
        body.restitution = 0.0
        
        return body
    }
    
    fileprivate func rebuildErasePlatNode(_ node: SKNode, X gridX: CGFloat, Y gridY: CGFloat) -> Bool {
        guard var rawParam = node.userData?["param"] as? ErasablePlatLineParam else { return false }
        
        guard rawParam.gridY == gridY else { return false }
        guard rawParam.gridX <= gridX && gridX < (rawParam.gridX + rawParam.len) else { return false }
        guard rawParam.len != 1.0 else { return true }
        
        if gridX == rawParam.gridX {
            rawParam.gridX += 1.0
            rawParam.len   -= 1.0
            self.makeErasablePlatNode(param: rawParam)
        } else if gridX == (rawParam.gridX + rawParam.len - 1.0) {
            rawParam.len -= 1.0
            self.makeErasablePlatNode(param: rawParam)
        } else {
            let firstLen = gridX - rawParam.gridX
            let newParam = ErasablePlatLineParam(gridX: gridX + 1.0, gridY: gridY, len: rawParam.len - firstLen - 1.0)
            self.makeErasablePlatNode(param: newParam)
            
            rawParam.len = firstLen
            self.makeErasablePlatNode(param: rawParam)
        }
        
        return true
    }
    
    fileprivate func loadSolidPhysicsEdges(_ shapeArray: Array<Dictionary<String, Any>>) {
        let gridRatio = GameConstant.TileGridLength
        let tileYOffset = GameConstant.TileYOffset
        
        var vertPhysicsBodies = [SKPhysicsBody]()
        var horzPhysicsBodies = [SKPhysicsBody]()
        var vertEBarrierBodies = [SKPhysicsBody]()
        
        for edge in shapeArray {
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
                let point2 = CGPoint(x: point1.x, y: point1.y + len * gridRatio)
                let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
                vertPhysicsBodies.append(pp_body)
            case .verticalRightLine:
                let point1 = CGPoint(x: (posX + 1) * gridRatio + horzPadding, y: posY * gridRatio + tileYOffset)
                let point2 = CGPoint(x: point1.x, y: point1.y + len * gridRatio)
                let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
                vertPhysicsBodies.append(pp_body)
            case .groundLine: fallthrough
            case .pipeTopGroundLine:
                var point1 = CGPoint(x: posX * gridRatio, y: (posY + 1) * gridRatio + tileYOffset)
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
            case .pipeTopUpSideLine:
                let path = GameScene.makePipeUpSideLinePath(posX, posY, len)
                let pp_body = SKPhysicsBody(edgeChainFrom: path)
                horzPhysicsBodies.append(pp_body)
            case .vertLeftDummyLine:
                let param = VerticalDummyLine(side: .left, gridX: posX, gridY: posY, len: len)
                makeVerticalDummyLineNode(param: param)
            case .vertRightDummyLine:
                let param = VerticalDummyLine(side: .right, gridX: posX, gridY: posY, len: len)
                makeVerticalDummyLineNode(param: param)
            case .vertLeftEBarrierLine:
                let point1 = CGPoint(x: posX * gridRatio - 2.0, y: posY * gridRatio + tileYOffset)
                let point2 = CGPoint(x: point1.x, y: point1.y + len * gridRatio)
                let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
                vertEBarrierBodies.append(pp_body)
            case .vertRightEBarrierLine:
                let point1 = CGPoint(x: (posX + 1) * gridRatio + 2.0, y: posY * gridRatio + tileYOffset)
                let point2 = CGPoint(x: point1.x, y: point1.y + len * gridRatio)
                let pp_body = SKPhysicsBody(edgeFrom: point1, to: point2)
                vertEBarrierBodies.append(pp_body)
            case .woodPlatformLine:
                let path = GameScene.makeWoodPlatformLinePath(posX, posY, len)
                let pp_body = SKPhysicsBody(edgeLoopFrom: path)
                horzPhysicsBodies.append(pp_body)
                
                let point1 = CGPoint(x: posX * gridRatio, y: (posY + 1.0) * gridRatio + tileYOffset)
                let point2 = CGPoint(x: point1.x, y: point1.y + gridRatio)
                let pp_body1 = SKPhysicsBody(edgeFrom: point1, to: point2)
                vertEBarrierBodies.append(pp_body1)
                
                let point3 = CGPoint(x: (posX + len) * gridRatio, y: (posY + 1.0) * gridRatio + tileYOffset)
                let point4 = CGPoint(x: point3.x, y: point3.y + gridRatio)
                let pp_body2 = SKPhysicsBody(edgeFrom: point3, to: point4)
                vertEBarrierBodies.append(pp_body2)
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
            horzPhysHostNode.name = "horzPhysHostNode"
            self.rootNode.addChild(horzPhysHostNode)
        }
        
        if vertPhysicsBodies.count > 0 {
            let vertPhysHostNode = SKNode()
            let body = SKPhysicsBody(bodies: vertPhysicsBodies)
            body.categoryBitMask = PhysicsCategory.Solid
            body.isDynamic = false
            body.friction = 0.0
            body.restitution = 0.0
            vertPhysHostNode.physicsBody = body
            vertPhysHostNode.name = "vertPhysHostNode"
            self.rootNode.addChild(vertPhysHostNode)
        }
        
        if vertEBarrierBodies.count > 0 {
            let vertEBarrierPhysHostNode = SKNode()
            let body = SKPhysicsBody(bodies: vertEBarrierBodies)
            body.categoryBitMask = PhysicsCategory.EBarrier
            body.isDynamic = false
            body.friction = 0.0
            body.restitution = 0.0
            vertEBarrierPhysHostNode.physicsBody = body
            vertEBarrierPhysHostNode.name = "vertEBarrierPhysHostNode"
            self.rootNode.addChild(vertEBarrierPhysHostNode)
        }
    }
    
    fileprivate func loadBridges(_ bridges: Array<Dictionary<String, Any>>) {
        for item in bridges {
            let posX = (item["pos_x"] as! CGFloat) * GameConstant.TileGridLength
            let posY = (item["pos_y"] as! CGFloat) * GameConstant.TileGridLength
            let count = item["count"] as! Int
            let tileType = item["tileType"] as! String
            
            let bridge = FragileBridgeNode(count: count, tileType: tileType)
            bridge.position = CGPoint(x: posX, y: posY)
            movingSpriteHolder.addChild(bridge)
            
            if let posDict = item["dst_pos"] as? Dictionary<String, CGFloat> {
                let x = posDict["x"]! * GameConstant.TileGridLength + GameConstant.TileYOffset
                let y = posDict["y"]! * GameConstant.TileGridLength + GameConstant.TileYOffset
                bridge.marioDestPostion = CGPoint(x: x, y: y)
            }
        }
    }
    
    fileprivate func loadRotateFireBalls(_ rotateFireBalls: Array<Dictionary<String, Any>>) {
        for item in rotateFireBalls {
            let posX = (item["pos_x"] as! CGFloat) * GameConstant.TileGridLength
            let posY = (item["pos_y"] as! CGFloat) * GameConstant.TileGridLength
            let angle = (item["angle"] as! CGFloat) / 180.0 * π
            
            let fireBalls = RotateFireballs(startAngle: angle)
            fireBalls.position = CGPoint(x: posX, y: posY)
            movingSpriteHolder.addChild(fireBalls)
        }
    }
    
    fileprivate func loadPhysicsLadders(_ ladderArray: Array<Dictionary<String, Any>>) {
        for item in ladderArray {
            let count = item["count"] as! Int
            let posX  = item["pos_x"] as! CGFloat
            let length = item["len"] as! Int
            
            let ladder = CycleMovingLadder(posX: posX, len: length, count: count)
            movingSpriteHolder.addChild(ladder)
        }
    }
    
    fileprivate func loadSingleVertPhysicsLadders(_ ladderArray: Array<Dictionary<String, Any>>) {
        for item in ladderArray {
            let len = item["len"] as! Int
            let gridX = item["pos_x"] as! CGFloat
            let gridY = item["pos_y"] as! CGFloat
            let minY = item["min_y"] as! CGFloat
            let maxY = item["max_y"] as! CGFloat
            let downward = item["downward"] as? Bool ?? false
            
            let ladder = OneVertMovingLadder(len: len)
            movingSpriteHolder.addChild(ladder)
            
            let posX = gridX * GameConstant.TileGridLength
            let posY = gridY * GameConstant.TileGridLength + GameConstant.TileYOffset
            ladder.position = CGPoint(x: posX, y: posY)
            ladder.maxY = maxY * GameConstant.TileGridLength + GameConstant.TileYOffset
            ladder.minY = minY * GameConstant.TileGridLength + GameConstant.TileYOffset
            ladder.downward = downward
        }
    }
    
    fileprivate func loadSingleHorzPhysicsLadders(_ ladderArray: Array<Dictionary<String, Any>>) {
        for item in ladderArray {
            let len   = item["len"] as! Int
            let gridX = item["pos_x"] as! CGFloat
            let gridY = item["pos_y"] as! CGFloat
            let minX  = item["min_x"] as! CGFloat
            let maxX  = item["max_x"] as! CGFloat
            
            let ladder = OneHorzMovingLadder(len: len)
            movingSpriteHolder.addChild(ladder)
            
            let posX = gridX * GameConstant.TileGridLength
            let posY = gridY * GameConstant.TileGridLength + GameConstant.TileYOffset
            ladder.position = CGPoint(x: posX, y: posY)
            ladder.minX = minX * GameConstant.TileGridLength
            ladder.maxX = maxX * GameConstant.TileGridLength
        }
    }
    
    fileprivate func loadPirhanaPlant(_ pirhanaArray: Array<Dictionary<String, Any>>) {
        for item in pirhanaArray {
            let posDict = item["pos"] as! Dictionary<String, CGFloat>
            let posX = posDict["x"]! * GameConstant.TileGridLength
            let posY = posDict["y"]! * GameConstant.TileGridLength + GameConstant.TileYOffset
            let xStart = item["xStart"] as! CGFloat
            let xEnd = item["xEnd"] as! CGFloat
            
            let pirhanaPlant = PirhanaPlant(tileType: tileType, xStart: xStart, xEnd: xEnd)
            pirhanaPlant.position = CGPoint(x: posX, y: posY)
            
            movingSpriteHolder.addChild(pirhanaPlant)
        }
    }
    
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
    
    static fileprivate func makePipeUpSideLinePath(_ gridX: CGFloat, _ gridY: CGFloat, _ len: CGFloat) -> CGPath {
        let x1 = gridX * GameConstant.TileGridLength
        let y1 = gridY * GameConstant.TileGridLength + GameConstant.TileYOffset
        let x2 = x1 + GameConstant.TileGridLength - 2.0
        let y2 = y1
        let x3 = x2
        let y3 = y2 - 2.0
        let x4 = (gridX + len) * GameConstant.TileGridLength + 2.0
        let y4 = y3
        let x5 = x4
        let y5 = y1
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        path.addLine(to: CGPoint(x: x3, y: y3))
        path.addLine(to: CGPoint(x: x4, y: y4))
        path.addLine(to: CGPoint(x: x5, y: y5))
        
        return path.cgPath
    }
    
    static fileprivate func makeWoodPlatformLinePath(_ gridX: CGFloat, _ gridY: CGFloat, _ len: CGFloat) -> CGPath {
        let x1 = gridX * GameConstant.TileGridLength
        let y1 = gridY * GameConstant.TileGridLength + GameConstant.TileYOffset
        let x2 = x1 + len * GameConstant.TileGridLength
        let y2 = y1
        let x3 = x2
        let y3 = y2 + GameConstant.TileGridLength - 3.0
        let x4 = x3 - 2.0
        let y4 = y3 + 3.0
        let x5 = x1 + 2.0
        let y5 = y4
        let x6 = x1
        let y6 = y3
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        path.addLine(to: CGPoint(x: x3, y: y3))
        path.addLine(to: CGPoint(x: x4, y: y4))
        path.addLine(to: CGPoint(x: x5, y: y5))
        path.addLine(to: CGPoint(x: x6, y: y6))
        path.addLine(to: CGPoint(x: x1, y: y1))
        
        return path.cgPath
    }
    
    static fileprivate func readPhysicsJsonData(file name:String) -> Dictionary<String, Array<Any>> {
        let filePath = Bundle.main.path(forResource: name, ofType: "geojson")
        let url = URL(fileURLWithPath: filePath!)
        
        do {
            let data = try Data(contentsOf: url)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let jsonDict = jsonData as! Dictionary<String, Array<Any>>
            return jsonDict
        } catch let error as Error? {
            fatalError("Error when load data from bundle:", file: error as Any as! StaticString)
        }
    }
}
