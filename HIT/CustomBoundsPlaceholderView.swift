//
//  CustomBoundsPlaceholderView.swift
//  HIT
//
//  Created by Nathan Melehan on 1/23/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class CustomBoundsPlaceholderView: StatePlaceholderView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    private var _collisionBoundsType: UIDynamicItemCollisionBoundsType?
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return _collisionBoundsType ?? .Rectangle
        }
        set {
            _collisionBoundsType = newValue
        }
    }
    
    private var _collisionBoundingPath: UIBezierPath?
    
    override var collisionBoundingPath: UIBezierPath {
        get {
            return _collisionBoundingPath
                ?? UIBezierPath(rect: CGRect(origin: CGPointZero, size: bounds.size))
        }
        set {
            _collisionBoundingPath = newValue
        }
    }

}
