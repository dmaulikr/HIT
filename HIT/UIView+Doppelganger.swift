//
//  UIView+ConstraintAdoption.swift
//  HIT
//
//  Created by Nathan Melehan on 12/13/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func mirrorView(otherView: UIView, byReplacingConstraints oldConstraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        NSLayoutConstraint.deactivateConstraints(oldConstraints)
        
        let widthConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: otherView,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1,
            constant: 0)
        
        let heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: otherView,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: 0)
        
        let centerXConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: otherView,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        
        let centerYConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: otherView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        
        let newConstraints = [widthConstraint, heightConstraint, centerXConstraint, centerYConstraint]
        NSLayoutConstraint.activateConstraints(newConstraints)
        
        return newConstraints
        
        // assure superview is shared
        
        // what about constraints owned by otherView that are equal to constants
        // e.g. constant width, constant height
        // do they have a 'second item'?
        
        // experiment with views whose width is derived from subviews with intrinsic size
    }
}