//
//  AudioManager.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/14.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit
import AVFoundation

enum GameSound: String {
    case None            = ""
    case AddLife         = "Add_Life"
    case BossDead        = "Boss_Dead"
    case BreakBrick      = "Break_Brick"
    case BreakBridge     = "Break_Bridge"
    case Coin            = "Coin"
    case ConnonFire      = "Connon_Fire"
    case DoubleJump      = "Double_Jump"
    case DoubleSwim      = "Double_Swim"
    case DownFlag        = "Down_Flag"
    case EnPipe          = "En_Pipe"
    case FireBullet      = "Fire_Bullet"
    case FireHitEvil     = "Fire_Hit_Evil"
    case FirePassWall    = "Fire_Pass_Wall"
    case Firework        = "Firework"
    case Flame           = "Flame"
    case GameOver        = "Game_Over"
    case HitHard         = "Hit_Hard"
    case Jump            = "Jump"
    case LevelFinish     = "Level_Finish"
    case MarioDeathLong  = "Mario_Death_Long"
    case MarioDeathShort = "Mario_Death_Short"
    case Powerdown       = "Powerdown"
    case Powerup         = "Powerup"
    case SpawnPowerup    = "Spawn_Powerup"
    case TreadEvil       = "Tread_Evil"
}

enum BackgroundMusic: String {
    case None           = ""
    case AutoWalkToPipe = "Auto_Walk_to_Pipe"
    case EnCastle       = "En_Castle"
    case InPrison       = "In_Prison"
    case InPrisonRapid  = "In_Prison_Rapid"
    case InSky          = "In_Sky"
    case InSkyRapid     = "In_Sky_Rapid"
    case InWater        = "In_Water"
    case InWaterRapid   = "In_Water_Rapid"
    case IndoorRandom   = "Indoor_Random"
    case Indoor         = "Indoor"
    case MarioProtected = "Mario_Protected"
    case Outdoor        = "Outdoor"
    case OutdoorRapid   = "Outdoor_Rapid"
    case StatsTime      = "Stats_Time"
    case TimeRunningOut = "Time_Running_Out"
}

class AudioManager {
    private static let instance = AudioManager()
    private init() {}
    
    var currentMusic: BackgroundMusic = .None
    var backgroundMusicPlayer: AVAudioPlayer?
    let soundCache: NSCache<NSString, SKAction> = NSCache()
    
    var musicOn: Bool = true {
        didSet {
            if musicOn {
                let currentMusic = self.currentMusic
                self.currentMusic = .None
                if currentMusic != .None {
                    play(musicName: currentMusic, false)
                }
            } else {
                backgroundMusicPlayer?.stop()
                backgroundMusicPlayer = nil
            }
        }
    }
    
    var soundOn: Bool = true

    // MARK: Interface
    
    static func setMusicOn(on: Bool) {
        instance.musicOn = on
    }
    
    static func setSoundOn(on: Bool) {
        instance.soundOn = on
    }
    
    static func play(music: BackgroundMusic, _ remainRatio: Bool) {
        if instance.musicOn {
            instance.play(musicName: music, remainRatio)
        } else {
            instance.currentMusic = music
        }
    }
    
    static func stopBackgroundMusic() {
        instance.backgroundMusicPlayer?.stop()
        instance.backgroundMusicPlayer = nil
        instance.currentMusic = .None
    }

    static func play(sound: GameSound) {
        if instance.soundOn {
            instance.play(soundName: sound)
        }
    }
}

extension AudioManager {
    
    private func play(musicName: BackgroundMusic, _ remainRatio: Bool) {
        guard currentMusic != musicName else { return }
        
        let resourceUrl = Bundle.main.url(forResource: musicName.rawValue, withExtension: "wav")
        guard let url = resourceUrl else {
            print("Could not find file: \(musicName.rawValue)")
            return
        }
        
        do {
            var ratio: Double = 0.0
            if remainRatio, let preMusic = backgroundMusicPlayer {
                ratio = preMusic.currentTime / preMusic.duration
            }
            
            try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer!.numberOfLoops = -1
            backgroundMusicPlayer!.prepareToPlay()
            backgroundMusicPlayer!.play()
            
            backgroundMusicPlayer!.currentTime = backgroundMusicPlayer!.duration * ratio
            
            currentMusic = musicName
        } catch {
            print("Could not create audio player for background music!")
        }
    }
    
    private func play(soundName: GameSound) {
        let name = NSString(string: soundName.rawValue)
        if let sound = soundCache.object(forKey: name) {
            GameScene.soundPlayNode.run(sound)
        } else {
            let sound = SKAction.playSoundFileNamed(soundName.rawValue, waitForCompletion: false)
            GameScene.soundPlayNode.run(sound)
            soundCache.setObject(sound, forKey: name)
        }
    }
}
