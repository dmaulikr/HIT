//
//  CardTransitionLayout.swift
//  HIT
//
//  Created by Nathan Melehan on 1/18/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class CardTransitionLayout: UICollectionViewTransitionLayout, UIDynamicAnimatorDelegate
{
    
    
    
    //
    //
    //
    //
    // MARK: - Lifecycle
    
    func initSetup() {
        animator = UIDynamicAnimator(collectionViewLayout: self)
        animator?.delegate = self
    }
    
    override init(
        currentLayout: UICollectionViewLayout,
        nextLayout newLayout: UICollectionViewLayout)
    {
        super.init(currentLayout: currentLayout, nextLayout: newLayout)
        
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        initSetup()
    }
    
    
    
    //
    //
    //
    //
    // MARK: - Properties
    
    var animator: UIDynamicAnimator?
    
    var cardFlowLayout: CardFlowLayout? {
        get {
            return currentLayout as? CardFlowLayout
        }
    }
    
    var pulledCardLayout: CollectionViewPulledCardLayout? {
        get {
            return nextLayout as? CollectionViewPulledCardLayout
        }
    }
    
    var hasProperlyAssignedEndpointLayouts: Bool {
        return cardFlowLayout != nil && pulledCardLayout != nil
    }
    
    // State information
    
    private var cardCache = [Int : UICollectionViewLayoutAttributes]()
    
    var toContentOffset = CGPointZero
    
    // Metrics
    
    var contentSize = CGSizeZero
    
    
    
    //
    //
    //
    //
    // MARK: - UIDynamicAnimatorDelegate
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
        transitionProgress = 1
        self.collectionView?.contentOffset = toContentOffset
        self.collectionView?.finishInteractiveTransition()
        print("finishing transition due to animator pause")
    }
    
    
    //
    //
    //
    //
    // MARK: - UICollectionViewLayout subclassing
    
    override func collectionViewContentSize()
        -> CGSize
    {
        return self.nextLayout.collectionViewContentSize()
    }
    
    func setupAttachmentBehaviorForIndexPath(indexPath: NSIndexPath)
    {
        let startingAttributes = cardFlowLayout!
            .layoutAttributesForItemAtIndexPath(indexPath)!.copy()
            as! UICollectionViewLayoutAttributes
        
        let finalAttributes = pulledCardLayout!
            .layoutAttributesForItemAtIndexPath(indexPath)!.copy()
            as! UICollectionViewLayoutAttributes
        
        print("\nsetting up indexPath.")
        print("  startingAttributes: \(startingAttributes)")
        print("  finalAttributes: \(finalAttributes)")
        
        if cardCache[indexPath.item] == nil {
            let behavior = UIAttachmentBehavior(item: startingAttributes,
                attachedToAnchor: finalAttributes.center)
            
            print(behavior)
            
            behavior.length = 0.0
            behavior.damping = 1.0
            behavior.frequency = 2.0
            
//            let pushBehavior = UIPushBehavior(items: [startingAttributes], mode: .Instantaneous)
//            pushBehavior.angle = CGFloat(M_PI/4)
//            pushBehavior.magnitude = 1.0
            
            animator?.addBehavior(behavior)
//            animator?.addBehavior(pushBehavior)
            cardCache[indexPath.item] = startingAttributes
        }
    }
    
    override func prepareLayout()
    {
        super.prepareLayout()
        
        guard hasProperlyAssignedEndpointLayouts else {
            self.collectionView!.cancelInteractiveTransition()
            print("cancelling transition due to incorrectly assigned layouts")
            return
        }
        
        if cardCache.values.count == 0 {
            print("setting up animator")
            toContentOffset = self.collectionView!.contentOffset
            
            for item in pulledCardLayout!.itemsInStack
            {
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                setupAttachmentBehaviorForIndexPath(indexPath)
            }
            
            if animator!.behaviors.count > 0 {
                let firstBehavior = animator!.behaviors.first! as! UIAttachmentBehavior
                animator!.behaviors.first!.action =
                    {
                        print("behavior's item: \(firstBehavior.items.first)")
                        if let attributes = firstBehavior.items.first as? UICollectionViewLayoutAttributes {
                            print("corresponding cardCache attributes: \(self.cardCache[attributes.indexPath.item])")
                        }
                        print("content offset: \(self.collectionView?.contentOffset)")
                        print("layout type: \(self.collectionView?.collectionViewLayout.dynamicType)")
                        self.collectionView?.contentOffset = self.toContentOffset
                    }
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect)
        -> [UICollectionViewLayoutAttributes]?
    {
        print("in rect: \(rect), offset: \(collectionView?.contentOffset)")
        
        if  let newOffset = collectionView?.contentOffset
            where newOffset != toContentOffset {
            print("offset mismatch")
        }
        
        if  let animatorItems = animator?.itemsInRect(rect) as? [UICollectionViewLayoutAttributes]
            where animatorItems.count > 0
        {
            return animatorItems
        }
        else {
            return Array(cardCache.values)
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        print("for item at indexPath: \(indexPath)")
        
        if let animatorItem = animator?.layoutAttributesForCellAtIndexPath(indexPath)
        {
            return animatorItem
        }
        else {
            return cardCache[indexPath.item]
        }
    }
}
