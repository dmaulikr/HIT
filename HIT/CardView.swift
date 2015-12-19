//
//  CardView.swift
//  HIT
//
//  Created by Nathan Melehan on 12/16/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class CardView: UIView {
    
    
    
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
    
    // facilitates embedding this xib-designed view inside another xib or storyboard
    @IBOutlet weak var xibView: UIView!

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
        
        xibSetup()
        setupAutolayoutStates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        setupAutolayoutStates()
    }
    
    func xibSetup() {
        NSBundle(forClass: self.dynamicType).loadNibNamed("CardView", owner: self, options: nil)
//        NSBundle.mainBundle().loadNibNamed("CardView", owner: self, options: nil)
        self.addSubview(self.xibView)
        
        // pin xibView to self
        self.xibView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Top).active = true
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Leading).active = true
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Trailing).active = true
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Bottom).active = true
    }
    
    func setupAutolayoutStates() {
        currentStateView = tableVisibilityStateView
        currentPositionConstraintSet = [cardTitleViewInitialCenterXConstraint, cardTitleViewInitialTopConstraint]
        
        tableVisibilityStatePositionConstraintSet = [tableVisibilityStateViewCenterXConstraint, tableVisibilityStateViewTopConstraint]
        revealedVisibilityStatePositionConstraintSet = [revealedVisibilityStateViewCenterXConstraint, revealedVisibilityStateViewCenterYConstraint]
    
        switchToTableVisibilityState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func switchToRevealedVisibilityState() {
        currentPositionConstraintSet = cardTitleView.mirrorConstraints(
            revealedVisibilityStatePositionConstraintSet!,
            ofView: revealedVisibilityStateView,
            byReplacingConstraints: currentPositionConstraintSet!)
    }
    
    func animateToRevealedVisibilityState() {
        
    }
    
    func switchToTableVisibilityState() {
        currentPositionConstraintSet = cardTitleView.mirrorConstraints(
            tableVisibilityStatePositionConstraintSet!,
            ofView: tableVisibilityStateView,
            byReplacingConstraints: currentPositionConstraintSet!)
    }
    
    func animateToTableVisibilityState() {
        
    }

}
