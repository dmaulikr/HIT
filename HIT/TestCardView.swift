//
//  TestCardView.swift
//  HIT
//
//  Created by Nathan Melehan on 2/7/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class TestCardView: CardView
{
    
    var mantra: Mantra? {
        didSet {
            mantraLabel.text = mantra?.cardTitle
        }
    }
    
    let cornerRadius: CGFloat = 3
    
    var shadowView = UIView()
    var backgroundView = UIView()
    var mantraLabel = UILabel()
    
    func buildShadowView()
    {
        addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.pinItem(shadowView, toItem: self, withAttribute: .CenterX).active = true
        
        let widthConstraint = NSLayoutConstraint.pinItem(shadowView, toItem: self, withAttribute: .Width)
        widthConstraint.constant = 0
        widthConstraint.active = true
        
        let topConstraint = NSLayoutConstraint.pinItem(shadowView, toItem: self, withAttribute: .Top)
        topConstraint.constant = -2
        topConstraint.active = true
        
        let heightConstraint = NSLayoutConstraint.pinItem(shadowView, toItem: self, withAttribute: .Height)
        heightConstraint.constant = 3.5
        heightConstraint.active = true
        
        shadowView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        shadowView.layer.cornerRadius = cornerRadius + 2
    }
    
    func buildBackgroundView()
    {
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.pinItem(backgroundView, toItem: self, withAttribute: .Leading).active = true
        NSLayoutConstraint.pinItem(backgroundView, toItem: self, withAttribute: .Trailing).active = true
        NSLayoutConstraint.pinItem(backgroundView, toItem: self, withAttribute: .Top).active = true
        NSLayoutConstraint.pinItem(backgroundView, toItem: self, withAttribute: .Bottom).active = true
        
        backgroundView.layer.cornerRadius = cornerRadius
    }
    
    func buildLabel()
    {        
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
        
        buildShadowView()
        buildBackgroundView()
        buildLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildShadowView()
        buildBackgroundView()
        buildLabel()
    }
    
    
    
    override func presentCollapsedView() {}
    override func presentStackedView() {}
    override func presentPulledView() {}
}