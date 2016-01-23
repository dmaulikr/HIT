//
//  CollectionViewCardFlowLayout.swift
//  HIT
//
//  Created by Nathan Melehan on 12/28/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class CardFlowLayout: UICollectionViewFlowLayout {
    
    //
    //
    //
    //
    // Properties
    
    // State information
    
    private var cardCache = [Int : UICollectionViewLayoutAttributes]()
    
    var cardAtTopOfStack: NSIndexPath?
    
    private var previousBounds: CGRect?
    private var attributesToRecalculate = [Int]()
    private var recalculateEverything = true
    
    // Metrics
    
    @IBInspectable var cardHeight: CGFloat = 100
    var cardSize: CGSize {
        get {
            return CGSize(width: itemSize.width, height: cardHeight)
        }
        set {
            cardHeight = newValue.height
            itemSize = CGSize(width: newValue.width, height: itemSize.height)
            
            invalidateLayout()
        }
    }
    
    // the card margin is the height of the visible
    // section of a card when stacked in the collection view
    
    var cardMargin: CGFloat {
        get {
            return itemSize.height
        }
        set {
            itemSize = CGSize(width: itemSize.width, height: newValue)
            
            invalidateLayout()
        }
    }
    
    var topInset: CGFloat {
        set {
            if let bounds = self.collectionView?.bounds
            {
                setSectionInsetForBounds(bounds, topInset: newValue)
            }
            else
            {
                sectionInset = UIEdgeInsets(
                    top: newValue,
                    left: sectionInset.left,
                    bottom: sectionInset.bottom,
                    right: sectionInset.right)
            }
            
            invalidateLayout()
        }
        get {
            return sectionInset.top
        }
    }
    
    // Represents the distance at which a card begins to slow
    // when approaching the top of the collection view's bounds

    var slowingLimit: CGFloat = 50 {
        didSet {
            invalidateLayout()
        }
    }
    
    override var itemSize: CGSize {
        willSet {
            if let bounds = self.collectionView?.bounds
            {
                setSectionInsetForBounds(bounds, topInset: topInset, itemSize: newValue)
            }
        }
    }
    
    
    
    //
    //
    //
    //
    // MARK: - UICollectionViewFlowLayout subclassing
    
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
    
    override class func invalidationContextClass() -> AnyClass
    {
        return CollectionViewCardFlowLayoutInvalidationContext.self
    }
    
    func observePossibleBoundsChange()
    {
        guard self.collectionView?.bounds != previousBounds else { return }
        
        previousBounds = self.collectionView?.bounds
        if let bounds = self.collectionView?.bounds
        {
            setSectionInsetForBounds(bounds)
            
            let newStackingAndSlowingCardAttributes = stackingAndSlowingCardAttributesForBounds(self.collectionView!.bounds)
            if  let newStackingAndSlowingCardAttributes = newStackingAndSlowingCardAttributes
                where newStackingAndSlowingCardAttributes.count > 0
            {
                cardAtTopOfStack = newStackingAndSlowingCardAttributes.first!.indexPath
            }
            else
            {
                cardAtTopOfStack = nil
            }
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        observePossibleBoundsChange()
        
        if recalculateEverything
        {
            if  let numberOfItems = self.collectionView?.numberOfItemsInSection(0)
                where numberOfItems > 0
            {
                for item in 0...numberOfItems
                {
                    cardCache[item] = calculateLayoutAttributesForItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0))
                }
            }
            
            recalculateEverything = false
        }
        
        for item in attributesToRecalculate
        {
            cardCache[item] = calculateLayoutAttributesForItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0))!
        }
        attributesToRecalculate.removeAll()
    }
    
    private func fetchCardFromCacheAtIndex(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes
    {
        if  let card = cardCache[indexPath.item]
            where !attributesToRecalculate.contains(indexPath.item)
        {
            return card
        }
        
        cardCache[indexPath.item] = calculateLayoutAttributesForItemAtIndexPath(indexPath)!
        attributesToRecalculate = attributesToRecalculate.filter { $0 != indexPath.item }
        
        return cardCache[indexPath.item]!
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
//        print("in rect: \(rect)")
        
        observePossibleBoundsChange()
        
        guard let superAttributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        // filter for item attributes
        let itemSuperAttributes = superAttributes
            .filter { $0.representedElementCategory == .Cell }
        
        let allOtherSuperAttributes = superAttributes
            .filter { $0.representedElementCategory != .Cell }
        
        var cardAttributes = itemSuperAttributes
            .map { fetchCardFromCacheAtIndex($0.indexPath) }
            .sort { return $0.indexPath.item < $1.indexPath.item }
        
        if  let cardAtTopOfStack = cardAtTopOfStack,
            let firstIndexPath = cardAttributes.first?.indexPath
            where cardAtTopOfStack.item < firstIndexPath.item
        {
            let extraAttributes = (cardAtTopOfStack.item...firstIndexPath.item)
                .map { fetchCardFromCacheAtIndex(NSIndexPath(forItem: $0, inSection: 0)) }
            cardAttributes.insertContentsOf(extraAttributes, at: 0)
        }
        
        return cardAttributes + allOtherSuperAttributes
    }
    
    func setZIndexForAttributes(attributes: UICollectionViewLayoutAttributes)
    {
        switch attributes.representedElementCategory
        {
        case .Cell:
            attributes.zIndex = attributes.indexPath.item
        default:
            break
        }
    }
    
    func applySlowingTransformationToAttributes(attributes: UICollectionViewLayoutAttributes)
    {
        let effectiveSlowingLimit = min(attributes.frame.origin.y, slowingLimit)
        
        let distanceFromTop = attributes.frame.origin.y - self.collectionView!.bounds.origin.y
        
        // This condition should only be met for the first few
        // cards in the stack which are initially stacked inside
        // the flow layout's slowing limit
        
        if distanceFromTop < -1 * effectiveSlowingLimit
        {
            attributes.frame.origin.y = self.collectionView!.bounds.origin.y
        }
            
        // If the card of the super class has travelled past
        // the "slowing distance" limit, we begin to impede its movement
        // so that it slowly approaches the top of the collection view
            
        else if distanceFromTop < effectiveSlowingLimit
        {
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
            
            let progressPastLimit = effectiveSlowingLimit - distanceFromTop
            let progressPastLimitPercent = progressPastLimit/(effectiveSlowingLimit * 2)
            attributes.frame.origin.y += progressPastLimitPercent * progressPastLimit/2
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
            if indexPath.item == 0
            {
                // Compute y-coordinate of the collection view's bounds
                // at which the first card of the collection starts to pin
                // to the top of the view.
                // This is an edge case raised by a positive top section inset.
                
                let y: CGFloat
                if slowingLimit > sectionInset.top {
                    y = sectionInset.top * 2
                }
                else {
                    y = slowingLimit + sectionInset.top
                }
                
                if self.collectionView!.bounds.origin.y > y {
                    attributes.frame.origin.y = self.collectionView!.bounds.origin.y
                }
                else {
                    applySlowingTransformationToAttributes(attributes)
                }
            }
            else
            {
                attributes.frame.origin.y = self.collectionView!.bounds.origin.y
            }
        }
            
        // Slow the following cards down.
            
        else if indexPath.item > cardAtTopOfStack.item
        {
            applySlowingTransformationToAttributes(attributes)
        }
    }
    
    func calculateLayoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        let superAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)!.copy() as! UICollectionViewLayoutAttributes
        
        setZIndexForAttributes(superAttributes)
        applyStackingTransformationToAttributes(superAttributes)
        
        let cardFrame = CGRect(
            x: superAttributes.frame.origin.x,
            y: superAttributes.frame.origin.y,
            width: cardSize.width,
            height: cardHeight)
        superAttributes.frame = cardFrame
        
        if  let cardAtTopOfStack = cardAtTopOfStack
            where indexPath.item < cardAtTopOfStack.item
        {
            superAttributes.alpha = 0
        }
        else {
            superAttributes.alpha = 1
        }
        
        return superAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        print("layout attributes for item at index path: \(indexPath), card at top is: \(cardAtTopOfStack)")

        return cardCache[indexPath.item]
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
//        print("\n\nshould invalidate")
        invalidateLayoutWithContext(invalidationContextForBoundsChange(newBounds))
        return super.shouldInvalidateLayoutForBoundsChange(newBounds)
    }
    
    func setSectionInsetForBounds(bounds: CGRect, topInset: CGFloat, itemSize: CGSize)
    {
        let leftRightInset = (bounds.width - itemSize.width)/2
        sectionInset = UIEdgeInsets(top: topInset, left: leftRightInset, bottom: 0, right: leftRightInset)
    }
    
    func setSectionInsetForBounds(bounds: CGRect, topInset: CGFloat) {
        setSectionInsetForBounds(bounds, topInset: topInset, itemSize: itemSize)
    }
    
    func setSectionInsetForBounds(bounds: CGRect) {
        setSectionInsetForBounds(bounds, topInset: sectionInset.top)
    }
    
    //
    //
    // Calculates which cards are either at the top of the stack
    // or within the slowing limit. Returns the attributes for those cards
    // in ascending order by their index paths.
    // Therefore, the first item in the returned array is the card
    // at the top of the stack.
    
    func stackingAndSlowingCardAttributesForBounds(bounds: CGRect)
        
        -> [UICollectionViewLayoutAttributes]?
        
    {
        let topOfStackDetectionRectForBounds: CGRect
        
        if slowingLimit > 0
        {
            topOfStackDetectionRectForBounds = CGRect(
                x: bounds.origin.x,
                y: bounds.origin.y - slowingLimit - minimumLineSpacing,
                width: bounds.width,
                height: slowingLimit * 2 + minimumLineSpacing)
        }
        else
        {
            topOfStackDetectionRectForBounds = CGRect(
                x: bounds.origin.x,
                y: bounds.origin.y - minimumLineSpacing,
                width: bounds.width,
                height: itemSize.height + minimumLineSpacing)
        }
        
        let stackingAndSlowingCardAttributes =
            super.layoutAttributesForElementsInRect(topOfStackDetectionRectForBounds)?
                .filter { $0.representedElementCategory == .Cell }
                .sort { $0.indexPath.item < $1.indexPath.item }
        
        return stackingAndSlowingCardAttributes
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
//        print("invalidate layout")
        
        recalculateEverything = true
    }
    
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayoutWithContext(context)
//        print("invalidate with context")
        
        attributesToRecalculate += context.invalidatedItemIndexPaths?
            .map { $0.item } ?? []
        
