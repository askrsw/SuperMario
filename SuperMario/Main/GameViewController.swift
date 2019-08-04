//
//  GameViewController.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/5.
//  Copyright © 2019 haharsw. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    let gameView = GameManager.instance.gameView
    var uiView: MainView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiView = MainView()
        uiView.mainController = self
        view.addSubview(uiView)
        
        let returnRect = CGRect(x: gameView.frame.width - 50, y: 10, width: 30, height: 30)
        let returnButton = UIButton(type: .custom)
        returnButton.setImage(UIImage(named: "Icon_return"), for: .normal)
        returnButton.frame = returnRect
        returnButton.addTarget(self, action: #selector(returnButtonTapped(sender:)), for: .touchUpInside)
        gameView.addSubview(returnButton)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Interface
    
    func startGameLevel(_ index: Int) {
        uiView.removeFromSuperview()
        uiView = nil
        
        view.addSubview(gameView)
        GameManager.instance.start(index: index)
    }
    
    // MARK: Help method
    
    @objc private func returnButtonTapped(sender: UIButton) {
        GameManager.instance.exitCurrentGame()
        gameView.removeFromSuperview()
        
        uiView = MainView()
        uiView.mainController = self
        view.addSubview(uiView)
    }
}
