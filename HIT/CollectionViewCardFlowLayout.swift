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
            return itemSize.height/3
        }
    }
    
    
    // MARK: - UICollectionViewFlowLayout override
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        print("in rect")
        
        guard let superAttributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        // filter for item attributes
        let cardMarginAttributes = superAttributes.filter({ (attributes) -> Bool in
            return attributes.representedElementCategory == .Cell
        })
        
        let cardAttributes = cardMarginAttributes.map { (attributes) -> UICollectionViewLayoutAttributes in
            return layoutAttributesForSupplementaryViewOfKind(SupplementaryViewKind.Card.rawValue, atIndexPath: attributes.indexPath)!
        }
        
        return superAttributes + cardAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let superAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)!.copy() as! UICollectionViewLayoutAttributes
        superAttributes.zIndex = indexPath.item * 2 + 1
        
        guard   let cardAtTopOfStack = cardAtTopOfStack
                else
        {
            return superAttributes
        }
        
        if indexPath == cardAtTopOfStack
        {
            superAttributes.frame.origin.y = self.collectionView!.bounds.origin.y
        }
        else if indexPath == cardAtTopOfStack.nextItem()
        {
            let distanceFromTop = superAttributes.frame.origin.y - self.collectionView!.bounds.origin.y
            
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
                superAttributes.frame.origin.y += progressPastLimitPercent * progressPastLimit/2
            }
        }
        
//        print("layout attributes for index path: \(indexPath)")
        
        return superAttributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        print("supplementary attributes for index path: \(indexPath)")
        
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
            
//            print("still in supp")
            
            let cardAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: elementKind,
                withIndexPath: indexPath)
            let cardFrame = CGRect(
                x: cardMarginAttributes.frame.origin.x,
                y: cardMarginAttributes.frame.origin.y,
                width: cardSize.width,
                height: cardHeight)
            cardAttributes.frame = cardFrame
            cardAttributes.zIndex = indexPath.item * 2
            
            return cardAttributes
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContextForBoundsChange(newBounds)
        
        // if the bounds' width has changed (maybe due to device rotation),
        // invalidate everything
        guard   let bounds = self.collectionView?.bounds
                where bounds.size == newBounds.size
                else
        {
            print("width change")
            return context
        }
        
//        print("\n\n \(newBounds)")
        
        var indexPathsToInvalidate = [NSIndexPath]()
        if let cardAtTopOfStack = cardAtTopOfStack {
            indexPathsToInvalidate.append(cardAtTopOfStack)
            indexPathsToInvalidate.append(cardAtTopOfStack.nextItem())
        }
        
        if newBounds.origin.y < 0
        {
            cardAtTopOfStack = nil
        }
        else if cardAtTopOfStack == nil
        {
            cardAtTopOfStack = NSIndexPath(forItem: 0, inSection: 0)
            indexPathsToInvalidate.append(cardAtTopOfStack!)
            indexPathsToInvalidate.append(cardAtTopOfStack!.nextItem())
        }
        else
        {
            let topOfStackDetectionRect = CGRect(
                origin: CGPoint(x: newBounds.origin.x, y: newBounds.origin.y - slowingLimit),
                size: CGSize(width: newBounds.width, height: 1))
            
            if let attributes = super.layoutAttributesForElementsInRect(topOfStackDetectionRect)?.first
            {
                let newCardAtTopOfStack = attributes.indexPath
                
                if newCardAtTopOfStack != cardAtTopOfStack {
                    indexPathsToInvalidate.append(newCardAtTopOfStack)
                    indexPathsToInvalidate.append(newCardAtTopOfStack.nextItem())
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
