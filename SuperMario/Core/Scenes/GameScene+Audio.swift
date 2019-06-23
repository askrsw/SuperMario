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
    
    func playBackgroundMusc(_ rapid: Bool = false, _ remainRatio: Bool = false) {
        let musicName = bkMusicName + (rapid ? "_Rapid" : "")
        let music = BackgroundMusic(rawValue: musicName)!
        AudioManager.play(music: music, remainRatio)
    }
    
    func marioIsPowerfull() {
        AudioManager.play(music: .MarioProtected, false)
    }
}
