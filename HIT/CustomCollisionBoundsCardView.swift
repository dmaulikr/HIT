//
//  CustomCollisionBoundsCardView.swift
//  HIT
//
//  Created by Nathan Melehan on 2/1/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class CustomCollisionBoundsCardView: CardView {
    
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