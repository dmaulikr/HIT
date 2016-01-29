//
//  HintingIconView.swift
//  HIT
//
//  Created by Nathan Melehan on 1/26/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class HintingIconView: XibDesignedView {

    
    // 
    // MARK: - Icon
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconViewWidthConstraint: NSLayoutConstraint!
    
    @IBInspectable var iconSize: CGFloat {
        get {
            return iconViewWidthConstraint.constant
        }
        set {
            iconViewWidthConstraint
                = NSLayoutConstraint.updateConstraint(
                    iconViewWidthConstraint,
                    withNewConstant: newValue)
            iconViewHeightConstraint
                = NSLayoutConstraint.updateConstraint(
                    iconViewHeightConstraint,
                    withNewConstant: newValue)
        }
    }
    
    
    //
    // MARK: - Dial
    
    @IBOutlet weak var dialView: DialView!
    
    @IBInspectable var dialColor: CGColor?
    @IBInspectable var dialProgress: CGFloat {
        get {
            return dialView.shapeLayer.strokeEnd
        }
        set {
            dialView.shapeLayer.strokeEnd = max(min(newValue, 1), 0)
        }
    }
    
    

}
