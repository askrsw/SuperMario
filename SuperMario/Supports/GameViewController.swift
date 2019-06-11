//
//  GameViewController.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/5.
//  Copyright © 2019 haharsw. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: view.bounds)
        
#if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsQuadCount = true
        skView.showsPhysics   = true
        skView.showsFields    = true
#endif
        
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = true
        skView.isMultipleTouchEnabled = true        // very important
        view = skView
        
        let _ = GameManager.instance
        
        if let scene = SKScene(fileNamed: "Scene1_1") as? GameScene {
            skView.presentScene(scene)
        } else {
            fatalError("Can not load game scene.")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
