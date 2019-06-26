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

func makeAnimation(texName: String, suffix: String, count: Int, timePerFrame: TimeInterval, repeatForever: Bool = true) -> SKAction {
    var textures: [SKTexture] = []
    for index in 1...count {
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
