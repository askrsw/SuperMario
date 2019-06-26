//
//  GameScene+Physics.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

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

extension GameScene {
    func makeErasablePlatNode(param: ErasablePlatLineParam) {
        let node = SKNode()
        node.physicsBody = makeErasablePlatPhysics(param.position1, param.position2)
        node.userData = NSMutableDictionary(dictionary: ["param" : param])
        
        erasablePlatHolder.addChild(node)
    }
    
    func ErasePlatNode(_ pos: CGPoint) {
        ErasePlatPhysicsNode(pos)
    }
    
    func loadPhysicsDesc() {
        let (shapeArray, gadgetArray) = GameScene.readPhysicsJsonData(file: physicsDescFileName)
        
        loadSolidPhysicsEdges(shapeArray)
        
        if let gadgets = gadgetArray {
            loadPhysicsGadets(gadgets)
        }
    }
    
    // MARK: Helper method
    
    fileprivate func ErasePlatPhysicsNode(_ pos: CGPoint) {
        let unitL = GameConstant.TileGridLength
        let rect = CGRect(x: pos.x - 0.5, y: pos.y, width: 1.0, height: unitL)
        
        // Warning: Very Important when you can not delete or edit current
        //          physics body during the physicsWorld.enumerateBodies method.
        //          Or you will get a confused result that likes a bug. For
        //          this issue I have debugged and tested about one and a half days.
        var willBeRemovedNodes: Array<SKNode> = []
        
        physicsWorld.enumerateBodies(in: rect) { [weak self] (body, _) in
            if body.categoryBitMask == PhysicsCategory.erasablePlat {
                if let node = body.node {
                    let gridX: CGFloat = floor(pos.x / unitL)
                    let gridY: CGFloat = round((pos.y - unitL * 0.25) / unitL)
                    self?.rebuildErasePlatNode(node, X: gridX, Y: gridY)
                    
                    willBeRemovedNodes.append(node)
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
        body.categoryBitMask = PhysicsCategory.erasablePlat
        body.collisionBitMask = (body.collisionBitMask) & ~PhysicsCategory.erasablePlat
        body.isDynamic = false
        body.friction = 0.0
        body.restitution = 0.0
        
        return body
    }
    
    fileprivate func rebuildErasePlatNode(_ node: SKNode, X gridX: CGFloat, Y gridY: CGFloat) {
        guard var rawParam = node.userData?["param"] as? ErasablePlatLineParam else { return }
        
        guard rawParam.gridY == gridY else { return }
        guard rawParam.len != 1.0 else { return }
        
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
    }
    
    fileprivate func loadSolidPhysicsEdges(_ shapeArray: Array<Dictionary<String, Any>>) {
        let gridRatio = GameConstant.TileGridLength
        let tileYOffset = GameConstant.TileYOffset
        
        var vertPhysicsBodies = [SKPhysicsBody]()
        var horzPhysicsBodies = [SKPhysicsBody]()
        
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
            self.rootNode.addChild(vertPhysHostNode)
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
    
    static fileprivate func readPhysicsJsonData(file name:String) -> (Array<Dictionary<String, Any>>, Array<Dictionary<String, Any>>?) {
        let filePath = Bundle.main.path(forResource: name, ofType: "geojson")
        let url = URL(fileURLWithPath: filePath!)
        
        do {
            let data = try Data(contentsOf: url)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let jsonDict = jsonData as! Dictionary<String, Array<Any>>
            let physicalShapes = jsonDict["shapes"] as! Array<Dictionary<String, Any>>
            let physicalGadgets = jsonDict["gadgetes"] as? Array<Dictionary<String, Any>>
            return (physicalShapes, physicalGadgets)
        } catch let error as Error? {
            fatalError("Error when load data from bundle:", file: error as Any as! StaticString)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    enum ContactResult {
        case Unkown
        case MarioIsA
        case MarioIsB
        case MarioPowerIsA
        case MarioPowerIsB
        case MBulletIsA
        case MBulletIsB
        case EnemyIsA
        case EnemyIsB
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let (first, second, result) = distinguishTwoBody(contact)
        if let first = first {
            if first.categoryBitMask == PhysicsCategory.Mario {
                switch second!.categoryBitMask {
                case PhysicsCategory.GoldMetal: fallthrough
                case PhysicsCategory.Brick:
                    if abs(contact.contactNormal.dx) < 10e-2 {
                        if (result == .MarioIsA && contact.contactNormal.dy > 0.0) || (result == .MarioIsB && contact.contactNormal.dy < 0.0) {
                            let node = second!.node as! SKNode & MarioBumpFragileNode
                            fragileContactNodes.append(node)
                        }
                    }
                case PhysicsCategory.MarioPower: fallthrough
                case PhysicsCategory.Coin:
                    let node = second!.node as! SKNode & MarioBumpFragileNode
                    fragileContactNodes.append(node)
                case PhysicsCategory.Gadget:
                    let gadget = second!.node!.userData?["param"] as! SceneGadget
                    if gadget.type == .vert {
                        mario.checkVertGadget(gadget: gadget)
                    }
                case PhysicsCategory.Evildoer:
                    if let _ = second!.node as? EnemiesBaseNode {
                        //enemy.contactWithMario(contact)
                    }
                default:
                    break
                }
            } else if first.categoryBitMask == PhysicsCategory.MarioPower {
                if abs(contact.contactNormal.dx) > 0.5 {
                    let node = first.node as! SKNode & SpriteReverseMovement
                    node.reverseMovement(contact.contactNormal)
                } else if contact.contactNormal.dy > 0.5 {
                    if let star = first.node as? StarSprite {
                        star.fallToGround()
                    }
                }
            } else if first.categoryBitMask == PhysicsCategory.MBullet {
                guard let bullet = first.node as? BulletSprite else { return }
                if abs(contact.contactNormal.dy) > 0.25 {
                    bullet.fallToGround()
                } else if abs(contact.contactNormal.dx) > 0.5 {
                    bullet.hitSolidPhysicsBody()
                }
            } else if first.categoryBitMask == PhysicsCategory.Evildoer {
                guard let enemy = first.node as? EnemiesBaseNode else { return }
                if (second!.categoryBitMask & (PhysicsCategory.Solid | PhysicsCategory.GoldMetal | PhysicsCategory.Brick)) != PhysicsCategory.None {
                    if abs(contact.contactNormal.dx) > 0.5 && abs(contact.contactNormal.dy) < 0.1 {
                        needFlippingEnemies.insert(enemy)
                    }
                } else if second!.categoryBitMask == PhysicsCategory.Evildoer {
                    if abs(contact.contactNormal.dx) > 0.5 && abs(contact.contactNormal.dy) < 0.1 {
                        enemy.collideWithEnemy()
                        needFlippingEnemies.insert(enemy)
                    }
                }
            }
        }
    }
    
    // MARK: Interface
    
    func postPhysicsProcess() {
        if fragileContactNodes.count == 1 {
            fragileContactNodes.first!.marioBump()
        } else if fragileContactNodes.count > 1 {
            var nearestIndex = -1
            var nearestDistance:CGFloat = 1000.0
            
            for index in 0 ..< fragileContactNodes.count {
                let node = fragileContactNodes[index]
                let dist = abs(node.convert(mario.position, from: self).x)
                if dist < nearestDistance {
                    nearestDistance = dist
                    nearestIndex = index
                }
            }
            
            if nearestIndex != -1 {
                fragileContactNodes[nearestIndex].marioBump()
            }
        }
        fragileContactNodes.removeAll()
        
        for enemy in needFlippingEnemies {
            enemy.faceLeft = !enemy.faceLeft
        }
        needFlippingEnemies.removeAll()
    }
    
    // MARK: Helper Method
    
    fileprivate func distinguishTwoBody(_ contact: SKPhysicsContact) -> (SKPhysicsBody?, SKPhysicsBody?, ContactResult) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.Mario {
            return (contact.bodyA, contact.bodyB, .MarioIsA)
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.Mario {
            return (contact.bodyB, contact.bodyA, .MarioIsB)
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.MarioPower {
            return (contact.bodyA, contact.bodyB, .MarioPowerIsA)
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.MarioPower {
            return (contact.bodyB, contact.bodyA, .MarioPowerIsB)
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.MBullet {
            return (contact.bodyA, contact.bodyB, .MBulletIsA)
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.MBullet {
            return (contact.bodyB, contact.bodyA, .MBulletIsB)
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.Evildoer {
            return (contact.bodyA, contact.bodyB, .EnemyIsA)
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.Evildoer {
            return (contact.bodyB, contact.bodyA, .EnemyIsB)
        } else {
            return (nil, nil, .Unkown)
        }
    }
}
