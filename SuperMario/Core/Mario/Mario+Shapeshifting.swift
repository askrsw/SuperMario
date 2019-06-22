//
//  Mario+Shapeshifting.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/13.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension Mario {
    
    func powerUpToB() {
        if marioPower == .A {
            shapeshifting = true
            
            let backupVelocity = physicsBody!.velocity
            
            powerfull = false
            physicsBody = nil
            removeAllActions()
            
            let repeatCount = Int(GameConstant.powerupSoundDuration / GameConstant.marioFlashTimeUnit / 2)
            let tex = SKTexture(imageNamed: "mario_b_normal1")
            let texAction = SKAction.setTexture(tex, resize: true)
            let flashAction = SKAction.repeat(GameAnimations.marioFlashAnimation, count: repeatCount)
            let blockAction = SKAction.run { [weak self] in
                self?.marioPower = .B
                self?.physicsBody = self?.makePhysicsBody(backupVelocity)
                self?.shapeshifting = false
            }
            let action = SKAction.sequence([texAction, flashAction, blockAction])
            
            self.position = CGPoint(x: position.x, y: position.y + GameConstant.TileGridLength * 0.5)
            self.run(action)
            
            AudioManager.play(sound: .Powerup)
        } else {
            AudioManager.play(sound: .AddLife)
        }
    }
    
    func powerUpToC() {
        if marioPower == .B {
            shapeshifting = true
            
            let backupVelocity = physicsBody!.velocity
            
            powerfull = false
            physicsBody = nil
            removeAllActions()
            
            let repeatCount = Int(GameConstant.powerupSoundDuration / GameConstant.marioFlashTimeUnit / 2)
            let tex = SKTexture(imageNamed: "mario_c_normal1")
            let texAction = SKAction.setTexture(tex, resize: true)
            let flashAction = SKAction.repeat(GameAnimations.marioFlashAnimation, count: repeatCount)
            let blockAction = SKAction.run { [weak self] in
                self?.marioPower = .C
                self?.physicsBody = self?.makePhysicsBody(backupVelocity)
                self?.shapeshifting = false
            }
            let action = SKAction.sequence([texAction, flashAction, blockAction])
            
            self.run(action)
            
            AudioManager.play(sound: .Powerup)
        } else {
            AudioManager.play(sound: .AddLife)
        }
    }
}
