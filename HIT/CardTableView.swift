//
//  CardTableView.swift
//  HIT
//
//  Created by Nathan Melehan on 12/19/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

protocol CardTableViewDelegate
{
    func numberOfCardsInCardTableView(cardTableView: CardTableView) -> Int
    func cardTableView(cardTableView: CardTableView, annotationAtIndex index: Int)
        -> CardAnnotation
    
    
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
    
    var cardViews = [IBTestCardView]()
    
    var delegate: CardTableViewDelegate? {
        didSet {
            reloadData()
        }
    }
    
    @IBInspectable var cardHeight: CGFloat {
        get {
            return pulledCardStateViewHeightConstraint.constant
        }
        set {
            pulledCardStateViewHeightConstraint =
                NSLayoutConstraint.updateConstraint(pulledCardStateViewHeightConstraint, withNewConstant: newValue)
        }
    }
    
    @IBInspectable var tableExtensionDistanceFromTop: CGFloat {
        get {
            return tableExtensionStateViewTopConstraint.constant
        }
        set {
            tableExtensionStateViewTopConstraint =
                NSLayoutConstraint.updateConstraint(tableExtensionStateViewTopConstraint, withNewConstant: newValue)
        }
    }
    
    @IBInspectable var tableCollapsedHeight: CGFloat {
        get {
            return tableCollapsedStateViewHeightConstraint.constant
        }
        set {
            tableCollapsedStateViewHeightConstraint =
                NSLayoutConstraint.updateConstraint(tableCollapsedStateViewHeightConstraint, withNewConstant: newValue)
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
        
//        if delegate == nil {
            setPulledCardStateViewCenterConstraintsForLocation(nextCardPullLocation())
//        }
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
    
    func reloadData() {
        // clear old cardview array, repopulate with data from delegate
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        cardViews = [IBTestCardView]()
        
        if let delegate = delegate
        {
            for index in 0..<delegate.numberOfCardsInCardTableView(self)
            {
                let cardView = IBTestCardView()
                cardView.annotation = delegate.cardTableView(self, annotationAtIndex: index)
                cardViews.append(cardView)
                cardView.translatesAutoresizingMaskIntoConstraints = false
                self.xibView.addSubview(cardView)
                
                NSLayoutConstraint.pinItem(cardView, toItem: pulledCardStateView, withAttribute: .Width).active = true
                NSLayoutConstraint.pinItem(cardView, toItem: pulledCardStateView, withAttribute: .Height).active = true
                NSLayoutConstraint.pinItem(cardView, toItem: self, withAttribute: .CenterX).active = true
                
                if index == 0
                {
                    NSLayoutConstraint(
                        item: cardView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: tableExtensionStateView,
                        attribute: .Top,
                        multiplier: 1,
                        constant: 0).active = true
                }
                else
                {
                    let previousCardView = cardViews[index-1]
                    NSLayoutConstraint(
                        item: cardView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: previousCardView.tableVisibilityStateView,
                        attribute: .Bottom,
                        multiplier: 1,
                        constant: 0).active = true
                }
            }
        }
    }
    
}
