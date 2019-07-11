//
//  HelperMethod.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/13.
//  Copyright © 2019 haharsw. All rights reserved.
//

import UIKit
import SpriteKit

func makeShrinkRoundRectangle(_ size: CGSize, xDelta: CGFloat = 1.5, yDelta: CGFloat = 1.0, radius: CGFloat = 0.5) -> CGPath {
    let x = -size.width * 0.5 + xDelta
    let y = -size.height * 0.5 + yDelta
    let w = size.width - xDelta * 2.0
    let h = size.height - yDelta * 2.0
    
    let rect = CGRect(x: x, y: y, width: w, height: h)
    let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
    return path.cgPath
}

func DebugPrint(_ message: String) {
    #if DEBUG
        print(message)
    #endif
}

func delay(_ seconds: Double, completion: @escaping ()->Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

func makeAnimation(texName: String, suffix: String, count: Int, timePerFrame: TimeInterval, startIndex: Int = 1, repeatForever: Bool = true) -> SKAction {
    let endIndex = startIndex + count - 1
    var textures: [SKTexture] = []
    for index in startIndex...endIndex {
        let texFileName = texName + suffix + "_\(index)"
        let tex = SKTexture(imageNamed: texFileName)
        textures.append(tex)
    }
    
    let animation = SKAction.animate(with: textures, timePerFrame: timePerFrame)
    
    if repeatForever {
        return SKAction.repeatForever(animation)
    } else {
        return animation
    }
}

func makeRepeatGridImage(imageName: String, count: Int) -> UIImage {
    let rawImage = UIImage(named: imageName)
    let unitL = rawImage!.size.width
    let imgSize = CGSize(width: unitL * CGFloat(count), height: unitL)
    
    UIGraphicsBeginImageContext(imgSize)
    for i in 0 ..< count {
        let rect = CGRect(x: unitL * CGFloat(i), y: 0, width: unitL, height: unitL)
        rawImage?.draw(in: rect)
    }
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resultImage!
}
