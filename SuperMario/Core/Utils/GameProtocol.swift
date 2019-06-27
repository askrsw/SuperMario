//
//  GameProtocol.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/19.
//  Copyright © 2019 haharsw. All rights reserved.
//

import SpriteKit

protocol MarioBumpFragileNode {
    func marioBump()
}

protocol SpriteReverseMovement {
    func reverseMovement(_ direction: CGVector)
}

protocol MovingSpriteNode {
    func update(deltaTime dt: CGFloat)
}

protocol MarioShapeshifting {
    func marioWillShapeshift()
    func marioDidShapeshift()
}
