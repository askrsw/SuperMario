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
    
    // MARK: Helper method
    
    private func ErasePlatPhysicsNode(_ pos: CGPoint) {
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
    
    private func makeErasablePlatPhysics(_ pos1: CGPoint, _ pos2: CGPoint) -> SKPhysicsBody {
        let body = SKPhysicsBody(edgeFrom: pos1, to: pos2)
        body.categoryBitMask = PhysicsCategory.erasablePlat
        body.collisionBitMask = (body.collisionBitMask) & ~PhysicsCategory.erasablePlat
        body.isDynamic = false
        body.friction = 0.0
        body.restitution = 0.0
        
        return body
    }
    
    private func rebuildErasePlatNode(_ node: SKNode, X gridX: CGFloat, Y gridY: CGFloat) {
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
                case PhysicsCategory.MarioPower:
                    let node = second!.node as! SKNode & MarioBumpFragileNode
                    fragileContactNodes.append(node)
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
            }
        }
    }
    
    // MARK: Interface
    
    func postPhysicsProcess() {
        if fragileContactNodes.count == 1 {
            fragileContactNodes.first!.marioBump()
            
            fragileContactNodes.removeAll()
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
            
            fragileContactNodes.removeAll()
        }
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
        } else {
            return (nil, nil, .Unkown)
        }
    }
}
