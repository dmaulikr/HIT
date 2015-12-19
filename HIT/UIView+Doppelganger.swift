//
//  UIView+ConstraintAdoption.swift
//  HIT
//
//  Created by Nathan Melehan on 12/13/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func mirrorView(
        otherView: UIView,
        byReplacingConstraints oldConstraints: [NSLayoutConstraint])
        
        -> [NSLayoutConstraint]
    {
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
    }
    
    
    
    func mirrorConstraints(
        constraints: [NSLayoutConstraint],
        ofView otherView: UIView,
        byReplacingConstraints oldConstraints: [NSLayoutConstraint])
        
        -> [NSLayoutConstraint]
    {
        var newConstraints = [NSLayoutConstraint]()
        
        for constraint in constraints
        {
            let firstItem = constraint.firstItem as? UIView == otherView
                ? self
                : constraint.firstItem
            
            let secondItem = constraint.secondItem as? UIView == otherView
                ? self
                : constraint.secondItem
            
            let mirrorConstraint = NSLayoutConstraint(
                item: firstItem,
                attribute: constraint.firstAttribute,
                relatedBy: constraint.relation,
                toItem: secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: constraint.constant)
            
            newConstraints.append(mirrorConstraint)
        }
        
        NSLayoutConstraint.deactivateConstraints(oldConstraints)
        NSLayoutConstraint.activateConstraints(newConstraints)
        
        return newConstraints
    }
}