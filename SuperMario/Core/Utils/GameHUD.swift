//
//  GameHUD.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/28.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

class GameHUD: SKNode {
    static let instance = GameHUD()
    
    private let marioLabel = SKLabelNode(text: "MARIO")
    private let scoreLabel = SKLabelNode(text: "0")
    private let coinNode   = SKSpriteNode(imageNamed: "small_coin_a_1")
    private let coinCountLabel = SKLabelNode(text: "X 0")
    private let worldLabel = SKLabelNode(text: "WORLD")
    private let levelLabel = SKLabelNode(text: "1 - 1")
    private let marioNode  = SKSpriteNode(imageNamed: "mario_b_normal1")
    private let marioLifeLabel = SKLabelNode(text: "X 3")
    private let timeLabel  = SKLabelNode(text: "TIME")
    private let timeCountLabel = SKLabelNode(text: "300")
    private var timer: Timer!
    
    private override init() {
        super.init()
        
        zPosition = 1001
        
        timer = Timer.init(timeInterval: 1.0, target: self, selector: #selector(timerFunction(timer:)), userInfo: nil, repeats: true)
        
        marioLabel.fontName = GameConstant.hudLabelFontName
        marioLabel.fontSize = GameConstant.hudLabelFontSize
        marioLabel.horizontalAlignmentMode = .left
        addChild(marioLabel)
        
        scoreLabel.fontName = GameConstant.hudLabelFontName
        scoreLabel.fontSize = GameConstant.hudLabelFontSize
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        coinNode.xScale = 2.0
        coinNode.yScale = 2.0
        addChild(coinNode)
        
        coinCountLabel.fontName = GameConstant.hudLabelFontName
        coinCountLabel.fontSize = GameConstant.hudLabelFontSize
        coinCountLabel.horizontalAlignmentMode = .left
        addChild(coinCountLabel)
        
        worldLabel.fontName = GameConstant.hudLabelFontName
        worldLabel.fontSize = GameConstant.hudLabelFontSize
        worldLabel.horizontalAlignmentMode = .center
        addChild(worldLabel)
        
        levelLabel.fontName = GameConstant.hudLabelFontName
        levelLabel.fontSize = GameConstant.hudLabelFontSize
        levelLabel.horizontalAlignmentMode = .center
        addChild(levelLabel)
        
        marioNode.xScale = 0.75
        marioNode.yScale = 0.75
        addChild(marioNode)
        
        marioLifeLabel.fontName = GameConstant.hudLabelFontName
        marioLifeLabel.fontSize = GameConstant.hudLabelFontSize
        marioLifeLabel.horizontalAlignmentMode = .left
        addChild(marioLifeLabel)
        
        timeLabel.fontName = GameConstant.hudLabelFontName
        timeLabel.fontSize = GameConstant.hudLabelFontSize
        timeLabel.horizontalAlignmentMode = .right
        addChild(timeLabel)
        
        timeCountLabel.fontName = GameConstant.hudLabelFontName
        timeCountLabel.fontSize = GameConstant.hudLabelFontSize
        timeCountLabel.horizontalAlignmentMode = .right
        addChild(timeCountLabel)
        
        layoutChildren()
        
        startTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var coinCount: Int = 0 {
        didSet {
            coinCountLabel.text = "X \(coinCount)"
        }
    }
    
    var level: String = "1 - 1" {
        didSet {
            levelLabel.text = level
        }
    }
    
    var marioLifeCount: Int = 3 {
        didSet {
            marioLifeLabel.text = "X \(marioLifeCount)"
        }
    }
    
    var timeCount: Int = 300 {
        didSet {
            timeCountLabel.text = "\(timeCount)"
        }
    }
    
    func startTimer() {
        RunLoop.current.add(timer, forMode: .default)
    }
    
    func pauseTimer() {
        timer.invalidate()
    }
    
    func resetAll() {
        timer.invalidate()
        timeCount = 300
        marioLifeCount = 3
        coinCount = 0
        score = 0
    }
    
    // MARK: Help method
    
    @objc private func timerFunction(timer: Timer) {
        timeCount -= 1
    }
    
    private func layoutChildren() {
        let halfW = UIScreen.main.bounds.size.width * 0.5
        let halfH = UIScreen.main.bounds.size.height * 0.5
        let padddingTop: CGFloat = 10.0
        let lineSpace: CGFloat = 5.0
        
        let contentLength = marioLabel.width + coinNode.size.width + coinCountLabel.width + worldLabel.width + marioNode.size.width + marioLifeLabel.width + timeLabel.width
        let horzSpaceUnit = (halfW * 2.0 - contentLength) / 6.0
        
        marioLabel.position = CGPoint(x: -halfW + horzSpaceUnit, y: halfH - marioLabel.height - padddingTop)
        scoreLabel.position = CGPoint(x: marioLabel.xPos, y: marioLabel.yPos - lineSpace - scoreLabel.height )
        
        coinNode.position = CGPoint(x: marioLabel.right + horzSpaceUnit, y: marioLabel.yPos - lineSpace / 2.0)
        coinCountLabel.position = CGPoint(x: coinNode.position.x + coinNode.size.width, y: coinNode.position.y - coinCountLabel.height * 0.5)
    
        worldLabel.position = CGPoint(x: 0.0, y: halfH - worldLabel.height - padddingTop)
        levelLabel.position = CGPoint(x: 0.0, y: worldLabel.yPos - lineSpace - levelLabel.height)
        
        marioNode.position = CGPoint(x: worldLabel.width * 0.5 + horzSpaceUnit + marioNode.size.width * 0.5, y: coinNode.position.y)
        marioLifeLabel.position = CGPoint(x: marioNode.position.x + marioNode.size.width, y: marioNode.position.y - marioLifeLabel.height * 0.5)
        
        timeLabel.position = CGPoint(x: halfW - horzSpaceUnit, y: halfH - timeLabel.height - padddingTop)
        timeCountLabel.position = CGPoint(x: timeLabel.xPos, y: timeLabel.yPos - lineSpace - timeCountLabel.height)
    }
}

extension SKLabelNode {
    var right: CGFloat {
        get { return position.x + frame.size.width }
    }
    
    var width: CGFloat {
        get { return frame.size.width }
    }
    
    var height: CGFloat {
        get { return frame.size.height }
    }
    
    var xPos: CGFloat {
        get { return position.x }
    }
    
    var yPos: CGFloat {
        get { return position.y }
    }
}
