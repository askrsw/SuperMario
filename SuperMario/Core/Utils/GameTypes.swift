//
//  GameTypes.swift
//  SuperMario
//
//  Created by haharsw on 2019/5/20.
//  Copyright © 2019 haharsw. All rights reserved.
//

import Foundation

struct ButtonDirectionCategory {
    static let None:  UInt32 = 0
    static let Left:  UInt32 = 0b1
    static let Up:    UInt32 = 0b10
    static let Right: UInt32 = 0b100
    static let Down:  UInt32 = 0b1000
}

struct PhysicsCategory {
    static let None:      UInt32 = 0
    static let All:       UInt32 = 0b11111111111111111111111111111111
    static let Mario:     UInt32 = 0b1
    static let MBullet:   UInt32 = 0b10
    static let Solid:     UInt32 = 0b100
    static let Brick:     UInt32 = 0b1000
    static let GoldMetal: UInt32 = 0b10000
    static let Coin:      UInt32 = 0b100000
    static let Gadget:    UInt32 = 0b1000000
    static let MarioPower:   UInt32 = 0b10000000
    static let erasablePlat: UInt32 = 0b100000000
                                   // 0b11111111111111111111111111111111
}

enum PhysicsSolidEdgeType: String {
    case verticalLeftLine  = "verticalLeftLine"
    case verticalRightLine = "verticalRightLine"
    case groundLine        = "groundLine"
    case pipeLeftSideLine  = "pipeLeftSideLine"
    case pipeRightSideLine = "pipeRightSideLine"
    case pipeTopGroundLine = "pipeTopGroundLine"
    case pipeTopUpSideLine = "pipeTopUpSideLine"
    case horzPlatformLine  = "horzPlatformLine"
}

enum FragileGridType: String {
    case A = "_a"
    case B = "_b"
}
