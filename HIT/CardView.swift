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
    
    var annotation: CardAnnotation? {
        didSet {
            
        }
    }

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
    
    @IBOutlet var cardTitleViewInitialCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var cardTitleViewInitialTopConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var title: UILabel!
    
    
    //
    //
    //
    //
    // MARK: - Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAutolayoutStates()
//        setupShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupAutolayoutStates()
//        setupShadow()
    }
    
    func setupShadow() {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeZero
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.5
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
    
    func preferredGapVisibleWhenInTable() -> CGFloat {
        return tableVisibilityStateView.frame.height
    }

}
