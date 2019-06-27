//
//  GameScene+MarioShapeshifting.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/27.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene: MarioShapeshifting {
    
    func marioWillShapeshift() {
        beforeMarioShapeshiftProcess(goldSpriteHolder)
        beforeMarioShapeshiftProcess(coinSpriteHolder)
        beforeMarioShapeshiftProcess(movingSpriteHolder)
        beforeMarioShapeshiftProcess(bulletSpriteHolder)
        
        if let enemiesHolder = enemySpriteHolder {
            beforeMarioShapeshiftProcess(enemiesHolder)
        }
    }
    
    func marioDidShapeshift() {
        afterMarioShapeshiftProcess(goldSpriteHolder)
        afterMarioShapeshiftProcess(coinSpriteHolder)
        afterMarioShapeshiftProcess(movingSpriteHolder)
        afterMarioShapeshiftProcess(bulletSpriteHolder)
        
        if let enemiesHolder = enemySpriteHolder {
            afterMarioShapeshiftProcess(enemiesHolder)
        }
    }
    
    // MARK: Help method
    
    private func beforeMarioShapeshiftProcess(_ holder: SKNode) {
        holder.enumerateChildNodes(withName: "*") { (node, _) in
            if let tNode = node as? MarioShapeshifting {
                tNode.marioWillShapeshift()
            }
        }
    }
    
    private func afterMarioShapeshiftProcess(_ holder: SKNode) {
        holder.enumerateChildNodes(withName: "*") { (node, _) in
            if let tNode = node as? MarioShapeshifting {
                tNode.marioDidShapeshift()
            }
        }
    }
}
