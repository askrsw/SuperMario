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
        view = GameManager.instance.gameView
        GameManager.instance.start()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
