//
//  GameScene.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/5.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var scaleFactor: CGFloat = 1.0
    
    var rootNode: SKNode?
    let brickSpriteHolder  = SKNode()
    let goldSpriteHolder   = SKNode()
    let coinSpriteHolder   = SKNode()
    let movingSpriteHolder = SKNode()
    let staticSpriteHolder = SKNode()
    let bulletSpriteHolder = SKNode()
    let erasablePlatHolder = SKNode()
    let gadgetNodeHolder   = SKNode()
    
    let mario = GameManager.instance.mario
    let dirButton = DirectionButton()
    let buttonA = ActionButton(actionType: .A)
    let buttonB = ActionButton(actionType: .B)
    let buttonC = ActionButton(actionType: .C)
    let buttonD = ActionButton(actionType: .D)
    
    fileprivate var lastUpdateTime: TimeInterval = 0.0
    var fragileContactNodes: Array<SKNode & MarioBumpFragileNode> = []
    
    var halfCameraViewWidth: CGFloat = 256.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        GameAnimations.updateStoredAnimations(self.tileType)
        initializeScene()
    }
    
    // MARK: Game cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        GameManager.instance.currentScene = self
        
        mario.move(toParent: self.rootNode!)
        
        buttonA.actived = false
        buttonB.actived = false
        
        GameAnimations.updateStoredAnimations(self.tileType)
        
        playBackgroundMusc()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat = lastUpdateTime > 0 ? CGFloat(currentTime - lastUpdateTime) : 0.0
        
        mario.update(deltaTime: dt)
        
        movingSpriteHolder.enumerateChildNodes(withName: "*") { (node, _) in
            if let movingNode = node as? MovingSpriteNode {
                movingNode.update(deltaTime: dt)
            }
        }
        
        bulletSpriteHolder.enumerateChildNodes(withName: "*") { (node, _) in
            if let movingNode = node as? MovingSpriteNode {
                movingNode.update(deltaTime: dt)
            }
        }
        
        lastUpdateTime = currentTime
    }
    
    override func didSimulatePhysics() {
        postPhysicsProcess()
    }
    
    // MARK: helper method
    
    fileprivate func initializeScene() {
        scaleMode = .resizeFill
        physicsWorld.contactDelegate = self
        
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
        
        rootNode!.addChild(coinSpriteHolder)
        rootNode!.addChild(goldSpriteHolder)
        rootNode!.addChild(brickSpriteHolder)
        rootNode!.addChild(movingSpriteHolder)
        rootNode!.addChild(staticSpriteHolder)
        rootNode!.addChild(bulletSpriteHolder)
        rootNode!.addChild(erasablePlatHolder)
        rootNode!.addChild(gadgetNodeHolder)
        
        coinSpriteHolder.name   = "coinSpriteHolder"
        goldSpriteHolder.name   = "goldSpriteHolder"
        brickSpriteHolder.name  = "brickSpriteHolder"
        movingSpriteHolder.name = "movingSpriteHolder"
        staticSpriteHolder.name = "staticSpriteHolder"
        bulletSpriteHolder.name = "bulletSpriteHolder"
        erasablePlatHolder.name = "erasablePlatHolder"
        gadgetNodeHolder.name   = "gadgetNodeHolder"
        
        loadPhysicsDesc()
        loadBrickGridTile()
        loadGoldGridTile()
        loadCoinGridTile()
        
        adjustSceneSize()
        setCamera()
        
    #if DEBUG
        drawColumnNumber()
    #endif
    }
    
    fileprivate func adjustSceneSize() {
        let height = UIScreen.main.bounds.height
        let scaleFactor = height / GameConstant.OriginalSceneHeight
        size = UIScreen.main.bounds.size
        self.scaleFactor = scaleFactor
    }
}
