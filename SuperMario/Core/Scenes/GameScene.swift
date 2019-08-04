//
//  GameScene.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/5.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    static var currentInstance: GameScene?
    
    var scaleFactor: CGFloat = 1.0
    
    var rootNode: SKNode!
    var cameraRootNode = SKNode()
    let brickSpriteHolder  = SKNode()
    let goldSpriteHolder   = SKNode()
    let coinSpriteHolder   = SKNode()
    let movingSpriteHolder = SKNode()
    let staticSpriteHolder = SKNode()
    let bulletSpriteHolder = SKNode()
    let erasablePlatHolder = SKNode()
    let gadgetNodeHolder   = SKNode()
    var enemySpriteHolder: SKNode?
    let flyScoreHolder = SKNode()
    let soundPlayNode  = SKNode()
    
#if DEBUG
    let horzIndexLabelHolder = SKNode()
    let vertIndexLabelHolder = SKNode()
#endif
    
    let mario = GameManager.instance.mario
    let dirButton = DirectionButton()
    let buttonA = ActionButton(actionType: .A)
    let buttonB = ActionButton(actionType: .B)
    let buttonC = ActionButton(actionType: .C)
    let buttonD = ActionButton(actionType: .D)
    
    fileprivate var lastUpdateTime: TimeInterval = 0.0
    var fragileContactNodes: Array<SKNode & MarioBumpFragileNode> = []
    var tileTypeDict: Dictionary<Int, TileGridType> = [:]
    
    var halfCameraViewWidth: CGFloat = 256.0
    var halfScaledSceneWdith: CGFloat = 256.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeScene()
    }
    
    // MARK: Game cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        GameScene.currentInstance = self
        
        mario.move(toParent: self.rootNode)
        GameHUD.instance.move(toParent: self.cameraRootNode)
        GameHUD.instance.position = .zero
        
        buttonA.actived = false
        buttonB.actived = false
        
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
        
        enemySpriteHolder?.enumerateChildNodes(withName: "*") { (node, _) in
            if let enemy = node as? EnemiesBaseNode {
                enemy.update(deltaTime: dt)
            }
        }
        
        lastUpdateTime = currentTime
    }
    
    override func didSimulatePhysics() {
        postPhysicsProcess()
        
        enemySpriteHolder?.enumerateChildNodes(withName: "*") { (node, _) in
            if let enemy = node as? EnemiesBaseNode {
                enemy.postPhysicsProcess()
            }
        }
    }
    
    // MARK: Helper method
    
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
            mario.position = CGPoint(x: x, y: y + GameConstant.TileGridLength)
            marioRef.removeFromParent()
        }
        
        rootNode.addChild(coinSpriteHolder)
        rootNode.addChild(goldSpriteHolder)
        rootNode.addChild(brickSpriteHolder)
        rootNode.addChild(movingSpriteHolder)
        rootNode.addChild(staticSpriteHolder)
        rootNode.addChild(bulletSpriteHolder)
        rootNode.addChild(erasablePlatHolder)
        rootNode.addChild(gadgetNodeHolder)
        rootNode.addChild(flyScoreHolder)
        rootNode.addChild(soundPlayNode)
        
        coinSpriteHolder.name   = "coinSpriteHolder"
        goldSpriteHolder.name   = "goldSpriteHolder"
        brickSpriteHolder.name  = "brickSpriteHolder"
        movingSpriteHolder.name = "movingSpriteHolder"
        staticSpriteHolder.name = "staticSpriteHolder"
        bulletSpriteHolder.name = "bulletSpriteHolder"
        erasablePlatHolder.name = "erasablePlatHolder"
        gadgetNodeHolder.name   = "gadgetNodeHolder"
        flyScoreHolder.name = "flyScoreHolder"
        soundPlayNode.name = "soundPlayNode"
        
        flyScoreHolder.zPosition = 1001
        
        enemySpriteHolder = rootNode.childNode(withName: "Enemies")
        enemySpriteHolder?.name = "enemySpriteHolder"
        enemySpriteHolder?.zPosition = 120
        
        loadPhysicsDesc()
        loadBrickGridTile()
        loadGoldGridTile()
        loadCoinGridTile()
        
        adjustSceneSize()
        setCamera()
        
    #if DEBUG
        rootNode.addChild(horzIndexLabelHolder)
        cameraRootNode.addChild(vertIndexLabelHolder)
        
        vertIndexLabelHolder.zPosition = 20
        horzIndexLabelHolder.zPosition = 20
        
        drawColumnNumber()
    #endif
    }
    
    fileprivate func adjustSceneSize() {
        let height = UIScreen.main.bounds.height
        let scaleFactor = height / GameConstant.OriginalSceneHeight
        size = UIScreen.main.bounds.size
        self.scaleFactor = scaleFactor
        
        self.halfScaledSceneWdith = size.width / scaleFactor * 0.5
    }
}
