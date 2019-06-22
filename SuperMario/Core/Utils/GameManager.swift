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
    private init() {}
    
    let mario = Mario()
    
    weak var gameView: SKView?
    weak var currentScene: GameScene?
}
