//
//  CardView.swift
//  HIT
//
//  Created by Nathan Melehan on 12/16/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class CardView: XibDesignedView {
    
    
    
    //
    //
    //
    //
    // MARK: - Properties

    var currentStateView: UIView?
    var currentPositionConstraintSet: [NSLayoutConstraint]?
    
    var tableVisibilityStatePositionConstraintSet: [NSLayoutConstraint]?
    var revealedVisibilityStatePositionConstraintSet: [NSLayoutConstraint]?
    
    
    
    //
    //
    //
    //
    // MARK: - Outlets

    @IBOutlet weak var tableVisibilityStateView: UIView!
    @IBOutlet weak var revealedVisibilityStateView: UIView!
    
    @IBOutlet weak var cardTitleView: UIView!
    
    @IBOutlet var tableVisibilityStateViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var tableVisibilityStateViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var revealedVisibilityStateViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var revealedVisibilityStateViewCenterYConstraint: NSLayoutConstraint!
    
    // rename to "initial storyboard constraint"
    @IBOutlet var cardTitleViewInitialCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var cardTitleViewInitialTopConstraint: NSLayoutConstraint!
  
    
    
    //
    //
    //
    //
    // MARK: - Methods
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAutolayoutStates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupAutolayoutStates()
        
        xibView.layer.shadowColor = UIColor.blackColor().CGColor
        xibView.layer.shadowOffset = CGSizeZero;
        xibView.layer.shadowRadius = 5.0;
        xibView.layer.shadowOpacity = 0.5;
    }
    
    func setupAutolayoutStates() {
        currentStateView = tableVisibilityStateView
        currentPositionConstraintSet = [cardTitleViewInitialCenterXConstraint, cardTitleViewInitialTopConstraint]
        
        tableVisibilityStatePositionConstraintSet = [tableVisibilityStateViewCenterXConstraint, tableVisibilityStateViewTopConstraint]
        revealedVisibilityStatePositionConstraintSet = [revealedVisibilityStateViewCenterXConstraint, revealedVisibilityStateViewCenterYConstraint]
    
        switchToTableVisibilityState()
    }
    
    func switchToRevealedVisibilityState() {
        currentPositionConstraintSet = cardTitleView.mirrorConstraints(
            revealedVisibilityStatePositionConstraintSet!,
            ofView: revealedVisibilityStateView,
            byReplacingConstraints: currentPositionConstraintSet!)
    }
    
    func switchToTableVisibilityState() {
        currentPositionConstraintSet = cardTitleView.mirrorConstraints(
            tableVisibilityStatePositionConstraintSet!,
            ofView: tableVisibilityStateView,
            byReplacingConstraints: currentPositionConstraintSet!)
    }

}
