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
                          "Scene1_2",
                          "Scene1_3",
                          "Scene1_4" ]
    
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
        
        _ = GameHUD.instance
    }
    
    func start(index: Int) {
        let sceneName = allSceneNames[index]
        let scene = fetchScene(sceneName: sceneName)
        gameView.presentScene(scene)
    }
    
    func enterScene(_ param: SceneGadget) {
        let scene = fetchScene(sceneName: param.destSceneName)
        gameView.presentScene(scene)
        mario.didEnterNextScene(param)
    }
    
    func makeCurrentScreenshot() {
        let width = gameView.frame.height / GameConstant.OriginalSceneHeight * (16 * 16.0)
        let size = CGSize(width: width, height: gameView.frame.height)
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        beforeMakeScreenshot()
        delay(0.1) {
            self.makeContinuedScreenshot(timeInterval: 0.25, count: 0, totalCount: 1)
            delay(0.5) {
                self.afterMakeScreenshot()
                UIGraphicsEndImageContext()
            }
        }
    }
    
    func exitCurrentGame() {
        allScenes.removeAll()
        AudioManager.stopBackgroundMusic()
        gameView.presentScene(nil)
        GameHUD.instance.resetAll()
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
    
    private func beforeMakeScreenshot() {
    #if DEBUG
        gameView.showsFPS       = false
        gameView.showsNodeCount = false
        gameView.showsQuadCount = false
        gameView.showsPhysics   = false
        gameView.showsFields    = false
    #endif
        
        GameScene.currentInstance?.cameraRootNode.alpha = 0.0
        GameScene.currentInstance?.horzIndexLabelHolder.alpha = 0.0
    }
    
    private func afterMakeScreenshot() {
    #if DEBUG
        gameView.showsFPS       = true
        gameView.showsNodeCount = true
        gameView.showsQuadCount = true
        gameView.showsPhysics   = true
        gameView.showsFields    = true
    #endif
        
        GameScene.currentInstance?.cameraRootNode.alpha = 1.0
        GameScene.currentInstance?.horzIndexLabelHolder.alpha = 1.0
    }
    
    // At first, I wanted to use this recursive function to record continuous
    // frames of the game. But the pictures recorded by this way were sucks.
    // I think I shoud use ReplayKit to record a game video. Then I can extract
    // pictures from the video.
    // Um, this is just a learning program. So now I won't import ReplayKit to
    // do this. May be I will do this in the future. And now I just get only One
    // picture with this recursive method. It's funny.
    private func makeContinuedScreenshot(timeInterval: Double, count: Int, totalCount: Int) {
        gameView.drawHierarchy(in: gameView.bounds, afterScreenUpdates:true)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }

        if count + 1 < totalCount {
            delay(timeInterval) {
                self.makeContinuedScreenshot(timeInterval: timeInterval, count: count + 1, totalCount: totalCount)
            }
        }
    }
}
