//
//  GameScene+Audio.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/14.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    // MARK: Interface
    
    func playBackgroundMusc() {
        if let music = BackgroundMusic(rawValue: bkMusicName) {
            AudioManager.play(music: music)
        }
    }
}
