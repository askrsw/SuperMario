//
//  GameManager.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/23.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameManager {
    static let instance = GameManager()
    
    let allSceneNames = [ "Scene1_1",
                          "Scene1_2" ]
    
    let mario    = Mario()
    let gameView = SKView(frame: UIScreen.main.bounds)
    
    var allScenes: [String: GameScene] = [:]
    
    private init() {
        
    #if DEBUG
        gameView.showsFPS       = true
        gameView.showsNodeCount = true
        gameView.showsQuadCount = true
        gameView.showsPhysics   = true
        gameView.showsFields    = true
    #endif
        
        gameView.ignoresSiblingOrder       = true
        gameView.shouldCullNonVisibleNodes = true
        gameView.isMultipleTouchEnabled    = true  //very important
        
        let _ = GameHUD.instance
    }
    
    func start() {
        let sceneName = allSceneNames[1]
        let scene = fetchScene(sceneName: sceneName)
        gameView.presentScene(scene)
    }
    
    func enterScene(_ param: SceneGadget) {
        let scene = fetchScene(sceneName: param.destSceneName)
        gameView.presentScene(scene)
        mario.didEnterNextScene(param)
    }
    
    // MARK: Help method
    
    private func fetchScene(sceneName name: String) -> GameScene {
        if let scene = allScenes[name] {
            return scene
        }
        
        if let scene = SKScene(fileNamed: name) as? GameScene {
            allScenes[name] = scene
            return scene
        } else {
            fatalError("Can not load game scene: \(name)")
        }
    }
}
