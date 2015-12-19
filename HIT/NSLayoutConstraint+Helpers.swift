//
//  NSLayoutConstraint+Helpers.swift
//  HIT
//
//  Created by Nathan Melehan on 12/18/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    class func pinItem(firstItem: AnyObject, toItem secondItem: AnyObject, withAttribute attribute: NSLayoutAttribute)
        
        -> NSLayoutConstraint
    {
        return NSLayoutConstraint(
            item: firstItem,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: secondItem,
            attribute: attribute,
            multiplier: 1.0,
            constant: 0)
    }
}
