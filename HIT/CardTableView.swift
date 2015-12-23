//
//  CardTableView.swift
//  HIT
//
//  Created by Nathan Melehan on 12/19/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

protocol CardTableViewDelegate {
    // should return the location of the card frame's center, 
    // in the coordinates of the CardTableView
    func nextCardPullLocationForCardTableView(cardTableView: CardTableView) -> CGPoint
}



@IBDesignable class CardTableView: XibDesignedView {
    
    
    //
    //
    //
    //
    // MARK: - Properties
    
    var delegate: CardTableViewDelegate?
    
    @IBInspectable var cardHeight: CGFloat {
        get {
            return pulledCardStateViewHeightConstraint.constant
        }
        set {
            
        }
    }
    
    @IBInspectable var tableExtensionDistanceFromTop: CGFloat {
        get {
            // include multiplier in equation
            return tableExtensionStateViewTopConstraint.constant
        }
        set {
            
        }
    }
    
    @IBInspectable var tableCollapsedHeight: CGFloat {
        get {
            return tableCollapsedStateViewHeightConstraint.constant
        }
        set {
            
        }
    }
    
    
    
    //
    //
    //
    //
    // MARK: - Outlets

    @IBOutlet weak var tableExtensionStateView: UIView!
    @IBOutlet weak var tableCollapsedStateView: UIView!
    @IBOutlet weak var pulledCardStateView: UIView!
    
    @IBOutlet var tableCollapsedStateViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableExtensionStateViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var pulledCardStateViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var pulledCardStateViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var pulledCardStateViewCenterYConstraint: NSLayoutConstraint!
    
    
    
    // 
    //
    //
    //
    // MARK: - Methods
    
    func nextCardPullLocation() -> CGPoint
    {
        return  delegate?.nextCardPullLocationForCardTableView(self) ??
                CGPoint(x: bounds.width/2, y: cardHeight/2)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if delegate == nil {
            setPulledCardStateViewCenterConstraintsForLocation(nextCardPullLocation())
        }
    }
    
    func setPulledCardStateViewCenterConstraintsForLocation(locationInView: CGPoint) {
        let offsetFromViewCenter = CGPoint(
            x: locationInView.x - bounds.width/2,
            y: locationInView.y - bounds.height/2)
        
        pulledCardStateViewCenterXConstraint = NSLayoutConstraint.updateConstraint(
            pulledCardStateViewCenterXConstraint,
            withNewConstant: offsetFromViewCenter.x)
        pulledCardStateViewCenterYConstraint = NSLayoutConstraint.updateConstraint(
            pulledCardStateViewCenterYConstraint,
            withNewConstant: offsetFromViewCenter.y)
    }
    
}
