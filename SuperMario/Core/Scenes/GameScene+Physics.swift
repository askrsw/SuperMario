//
//  GameScene+Physics.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/11.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let (marioBody, otherBody) = distinguishTwoBody(contact)
        if marioBody != nil {
            switch otherBody!.categoryBitMask {
            case PhysicsCategory.GoldMetal: fallthrough
            case PhysicsCategory.Brick:
                if contact.contactNormal.dy > 0.0 {
                    let node = otherBody!.node as! SKNode & MarioBumpFragileNode
                    fragileContactNodes.append(node)
                }
            default:
                break
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
    
    fileprivate func distinguishTwoBody(_ contact: SKPhysicsContact) -> (SKPhysicsBody?, SKPhysicsBody?) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.Mario {
            return (contact.bodyA, contact.bodyB)
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.Mario {
            return (contact.bodyB, contact.bodyA)
        } else {
            return (nil, nil)
        }
    }
}
