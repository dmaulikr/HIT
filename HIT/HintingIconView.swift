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
    
    @IBInspectable var imageName: String? {
        didSet {
            iconView.image = imageName != nil
                ? UIImage(named: imageName!)
                : nil
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
            let cappedValue = max(min(newValue, 1), 0)
            
            let dialCompletionGap: CGFloat = 0.1
            let gapStart = 1 - dialCompletionGap
            let interpretedValue: CGFloat
            switch cappedValue
            {
            case 0..<gapStart: interpretedValue = cappedValue
            case gapStart..<1.0: interpretedValue = gapStart
            default: interpretedValue = 1
            }
            
            dialView.shapeLayer.strokeEnd = interpretedValue
        }
    }
    
    

}
