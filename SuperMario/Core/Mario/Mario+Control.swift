//
//  Mario+Control.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/18.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension Mario {
    
    func directionAction(_ dir: UInt32) {
        guard pipingTime == false else { return }
        
        downWard = false
        
        switch dir {
        case ButtonDirectionCategory.Left:
            speedX = true
            marioFacing = .backward
        case ButtonDirectionCategory.Up:
            speedX = false
        case ButtonDirectionCategory.Left | ButtonDirectionCategory.Up:
            speedX = true
            marioFacing = .backward
        case ButtonDirectionCategory.Right:
            speedX = true
            marioFacing = .forward
        case ButtonDirectionCategory.Right | ButtonDirectionCategory.Up:
            speedX = true
            marioFacing = .forward
        case ButtonDirectionCategory.Down:
            downWard = true
            speedX = false
        case ButtonDirectionCategory.Right | ButtonDirectionCategory.Down:
            speedX = true
            marioFacing = .forward
            downWard = true
        case ButtonDirectionCategory.Left | ButtonDirectionCategory.Down:
            speedX = true
            marioFacing = .backward
            downWard = true
        case ButtonDirectionCategory.None:
            speedX = false
        default:
            break;
        }
    }
    
    // acceleration
    func turbo(_ v: Bool) {
        moveFaster = v
    }
    
    func jump(_ v: Bool) {
        guard pipingTime == false else { return }
    }
    
    func jumpHigh() {
        guard pipingTime == false else { return }
        guard jumping == false else { return }
        guard let physicsBody = physicsBody else { return }
        let verticalForce = physicsBody.mass * 500.0
        physicsBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
    
    func fire() {
        guard pipingTime == false else { return }
        if marioPower == .C  && marioMoveState != .crouching {
            if let holder = GameManager.instance.currentScene?.bulletSpriteHolder {
                let bullet = BulletSprite(faceTo: marioFacing, marioPos: position)
                holder.addChild(bullet)
                
                AudioManager.play(sound: .FireBullet)
            }
        }
    }
}
