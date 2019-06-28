//
//  GameScene+ContactDelegate.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/27.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    enum ContactResult {
        case Unkown
        case MarioIsA
        case MarioIsB
        case MarioPowerIsA
        case MarioPowerIsB
        case MBulletIsA
        case MBulletIsB
        case EShellIsA
        case EShellIsB
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
                    if let node = second!.node as? SKNode & MarioBumpFragileNode {
                        fragileContactNodes.append(node)
                    }
                case PhysicsCategory.Gadget:
                    let gadget = second!.node!.userData?["param"] as! SceneGadget
                    if gadget.type == .vert {
                        mario.checkVertGadget(gadget: gadget)
                    }
                case PhysicsCategory.EShell: fallthrough
                case PhysicsCategory.Evildoer:
                    if let enemy = second!.node as? EnemiesBaseNode {
                        enemy.contactWithMario(point: contact.contactPoint, normal: contact.contactNormal)
                    }
                default:
                    break
                }
            } else if first.categoryBitMask == PhysicsCategory.MarioPower {
                if abs(contact.contactNormal.dx) > 0.5 {
                    if let node = first.node as? SKNode & SpriteReverseMovement {
                        node.reverseMovement(contact.contactNormal)
                    }
                } else if contact.contactNormal.dy > 0.5 {
                    if let star = first.node as? StarSprite {
                        star.fallToGround()
                    }
                }
            } else if first.categoryBitMask == PhysicsCategory.MBullet {
                guard let bullet = first.node as? BulletSprite else { return }
                if let enemy = second!.node as? EnemiesBaseNode {
                    enemy.hitByBullet()
                    bullet.hitEnemy()
                } else if abs(contact.contactNormal.dy) > 0.25 {
                    bullet.fallToGround()
                } else if abs(contact.contactNormal.dx) > 0.5 {
                    bullet.hitSolidPhysicsBody()
                }
            } else if first.categoryBitMask == PhysicsCategory.EShell {
                guard let enemy = second?.node as? EnemiesBaseNode else { return }
                if second!.categoryBitMask == PhysicsCategory.Evildoer {
                    enemy.hitByBullet()
                } else if second!.categoryBitMask == PhysicsCategory.EShell {
                    enemy.hitByBullet()
                    if let enemy2 = first.node as? EnemiesBaseNode {
                        enemy2.hitByBullet()
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
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.EShell {
            return (contact.bodyA, contact.bodyB, .EShellIsA)
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.EShell {
            return (contact.bodyB, contact.bodyA, .EShellIsB)
        } else {
            return (nil, nil, .Unkown)
        }
    }
}