//        for indexPath in context.invalidatedItemIndexPaths ?? []
//        {
//            cardCache.removeValueForKey(indexPath.item)
//        }
        
        previousBounds = (context as? CollectionViewCardFlowLayoutInvalidationContext)?.previousBounds
    }
    
    override func invalidationContextForBoundsChange(newBounds: CGRect)
        
        -> UICollectionViewLayoutInvalidationContext
    {
        print("invalidation context for bounds change: \(newBounds)")
        
        let context = super.invalidationContextForBoundsChange(newBounds) as! CollectionViewCardFlowLayoutInvalidationContext
        
        context.previousBounds = self.collectionView?.bounds
        
        guard   let cv = self.collectionView,
                let count = cv.dataSource?.collectionView(cv, numberOfItemsInSection: 0)
                where count > 0
                else
        {
            return context
        }
        
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
        
        // We also invalidate all cards between the first and 
        // the most recent card at the top of the stack.
        
        // We do this because the user may sometimes scroll to the top
        // at high speeds, and the most recent card at the top of the stack
        // may be below the ones that are at the top of the collection view.
        
        if newBounds.origin.y < 0
        {
            if let cardAtTopOfStack = cardAtTopOfStack
            {
                indexPathsToInvalidate +=
                    (0...cardAtTopOfStack.item)
                        .map { NSIndexPath(forItem: $0, inSection: 0) }

            }
            
            super.layoutAttributesForElementsInRect(newBounds)?
                .forEach({ attributes in
                    indexPathsToInvalidate.append(attributes.indexPath)
                })
        }
            
        // If we're in positive-scrolling coordinates but the
        // the card at the top of the stack is nil,
        // then we've just transitioned from scrolling out of 
        // the negative gutter.
            
        // We invalidate all visible cards so that we can remove the
        // stretching effect that we enforced when we were in negative bounds.
            
        // We detect what the next card at the top of the stack will be,
        // and we invalidate all cards between that one and the first card.
        // This invalidation is helpful when scrolling at high speeds
        // away from the top.
            
        else if bounds.origin.y < 0 && newBounds.origin.y >= 0
        {
            let newStackingAndSlowingCardAttributes = stackingAndSlowingCardAttributesForBounds(newBounds)
            newStackingAndSlowingCardAttributes?.forEach({ attributes in
                indexPathsToInvalidate.append(attributes.indexPath)
            })
            
            if  let newStackingAndSlowingCardAttributes = newStackingAndSlowingCardAttributes
                where newStackingAndSlowingCardAttributes.count > 0
            {
                let newCardAtTopOfStack = newStackingAndSlowingCardAttributes.first!.indexPath
                
                indexPathsToInvalidate +=
                    (0...newCardAtTopOfStack.item).map { NSIndexPath(forItem: $0, inSection: 0) }
            }
            
            super.layoutAttributesForElementsInRect(newBounds)?
                .forEach({ attributes in
                    indexPathsToInvalidate.append(attributes.indexPath)
                })
        }
            
        // Otherwise, we're currently somewhere further down
        // in the scroll view.
            
        // We invalidate the most recent card at the top of the stack along
        // with all the cards within the slowing limit that follow it.
            
        // We detect what the next card at the top of the stack will be,
        // and we invalidate all cards between that one and the 
        // previous top card.
        // This invalidation is helpful when scrolling at high speeds,
        // because we may have skipped several cards.
        // We also invalidate the cards that follow the next top card 
        // that are within the slowing limit.
        
        else
        {
            let currentBounds = self.collectionView!.bounds
            stackingAndSlowingCardAttributesForBounds(currentBounds)?
                .forEach({ attributes in
                    indexPathsToInvalidate.append(attributes.indexPath)
                })
            
            
            let newStackingAndSlowingCardAttributes = stackingAndSlowingCardAttributesForBounds(newBounds)
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
                        [cardAtTopOfStack?.item ?? 0, newCardAtTopOfStack.item].sort()
                    
                    indexPathsToInvalidate +=
                        (stackChangeEndPoints[0]...stackChangeEndPoints[1])
                            .map { NSIndexPath(forItem: $0, inSection: 0) }
                }
            }
        }
        
        context.invalidateItemsAtIndexPaths(indexPathsToInvalidate)
        
        return context
    }
    
}

class CollectionViewCardFlowLayoutInvalidationContext: UICollectionViewFlowLayoutInvalidationContext
{
    var previousBounds: CGRect?
}
