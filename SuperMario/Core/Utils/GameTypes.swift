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
    static let All:       UInt32 = 0xFFFFFFFF
    static let Mario:     UInt32 = 0b1
    static let Solid:     UInt32 = 0b10
    static let Brick:     UInt32 = 0b100
    static let GoldMetal: UInt32 = 0b1000
}

enum PhysicsSolidEdgeType: String {
    case verticalLeftLine  = "verticalLeftLine"
    case verticalRightLine = "verticalRightLine"
    case groundLine        = "groundLine"
    case pipeLeftSideLine  = "pipeLeftSideLine"
    case pipeRightSideLine = "pipeRightSideLine"
    case pipeTopGroundLine = "pipeTopGroundLine"
}

enum FragileGridType: String {
    case A = "_a"
    case B = "_b"
}
