//
//  TestCardView.swift
//  HIT
//
//  Created by Nathan Melehan on 2/7/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class TestCardView: UIView
{
    
    var mantra: Mantra? {
        didSet {
            mantraLabel.text = mantra?.cardTitle
        }
    }
    
    var mantraLabel: UILabel = UILabel()
    
    func buildLabel() {
        addSubview(mantraLabel)
        mantraLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20
        
        let leadingConstraint = NSLayoutConstraint.pinItem(mantraLabel, toItem: self, withAttribute: .Leading)
        leadingConstraint.constant = padding
        leadingConstraint.active = true
        
        let trailingConstraint = NSLayoutConstraint.pinItem(mantraLabel, toItem: self, withAttribute: .Trailing)
        trailingConstraint.constant = padding
        trailingConstraint.active = true
        
        let topConstraint = NSLayoutConstraint.pinItem(mantraLabel, toItem: self, withAttribute: .Top)
        topConstraint.constant = padding
        topConstraint.active = true
        
        
        mantraLabel.font = UIFont.systemFontOfSize(24)
        mantraLabel.textColor = UIColor.whiteColor()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildLabel()
    }
    
    
    
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