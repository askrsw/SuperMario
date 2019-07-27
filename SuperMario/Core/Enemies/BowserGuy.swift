//
//  BowserGuy.swift
//  SuperMario
//
//  Created by haharsw on 2019/7/19.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

fileprivate enum BowserMoveState {
    case moveForward
    case moveBackward
    case stay1
    case stay2
    case ossified
}

class BowserGuy: SKSpriteNode {
    let positionX1: CGFloat = 160.0
    let positionX2: CGFloat = 60.0
    let constStayTime: CGFloat = 1.0
    let moveSpeed: CGFloat  = 40.0
    let normalShootSkip: CGFloat = 1.5
    let hurryShootSkip: CGFloat = 0.15
    let animation: SKAction
    
    weak var bridge: FragileBridgeNode!
    
    var lifeLeft: Int = 5
    var shootTime: CGFloat = 0.0
    var jumping:  Bool = false
    var jumped:   Bool = false
    var stayTime: CGFloat = 0.0
    fileprivate var moveState: BowserMoveState = .stay1
    var active: Bool = false {
        didSet {
            if oldValue != active {
                if active {
                    run(animation, withKey: "animation")
                } else {
                    removeAction(forKey: "animation")
                }
            }
        }
    }
    
    var basePositionY: CGFloat = 0
    override var position: CGPoint {
        didSet {
            if basePositionY == 0 {
                basePositionY = position.y
            }
        }
    }
    
    init() {
        let texName1 = "bowser_a_1"
        let tex1 = SKTexture(imageNamed: texName1)
        
        let texName2 = "bowser_a_2"
        let tex2 = SKTexture(imageNamed: texName2)
        
        let texName3 = "bowser_a_3"
        let tex3 = SKTexture(imageNamed: texName3)
        
        let texName4 = "bowser_a_4"
        let tex4 = SKTexture(imageNamed: texName4)
        
        let tempAnimation = SKAction.animate(with: [tex1, tex2, tex3, tex4], timePerFrame: 0.2)
        self.animation = SKAction.repeatForever(tempAnimation)
        
        super.init(texture: tex1, color: .clear, size: tex1.size())
        physicsBody = createPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func ossify() {
        if moveState != .ossified {
            moveState = .ossified
            removeAction(forKey: "animation")
            physicsBody?.categoryBitMask  = PhysicsCategory.None
            physicsBody?.collisionBitMask = PhysicsCategory.None
            physicsBody?.contactTestBitMask = PhysicsCategory.None
            
            let upForce = CGVector(dx: 0.0, dy: physicsBody!.mass * 300.0)
            physicsBody?.applyImpulse(upForce)
            
            AudioManager.play(sound: .BossDead)
        }
    }
    
    func hitByBullet() -> Bool {
        lifeLeft -= 1
        if lifeLeft == 0 {
            ossify()
            
            let pos = GameScene.currentInstance!.convert(position, from: self.parent!)
            GameScene.addScore(score: ScoreConfig.shootBowser, pos: pos)
        }
        
        return true
    }
    
    func contactWithMario() {
        if moveState != .ossified && !GameManager.instance.mario.powerfull {
            GameManager.instance.mario.collideWithEnemy()
        }
    }
    
    func update(deltaTime dt: CGFloat) {
        guard dt < 0.1 else { return }
        
        switch moveState {
        case .stay1: fallthrough
        case .stay2:
            if !jumping {
                stayTime += dt
                if stayTime >= constStayTime {
                    if !jumped {
                        let upForce = physicsBody!.mass * 200
                        let force = CGVector(dx: 0.0, dy: upForce)
                        physicsBody?.applyImpulse(force)
                        jumped = true
                        jumping = true
                    } else {
                        if moveState == .stay1 {
                            moveState = .moveForward
                        } else {
                            moveState = .moveBackward
                        }
                    }
                }
            } else {
                if abs(physicsBody!.velocity.dy) < 0.1 {
                    if position.y < basePositionY + GameConstant.TileGridLength {
                        jumping = false
                        stayTime = 0.0
                    }
                }
            }
        case .moveForward:
            physicsBody?.velocity = CGVector(dx: -moveSpeed, dy: 0.0)
            if position.x <= positionX2 {
                position.x = positionX2
                moveState = .stay2
                physicsBody?.velocity = .zero
                jumping = false
                jumped = false
                stayTime = 0.0
            }
        case .moveBackward:
            physicsBody?.velocity = CGVector(dx: moveSpeed, dy: 0.0)
            if position.x >= positionX1 {
                position.x = positionX1
                moveState = .stay1
                physicsBody?.velocity = .zero
                jumping = false
                jumped = false
                stayTime = 0.0
            }
        case .ossified:
            break
        }
        
        if moveState != .ossified {
            let shootSkip = jumping ? hurryShootSkip : normalShootSkip
            shootTime += dt
            if shootTime >= shootSkip {
                shootTime = 0.0
                let pos = GameScene.currentInstance!.convert(position, from: self.parent!)
                let ebullet = EBulletSprite(faceTo: -1.0, shootPos: pos)
                GameScene.addBullet(ebullet)
                ebullet.applyImpulse()
            }
        } else {
            if position.y < -self.size.height {
                removeFromParent()
                bridge.boss = nil
            }
        }
    }
    
    // MARK: Help Method
    
    func createPhysicsBody() -> SKPhysicsBody {
        let unitL = GameConstant.TileGridLength
        let point1 = CGPoint(x: -unitL, y: unitL * 0.6)
        let point2 = CGPoint(x: -unitL * 0.5, y: unitL)
        let point3 = CGPoint(x: -unitL * 0.25, y: unitL)
        let point4 = CGPoint(x: unitL * 0.1, y: unitL * 0.5)
        let point5 = CGPoint(x: unitL * 0.5, y: unitL * 0.5)
        let point6 = CGPoint(x: unitL, y: 0)
        let point7 = CGPoint(x: unitL, y: -unitL)
        let point8 = CGPoint(x: unitL * 0.25, y: -unitL)
        let point9 = CGPoint(x: -unitL * 0.5, y: 0)
        let path = UIBezierPath()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point4)
        path.addLine(to: point5)
        path.addLine(to: point6)
        path.addLine(to: point7)
        path.addLine(to: point8)
        path.addLine(to: point9)
        path.addLine(to: point1)
        
        let body = SKPhysicsBody(polygonFrom: path.cgPath)
        body.allowsRotation = false
        body.categoryBitMask = PhysicsCategory.EPirhana
        body.contactTestBitMask = PhysicsCategory.Mario | PhysicsCategory.MBullet
        body.collisionBitMask = PhysicsCategory.Static | PhysicsCategory.MBullet
        body.restitution = 0.0
        body.friction = 1.0
        
        return body
    }
}
