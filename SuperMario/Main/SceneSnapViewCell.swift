//
//  SceneSnapViewCell.swift
//  SuperMario
//
//  Created by haharsw on 2019/8/4.
//  Copyright © 2019 haharsw. All rights reserved.
//

import UIKit

class SceneSnapViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let label = UILabel()
    
    var asCurrentSelected: Bool = false {
        didSet {
            if asCurrentSelected {
                label.font = UIFont.boldSystemFont(ofSize: 13.0)
                imageView.alpha = 1.0
            } else {
                label.font = UIFont.systemFont(ofSize: 11.0)
                imageView.alpha = 0.5
            }
        }
    }
    
    var title: String = "" {
        didSet {
            imageView.image = UIImage(named: title)
            
            let indexMajor1 = title.index(title.endIndex, offsetBy: -3)
            let indexMajor2 = title.index(title.endIndex, offsetBy: -2)
            let minor = title.suffix(1)
            let major = title[indexMajor1..<indexMajor2]
            label.text = "Level " + major + " - " + minor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 20.0)
        imageView.frame = imageRect
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1.25
        imageView.layer.borderColor = UIColor.yellow.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.alpha = 0.5
        contentView.addSubview(imageView)
        
        let labelRect = CGRect(x: 0, y: imageRect.height, width: frame.width, height: 20.0)
        label.frame = labelRect
        label.textColor = .yellow
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.0)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
