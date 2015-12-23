//
//  StatePlaceholderView.swift
//  HIT
//
//  Created by Nathan Melehan on 12/22/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class StatePlaceholderView: UIView {

    @IBInspectable var placeholderColor: UIColor = UIColor.blackColor()
    
    #if TARGET_INTERFACE_BUILDER
    override func drawRect(rect: CGRect) {
        let rectPath = UIBezierPath(rect: bounds)
        rectPath.lineWidth = 10
        placeholderColor.setStroke()
        rectPath.stroke()
    
        let crossPath = UIBezierPath()
        crossPath.lineWidth = 5
        crossPath.moveToPoint(CGPoint(x: 0, y: 0))
        crossPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        crossPath.moveToPoint(CGPoint(x: bounds.width, y: 0))
        crossPath.addLineToPoint(CGPoint(x: 0, y: bounds.height))
        crossPath.stroke()
    }
    #endif

    override func layoutSubviews() {
        setNeedsDisplay()
    }

}
