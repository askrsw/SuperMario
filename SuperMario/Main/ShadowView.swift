//
//  ShadowView.swift
//  SuperMario
//
//  Created by haharsw on 2019/8/3.
//  Copyright © 2019 haharsw. All rights reserved.
//

import UIKit

enum MarioImageType: String {
    case A = "a"
    case B = "b"
    case C = "c"
}

class ShadowView: UIView {
    let factor: CGFloat = 1.0
    let alphaValue: CGFloat = 0.375
    let marioImageView: UIImageView = UIImageView()
    
    var marioImageType: MarioImageType = .A {
        didSet {
            let imgName = "mario_" + marioImageType.rawValue + "_normal1"
            setMarioImageType(imgName: imgName)
        }
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .clear
        
        createSubUI()
        addSubview(marioImageView)
        let imgName = "mario_a_normal1"
        setMarioImageType(imgName: imgName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Help method
    
    private func createSubUI() {
        let containerView = UIView(frame: bounds)
        containerView.alpha = alphaValue
        
        let baseImage = UIImage(named: "base_a")
        let groundObj: Array<UIImage?> = [
            UIImage(named: "grass_1"),
            UIImage(named: "grass_2"),
            UIImage(named: "grass_3"),
            UIImage(named: "hill1"),
            UIImage(named: "hill2")
        ]
        
        let skyObj: Array<UIImage?> = [
            UIImage(named: "cloud_a_1"),
            UIImage(named: "cloud_a_2"),
            UIImage(named: "cloud_a_3")
        ]
        
        var baseXPos: CGFloat = 0.0
        let baseYPos: CGFloat = frame.size.height - 24.0 * factor
        while baseXPos < frame.width {
            let rect1 = CGRect(x: baseXPos, y: baseYPos, width: 16.0 * factor, height: 16.0 * factor)
            let rect2 = CGRect(x: baseXPos, y: baseYPos + 16.0 * factor, width: 16.0 * factor, height: 16.0 * factor)
            let imgView1 = UIImageView(frame: rect1)
            let imgView2 = UIImageView(frame: rect2)
            imgView1.contentMode = .scaleToFill
            imgView2.contentMode = .scaleToFill
            imgView1.image = baseImage
            imgView2.image = baseImage
            containerView.addSubview(imgView1)
            containerView.addSubview(imgView2)
            baseXPos += 16.0 * factor
        }
        
        var groundObjXPos: CGFloat = CGFloat.random(min: -60.0, max: 10.0)
        while groundObjXPos < frame.width {
            let imgIndex = Int.random(min: 0, max: groundObj.count - 1)
            let image = groundObj[imgIndex]!
            let imgW = image.size.width * factor
            let imgH = image.size.height * factor
            let rect = CGRect(x: groundObjXPos, y: frame.height - 24 * factor - imgH, width: imgW, height: imgH)
            let imgView = UIImageView(frame: rect)
            imgView.contentMode = .scaleToFill
            imgView.image = image
            containerView.addSubview(imgView)
            
            groundObjXPos += imgW + CGFloat.random(min: 15, max: 50)
        }
        
        var skyObjXPos: CGFloat = CGFloat.random(min: -40.0, max: 5.0)
        while skyObjXPos < frame.width {
            let imgIndex = Int.random(min: 0, max: skyObj.count - 1)
            let image = skyObj[imgIndex]!
            let imgW = image.size.width * factor
            let imgH = image.size.height * factor
            let skyObjYPos = CGFloat.random(min: 10.0, max: frame.height - 100.0)
            let rect = CGRect(x: skyObjXPos, y: skyObjYPos, width: imgW, height: imgH)
            let imgView = UIImageView(frame: rect)
            imgView.contentMode = .scaleToFill
            imgView.image = image
            containerView.addSubview(imgView)
            skyObjXPos += imgW + CGFloat.random(min: 15, max: 50)
            
            let speedFactor = CGFloat.random(min: 30.0, max: 60.0)
            animateCloud(imgView, speedFactor: speedFactor)
        }
        
        addSubview(containerView)
    }
    
    // MARK: Help method
    
    private func setMarioImageType(imgName: String) {
        let marioImage = UIImage(named: imgName)!
        let marioImgW = marioImage.size.width
        let marioImgH = marioImage.size.height
        let marioImgRect = CGRect(x: 64 * factor, y: frame.height - 24.0 * factor - marioImgH * factor, width: marioImgW, height: marioImgH)
        marioImageView.frame = marioImgRect
        marioImageView.contentMode = .scaleToFill
        marioImageView.image = marioImage
    }
    
    private func animateCloud(_ cloud: UIImageView, speedFactor: CGFloat) {
        let cloudSpeed = speedFactor / frame.width
        let duration = (frame.width - cloud.frame.origin.x) * cloudSpeed
        UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: .curveLinear, animations: {
            cloud.frame.origin.x = self.frame.width
        }, completion: { _ in
            cloud.frame.origin.x = -cloud.frame.width
            self.animateCloud(cloud, speedFactor: speedFactor)
        })
    }
}
