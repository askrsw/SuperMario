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
        guard !died else { return }
        guard !pipingTime else { return }
        switch dir {
        case ButtonDirectionCategory.Left:
            speedX = true
            downWard = false
            marioFacing = .backward
        case ButtonDirectionCategory.Up:
            speedX = false
            downWard = false
        case ButtonDirectionCategory.Left | ButtonDirectionCategory.Up:
            speedX = true
            downWard = false
            marioFacing = .backward
        case ButtonDirectionCategory.Right:
            speedX = true
            downWard = false
            marioFacing = .forward
        case ButtonDirectionCategory.Right | ButtonDirectionCategory.Up:
            speedX = true
            downWard = false
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
            downWard = false
        default:
            break;
        }
    }
    
    // acceleration
    func turbo(_ v: Bool) {
        guard !died else { return }
        moveFaster = v
    }
    
    func jumpHigh() {
        guard !died else { return }
        guard !pipingTime else { return }
        guard !jumping else { return }
        guard let physicsBody = physicsBody else { return }
        let verticalForce = physicsBody.mass * 475.0
        physicsBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
    
    func fire() {
        guard !died else { return }
        guard !pipingTime else { return }
        if marioPower == .C  && marioMoveState != .crouching {
            let bullet = BulletSprite(faceTo: marioFacing, marioPos: position)
            GameScene.addBullet(bullet)
            AudioManager.play(sound: .FireBullet)
        }
    }
    
    func bounceALittle() {
        guard let physicsBody = physicsBody else { return }
        let verticalForce = physicsBody.mass * 225.0
        physicsBody.applyImpulse(CGVector(dx: 0.0, dy: verticalForce))
    }
}
