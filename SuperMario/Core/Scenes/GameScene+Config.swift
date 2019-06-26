//
//  GameScene+Config.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/14.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene {
    var bkMusicName: String {
        get {
            return userData?["bkMusic"] as? String ?? ""
        }
    }
    
    var sceneWidth: CGFloat {
        get {
            return userData?["SceneWidth"] as? CGFloat ?? 256.0
        }
    }
    
    var physicsDescFileName: String {
        get {
            return userData?["PhysicsDescFile"] as? String ?? ""
        }
    }
    
    var tileType: String {
        get {
            return userData?["tileType"] as? String ?? "_a"
        }
    }
    
    static var currentTileType: String {
        get {
            return GameManager.instance.currentScene?.tileType ?? "_a"
        }
    }
}
