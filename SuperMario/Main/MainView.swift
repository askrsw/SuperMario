//
//  MainView.swift
//  SuperMario
//
//  Created by haharsw on 2019/8/3.
//  Copyright © 2019 haharsw. All rights reserved.
//

import UIKit

class MainView: UIView {
    let skyColor = UIColor(red: 107/255.0, green: 140/255.0, blue: 1.0, alpha: 1.0)
    let maxWidth: CGFloat  = 200
    let maxHeight: CGFloat = 300
    
    let marioPowerLabel   = UILabel()
    let marioPowerSwitchA = UISwitch()
    let marioPowerSwitchB = UISwitch()
    let marioPowerSwitchC = UISwitch()
    let musicSwitch = UISwitch()
    let soundSwitch = UISwitch()
    let shadowView = ShadowView()
    var collectionView: UICollectionView!
    var marioPower = MarioPower.A
    
    weak var mainController: GameViewController?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = skyColor
        
        addSubview(shadowView)
        createSubUI()
        createCollectionView()
        
        delay(0.1) {
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? SceneSnapViewCell {
                cell.asCurrentSelected = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Help method
    
    private func createSubUI() {
        let xOffset: CGFloat = 40.0 //(frame.width * 0.5 - maxWidth) * 0.5
        let yOffset = (frame.height - maxHeight) * 0.5
        
        let marioLabel = createTipLabel(.yellow, 20.0, true)
        marioLabel.frame = CGRect(x: xOffset, y: yOffset, width: 130, height: 30)
        marioLabel.text = "Mario Status: "
        addSubview(marioLabel)
        
        marioPowerLabel.frame = CGRect(x: xOffset + 130 + 10, y: yOffset, width: 35, height: 30)
        marioPowerLabel.textColor = .yellow
        marioPowerLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        marioPowerLabel.text = "A"
        marioPowerLabel.textAlignment = .left
        addSubview(marioPowerLabel)
        
        let powerALablel = createTipLabel()
        powerALablel.frame = CGRect(x: xOffset + 20, y: yOffset + 40, width: 120, height: 30)
        powerALablel.text = "Power A: "
        addSubview(powerALablel)
        
        marioPowerSwitchA.center = CGPoint(x: xOffset + 130, y: powerALablel.center.y)
        marioPowerSwitchA.tintColor = .yellow
        marioPowerSwitchA.onTintColor = .yellow
        marioPowerSwitchA.tag = 1
        marioPowerSwitchA.isOn = true
        marioPowerSwitchA.isUserInteractionEnabled = false
        marioPowerSwitchA.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        addSubview(marioPowerSwitchA)
        
        let powerBLablel = createTipLabel()
        powerBLablel.frame = CGRect(x: xOffset + 20, y: yOffset + 80, width: 120, height: 30)
        powerBLablel.text = "Power B: "
        addSubview(powerBLablel)
        
        marioPowerSwitchB.center = CGPoint(x: xOffset + 130, y: powerBLablel.center.y)
        marioPowerSwitchB.tintColor = .yellow
        marioPowerSwitchB.onTintColor = .yellow
        marioPowerSwitchB.tag = 2
        marioPowerSwitchB.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        addSubview(marioPowerSwitchB)
        
        let powerCLablel = createTipLabel()
        powerCLablel.frame = CGRect(x: xOffset + 20, y: yOffset + 120, width: 120, height: 30)
        powerCLablel.text = "Power C: "
        addSubview(powerCLablel)
        
        marioPowerSwitchC.center = CGPoint(x: xOffset + 130, y: powerCLablel.center.y)
        marioPowerSwitchC.tintColor = .yellow
        marioPowerSwitchC.onTintColor = .yellow
        marioPowerSwitchC.tag = 3
        marioPowerSwitchC.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        addSubview(marioPowerSwitchC)
        
        let musicLabel = createTipLabel(.yellow, 20.0, true)
        musicLabel.text = "Music: "
        musicLabel.frame = CGRect(x: xOffset, y: yOffset + 180, width: 80, height: 30)
        addSubview(musicLabel)
        
        musicSwitch.center = CGPoint(x: xOffset + 80 + 30, y: musicLabel.center.y)
        musicSwitch.tintColor = .yellow
        musicSwitch.onTintColor = .yellow
        musicSwitch.isOn = true
        musicSwitch.addTarget(self, action: #selector(musicOrSoundValueChanged(sender:)), for: .valueChanged)
        addSubview(musicSwitch)
        
        let soundLabel = createTipLabel(.yellow, 20.0, true)
        soundLabel.text = "Sound: "
        soundLabel.frame = CGRect(x: xOffset, y: yOffset + 220, width: 80, height: 30)
        addSubview(soundLabel)
        
        soundSwitch.center = CGPoint(x: xOffset + 80 + 30, y: soundLabel.center.y)
        soundSwitch.tintColor = .yellow
        soundSwitch.onTintColor = .yellow
        soundSwitch.isOn = true
        soundSwitch.addTarget(self, action: #selector(musicOrSoundValueChanged(sender:)), for: .valueChanged)
        addSubview(soundSwitch)
        
        let button = UIButton(type: .custom)
        button.setTitle("Start Game", for: .normal)
        button.setTitleColor(.yellow, for: .normal)
        button.setTitleColor(.orange, for: .highlighted)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        button.sizeToFit()
        button.center = CGPoint(x: 40.0 + maxWidth * 0.5, y: yOffset + 280)
        button.addTarget(self, action: #selector(startGame(sender:)), for: .touchUpInside)
        addSubview(button)
    }
    
    private func createTipLabel(_ textColor: UIColor = .yellow, _ fontSize: CGFloat = 18.0, _ bold: Bool = false) -> UILabel {
        let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        let label = UILabel()
        label.textColor = textColor
        label.font = font
        label.textAlignment = .left
        return label
    }
    
    private func createCollectionView() {
        let rect = CGRect(x: 40.0 + maxWidth + 40.0, y: 20.0, width: frame.width - 40.0 - maxWidth - 40.0 - 40.0, height: frame.height - 40.0)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 30.0, bottom: 20.0, right: 30.0)
        layout.minimumLineSpacing = 20.0
        layout.minimumInteritemSpacing = 20.0
        
        layout.itemSize = CGSize(width: 16 * 10.0, height: 14 * 10.0 + 20)
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 16.0
        collectionView.layer.masksToBounds = true
        collectionView.layer.borderWidth = 1.5
        collectionView.layer.borderColor = UIColor.yellow.cgColor
        collectionView.clipsToBounds = true
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.allowsMultipleSelection = false
        collectionView.register(SceneSnapViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        addSubview(collectionView)
    }
    
    @objc private func startGame(sender: UIButton) {
        if let current = collectionView.indexPathsForSelectedItems?.first {
            let index = current.item
            if let main = mainController {
                AudioManager.setMusicOn(on: musicSwitch.isOn)
                AudioManager.setSoundOn(on: soundSwitch.isOn)
                GameManager.instance.mario.marioPower = marioPower
                main.startGameLevel(index)
            }
        }
    }
    
    @objc private func musicOrSoundValueChanged(sender: UISwitch) {
        if sender == musicSwitch {
            AudioManager.setMusicOn(on: sender.isOn)
        } else {
            AudioManager.setSoundOn(on: sender.isOn)
        }
    }
    
    @objc private func switchValueChanged(sender: UISwitch) {
        let value = sender.isOn
        switch sender.tag {
        case 1:
            marioPowerSwitchA.isOn = value
            marioPowerSwitchB.isOn = !value
            marioPowerSwitchC.isOn = !value
            marioPowerSwitchA.isUserInteractionEnabled = !value
            marioPowerSwitchB.isUserInteractionEnabled = value
            marioPowerSwitchC.isUserInteractionEnabled = value
            marioPowerLabel.text = "A"
            shadowView.marioImageType = .A
            marioPower = .A
        case 2:
            marioPowerSwitchA.isOn = !value
            marioPowerSwitchB.isOn = value
            marioPowerSwitchC.isOn = !value
            marioPowerSwitchA.isUserInteractionEnabled = value
            marioPowerSwitchB.isUserInteractionEnabled = !value
            marioPowerSwitchC.isUserInteractionEnabled = value
            marioPowerLabel.text = "B"
            shadowView.marioImageType = .B
            marioPower = .B
        case 3:
            marioPowerSwitchA.isOn = !value
            marioPowerSwitchB.isOn = !value
            marioPowerSwitchC.isOn = value
            marioPowerSwitchA.isUserInteractionEnabled = value
            marioPowerSwitchB.isUserInteractionEnabled = value
            marioPowerSwitchC.isUserInteractionEnabled = !value
            marioPowerLabel.text = "C"
            shadowView.marioImageType = .C
            marioPower = .C
        default:
            break
        }
    }
}

extension MainView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GameManager.instance.allSceneNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! SceneSnapViewCell
        let title = GameManager.instance.allSceneNames[indexPath.row]
        cell.title = title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SceneSnapViewCell {
            cell.asCurrentSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SceneSnapViewCell {
            cell.asCurrentSelected = false
        }
    }
}
