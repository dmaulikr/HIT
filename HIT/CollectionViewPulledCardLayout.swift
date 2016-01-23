//
//  CollectionViewPulledCardLayout.swift
//  HIT
//
//  Created by Nathan Melehan on 1/18/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class CollectionViewPulledCardLayout: UICollectionViewLayout
{
    
    // State information
    
    var pulledCard: NSIndexPath?
    var itemsInStack = [Int]()
        {
        didSet {
            itemsInStack = itemsInStack.sort()
        }
    }
    
    // Metrics
    
    var contentSize = CGSizeZero
    var cardSize = CGSize(width: 50, height: 50)
    var pulledCardYOrigin: CGFloat = -50
    var centerX: CGFloat = 50
    var retractedCardStackHeight: CGFloat = 50
    var retractedCardGap: CGFloat = 5
    
    
    // UICollectionViewLayout subclassing
    
    override func collectionViewContentSize() -> CGSize
    {
        return contentSize
    }
    
    override func prepareLayout() {
        super.prepareLayout()
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributes = itemsInStack.map {
            layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: $0, inSection: 0))!
        }
        
        if let pulledCard = pulledCard {
            attributes.append(layoutAttributesForItemAtIndexPath(pulledCard)!)
        }
        
        return attributes
    }
    
    func setYCoordinateForAttributes(attributes: UICollectionViewLayoutAttributes)
    {
        if attributes.indexPath == pulledCard
        {
            attributes.frame.origin.y = self.collectionView!.bounds.origin.y + pulledCardYOrigin
        }
        else if itemsInStack.contains(attributes.indexPath.item)
        {
            var stackCardIndex = CGFloat(attributes.indexPath.item - itemsInStack.first!)
            
            if  let pulledCard = pulledCard
                where itemsInStack.contains(pulledCard.item)
                && attributes.indexPath.item > pulledCard.item
            {
                stackCardIndex -= 1
            }
            
            let distanceFromTopToRetractedStack
                = self.collectionView!.bounds.height
                - retractedCardStackHeight
            
            attributes.frame.origin.y
                = self.collectionView!.bounds.origin.y
                + distanceFromTopToRetractedStack
                + stackCardIndex * retractedCardGap
        }
        else
        {
            attributes.frame.origin.y
                = self.collectionView!.bounds.origin.y
                + self.collectionView!.bounds.height
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = CGRect(
            origin: CGPoint(x: centerX - cardSize.width/2, y: 0),
            size: cardSize)
        attributes.zIndex = indexPath.item

        setYCoordinateForAttributes(attributes)
        
        return attributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
