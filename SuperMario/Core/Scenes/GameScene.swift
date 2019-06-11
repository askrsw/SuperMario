//
//  GameScene.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/5.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var sceneWidth: CGFloat  = 256.0
    var scaleFactor: CGFloat = 1.0
    
    var rootNode: SKNode?
    let brickSpriteHolder = SKNode()
    let goldSpriteHolder  = SKNode()
    
    let mario = GameManager.instance.mario
    let dirButton = DirectionButton()
    let buttonA = ActionButton(actionType: .A)
    let buttonB = ActionButton(actionType: .B)
    let buttonC = ActionButton(actionType: .C)
    let buttonD = ActionButton(actionType: .D)
    
    fileprivate var lastUpdateTime: TimeInterval = 0.0
    var fragileContactNodes: Array<SKNode & MarioBumpFragileNode> = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Game cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        scaleMode = .resizeFill
        physicsWorld.contactDelegate = self
        
        sceneWidth = userData?["SceneWidth"] as! CGFloat
        
        rootNode = childNode(withName: "root")
        if let bkRef = rootNode?.childNode(withName: "scene_reference") {
            bkRef.removeFromParent()
        }
        
        if let marioRef = rootNode?.childNode(withName: "mario") {
            let y = marioRef.position.y
            let x = marioRef.position.x
            mario.position = CGPoint(x: x, y: y)
            marioRef.removeFromParent()
        }
        
        rootNode?.addChild(mario)
        
        adjustSceneSize(view)
        setCamera()
        loadSolidPhysicsEdge()
        loadBrickGridTile()
        loadGoldGridTile()
        
#if DEBUG
        drawColumnNumber()
#endif
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat = lastUpdateTime > 0 ? CGFloat(currentTime - lastUpdateTime) : 0.0
        mario.update(deltaTime: dt)
        lastUpdateTime = currentTime
    }
    
    override func didSimulatePhysics() {
        postPhysicsProcess()
    }
    
    // MARK: helper method
    
    fileprivate func adjustSceneSize(_ view: SKView) {
        let scaleFactor = view.frame.height / GameConstant.OriginalSceneHeight
        size = view.frame.size
        self.scaleFactor = scaleFactor
    }
}
