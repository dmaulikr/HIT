//
//  CollectionViewCardFlowLayout.swift
//  HIT
//
//  Created by Nathan Melehan on 12/28/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class CollectionViewCardFlowLayout: UICollectionViewFlowLayout {
    
    enum SupplementaryViewKind: String {
        case Card = "card"
    }
    
    @IBInspectable var cardHeight: CGFloat = 100
    var cardSize: CGSize {
        get {
            return CGSize(width: itemSize.width, height: cardHeight)
        }
        set {
            cardHeight = newValue.height
            itemSize = CGSize(width: newValue.width, height: itemSize.height)
        }
    }
    
    // the card margin is the height of the visible section of a card
    // when stacked in the collection view
    var cardMargin: CGFloat {
        get {
            return itemSize.height
        }
        set {
            itemSize = CGSize(width: itemSize.width, height: newValue)
        }
    }
    
    var cardAtTopOfStack: NSIndexPath? = NSIndexPath(forItem: 0, inSection: 0)
    
    
    // Represents the distance at which a card begins to slow
    // when approaching the top of the collection view's bounds
    //
    var slowingLimit: CGFloat {
        get {
            return 300
        }
    }
    
    // MARK: - UICollectionViewFlowLayout override
    
    func initSetup() {
        minimumInteritemSpacing = 0
    }
    
    override init() {
        super.init()
        
        initSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initSetup()
    }
    
    override func prepareLayout() {
        setSectionInsetForBounds(self.collectionView!.bounds)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        guard let superAttributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        // filter for item attributes
        let itemSuperAttributes = superAttributes.filter({ (superAttributes) -> Bool in
            return superAttributes.representedElementCategory == .Cell
        })
        
        let allOtherSuperAttributes = superAttributes.filter({ (superAttributes) -> Bool in
            return superAttributes.representedElementCategory != .Cell
        })
        
        let cardMarginAttributes = itemSuperAttributes.map { (superAttributes) -> UICollectionViewLayoutAttributes in
            let attributes = superAttributes.copy() as! UICollectionViewLayoutAttributes
            setZIndexForAttributes(attributes)
            
            return attributes
        }
        
        let cardAttributes = cardMarginAttributes.map { (attributes) -> UICollectionViewLayoutAttributes in
            return layoutAttributesForSupplementaryViewOfKind(SupplementaryViewKind.Card.rawValue, atIndexPath: attributes.indexPath)!
        }
        
        return cardMarginAttributes + cardAttributes + allOtherSuperAttributes
    }
    
    func setZIndexForAttributes(attributes: UICollectionViewLayoutAttributes)
    {
        switch attributes.representedElementCategory
        {
        case .Cell:
            attributes.zIndex = attributes.indexPath.item * 2 + 1
        case .SupplementaryView:
            attributes.zIndex = attributes.indexPath.item * 2
        default:
            break
        }
    }
    
    func applyStackingTransformationToAttributes(attributes: UICollectionViewLayoutAttributes)
    {
        let indexPath = attributes.indexPath
        
        // If we've scrolled into the negative gutter,
        // we stretch the cards out away from each other.
        
        if  let y = self.collectionView?.bounds.origin.y
            where y < 0
        {
            let stretchingResistance: CGFloat = 10
            attributes.frame.origin.y += -1*y*CGFloat(indexPath.item)/stretchingResistance
            return
        }
        
        guard   let cardAtTopOfStack = cardAtTopOfStack
                else
        {
            return
        }
        
        // Pin the card at the top of the stack
        // to the current bounds of the scroll view.
        
        if indexPath == cardAtTopOfStack
        {
            attributes.frame.origin.y = self.collectionView!.bounds.origin.y
        }
            
            // Slow the next card down.
            
        else if indexPath.item > cardAtTopOfStack.item // if indexPath == cardAtTopOfStack.nextItem()
//            || indexPath == cardAtTopOfStack.nextItem().nextItem()
        {
            let distanceFromTop = attributes.frame.origin.y - self.collectionView!.bounds.origin.y
            
            // If the card of the super class has travelled past
            // the "slowing distance" limit, we begin to impede its movement
            // so that it slowly approaches the top of the collection view
            
            if distanceFromTop < slowingLimit {
                
                // We measure how far past the slowing distance
                // that the card of the super class has travelled.
                
                // We then take that as a percentage of the total distance
                // it will travel in the super class layout before it rests
                // at the top of our collection view
                
                // We multiply that percentage by half the progress past the
                // slowing limit that has been achieved. We add that result
                // to the y-coordinate of our card so that its movement is
                // impeded as it approaches the top of the collection view bounds.
                
                // As well, by including the progress percentage into the calculation,
                // the card is impeded less when it has just passed the limit,
                // and by more (i.e. it travels more slowly) when it is very near
                // its final resting place.
                
                let progressPastLimit = slowingLimit - distanceFromTop
                let progressPastLimitPercent = progressPastLimit/(slowingLimit * 2)
                attributes.frame.origin.y += progressPastLimitPercent * progressPastLimit/2
            }
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let superAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)!.copy() as! UICollectionViewLayoutAttributes
        
        setZIndexForAttributes(superAttributes)
        applyStackingTransformationToAttributes(superAttributes)
        
        return superAttributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        if let superAttributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath) {
            return superAttributes
        }
        
        guard let supplementaryViewKind = SupplementaryViewKind(rawValue: elementKind) else {
            return nil
        }
        
        switch supplementaryViewKind {
        case .Card:
            guard let cardMarginAttributes = self.layoutAttributesForItemAtIndexPath(indexPath) else {
                return nil
            }
            
            let cardAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: elementKind,
                withIndexPath: indexPath)
            let cardFrame = CGRect(
                x: cardMarginAttributes.frame.origin.x,
                y: cardMarginAttributes.frame.origin.y,
                width: cardSize.width,
                height: cardHeight)
            cardAttributes.frame = cardFrame
            setZIndexForAttributes(cardAttributes)
            
            if  let cardAtTopOfStack = cardAtTopOfStack
                where indexPath.item < cardAtTopOfStack.item
            {
                cardAttributes.alpha = 0
            }
            else {
                cardAttributes.alpha = 1
            }
            
            return cardAttributes
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    func setSectionInsetForBounds(bounds: CGRect) {
        let leftRightInset = (bounds.width - itemSize.width)/2
        sectionInset = UIEdgeInsets(top: 0, left: leftRightInset, bottom: 0, right: leftRightInset)
    }
    
    override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContextForBoundsChange(newBounds)
        
        setSectionInsetForBounds(newBounds)
        
        // if the bounds' width has changed (maybe due to device rotation),
        // invalidate everything.
        
        guard   let bounds = self.collectionView?.bounds
                where bounds.size == newBounds.size
                else
        {
            return context
        }
        
        
        var indexPathsToInvalidate = [NSIndexPath]()
        
        // If we're scrolled into the negative gutter,
        // then we want to stretch the cards away from each other,
        // so we invalidate all the cards that are visible.
        
        if newBounds.origin.y < 0
        {
            cardAtTopOfStack = nil
            super.layoutAttributesForElementsInRect(newBounds)?
                .forEach({ attributes in
                    indexPathsToInvalidate.append(attributes.indexPath)
                })
        }
            
        // If we're in positive-scrolling coordinates but the
        // the card at the top of the stack is nil,
        // then we've just transitioned from scrolling out of 
        // the negative gutter.
        // We set the card at the top of the stack to be the first 
        // card and invalidate all the visible cards.
            
        else if cardAtTopOfStack == nil
        {
            cardAtTopOfStack = NSIndexPath(forItem: 0, inSection: 0)
            super.layoutAttributesForElementsInRect(newBounds)?
                .forEach({ attributes in
                    indexPathsToInvalidate.append(attributes.indexPath)
                })
        }
            
        // Otherwise, we're currently somewhere further down
        // in the scroll view.
        // We invalidate the most recent card at the top of the stack
        // and update the top card if needed, and invalidate that one too.
        // We also invalidate the following card so that we can slow its
        // travel as it reaches the top.
            
        else
        {
            let currentBounds = self.collectionView!.bounds
            let topOfStackDetectionRectForCurrentBounds = CGRect(
                x: currentBounds.origin.x,
                y: currentBounds.origin.y,
                width: currentBounds.width,
                height: slowingLimit*2)
            let currentStackingAndSlowingCardAttributes =
                super.layoutAttributesForElementsInRect(topOfStackDetectionRectForCurrentBounds)?
                    .filter({ (attributes) -> Bool in
                        return attributes.representedElementCategory == .Cell
                    })
            currentStackingAndSlowingCardAttributes?.forEach({ attributes in
                indexPathsToInvalidate.append(attributes.indexPath)
            })
            
            
            let topOfStackDetectionRectForNewBounds = CGRect(
                x: newBounds.origin.x,
                y: newBounds.origin.y - slowingLimit,
                width: newBounds.width,
                height: slowingLimit*2)
            var newStackingAndSlowingCardAttributes =
                super.layoutAttributesForElementsInRect(topOfStackDetectionRectForNewBounds)?
                    .filter({ (attributes) -> Bool in
                        return attributes.representedElementCategory == .Cell
                    })
            newStackingAndSlowingCardAttributes = newStackingAndSlowingCardAttributes?
                .sort({ (attribute1, attribute2) -> Bool in
                    return attribute1.indexPath.item < attribute2.indexPath.item
                })
            newStackingAndSlowingCardAttributes?.forEach({ attributes in
                indexPathsToInvalidate.append(attributes.indexPath)
            })
            
            
            if  let newStackingAndSlowingCardAttributes = newStackingAndSlowingCardAttributes
                where newStackingAndSlowingCardAttributes.count > 0
            {
                let newCardAtTopOfStack = newStackingAndSlowingCardAttributes.first!.indexPath
                
                if newCardAtTopOfStack != cardAtTopOfStack
                {
                    let stackChangeEndPoints =
                        [cardAtTopOfStack!.item, newCardAtTopOfStack.item].sort()
                    
                    for item in stackChangeEndPoints[0]...stackChangeEndPoints[1]
                    {
                        indexPathsToInvalidate.append(NSIndexPath(forItem: item, inSection: 0))
                    }
                    cardAtTopOfStack = newCardAtTopOfStack
                }
            }
        }
        
        context.invalidateItemsAtIndexPaths(indexPathsToInvalidate)
        context.invalidateSupplementaryElementsOfKind(
            SupplementaryViewKind.Card.rawValue,
            atIndexPaths: indexPathsToInvalidate)
        
        return context
    }
    
}
