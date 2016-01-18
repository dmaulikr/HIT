//
//  CollectionViewPulledCardLayout.swift
//  HIT
//
//  Created by Nathan Melehan on 1/18/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class CollectionViewPulledCardLayout: UICollectionViewLayout {
    
    var pulledCard: NSIndexPath?
    var pulledCardYOrigin: CGFloat = -50
    var centerX: CGFloat = 50
    
    var retractedCardStackHeight: CGFloat = 50
    var retractedCardGap: CGFloat = 5
    
    var contentSize = CGSizeZero
    
    var cardSize = CGSize(width: 50, height: 50)
    
    var itemsInStack = [Int]()
    {
        didSet {
            itemsInStack = itemsInStack.sort()
        }
    }
    
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
        print("set y")
        if attributes.indexPath == pulledCard
        {
            attributes.frame.origin.y = self.collectionView!.bounds.origin.y + pulledCardYOrigin
        }
        else if itemsInStack.contains(attributes.indexPath.item)
        {
            let stackCardIndex = CGFloat(attributes.indexPath.item - itemsInStack.first!)
            
            let distanceFromTopToRetractedStack
                = self.collectionView!.bounds.height
                - retractedCardStackHeight
            
            attributes.frame.origin.y
                = self.collectionView!.bounds.origin.y
                + distanceFromTopToRetractedStack
                + stackCardIndex * retractedCardGap
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        if !itemsInStack.contains(indexPath.item) && indexPath != pulledCard { return nil }
        
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
