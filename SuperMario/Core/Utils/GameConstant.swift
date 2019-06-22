//
//  GameConstant.swift
//  SuperMario
//
//  Created by haharsw on 2019/6/7.
//  Copyright © 2019 haharsw. All rights reserved.
//

import UIKit

class GameConstant {
    private init() {}
    
    public static let OriginalSceneHeight: CGFloat = 224.0
    
    public static let TileGridLength: CGFloat = 16.0
    public static let TileYOffset: CGFloat    = -8.0
    public static let groundYFixup: CGFloat   = -1.0
    public static let horzPaddingOffset: CGFloat = 0.0
    
    public static let marioFlashTimeUnit: TimeInterval     = 0.1
    public static let powerdownSoundDuration: TimeInterval = 0.8088888888888889
    public static let powerupSoundDuration: TimeInterval   = 1.0178684807256235
    
    public static let actionButtonFontName = "Helvetica"
    public static let actionButtonFontSize: CGFloat = 20.0
    public static let actionButtonCircleRadius: CGFloat = 12.5

    public static let directionButtonCircleRadius: CGFloat = 30.0
    public static let directionButtonSmallCircleRadius: CGFloat = 6.0
}
