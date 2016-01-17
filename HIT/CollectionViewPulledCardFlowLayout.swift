//
//  CollectionViewPulledCardFlowLayout.swift
//  HIT
//
//  Created by Nathan Melehan on 1/15/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

class CollectionViewPulledCardFlowLayout: CollectionViewCardFlowLayout
{
    var pulledCard: NSIndexPath?
    
    var retractedCardStackHeight: CGFloat = 50
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        print("in rect, bounds: \(self.collectionView!.bounds)")
        
        // filter for item attributes
        
        let attributes = superAttributes.map { (superAttributes) -> UICollectionViewLayoutAttributes in
            switch superAttributes.representedElementCategory
            {
            case .Cell:
                return layoutAttributesForItemAtIndexPath(superAttributes.indexPath)!
            default:
                return superAttributes
            }
        }
        
        return attributes
    }
    
    func setYCoordinateForAttributes(attributes: UICollectionViewLayoutAttributes)
    {
        if attributes.indexPath == pulledCard
        {
            attributes.frame.origin.y = self.collectionView!.bounds.origin.y
        }
        else
        {
            let distanceFromTopToRetractedStack = self.collectionView!.bounds.height - retractedCardStackHeight
            
            let distanceFromTopToAttributes = attributes.frame.origin.y - self.collectionView!.bounds.origin.y
            let percentageDistance = distanceFromTopToAttributes / self.collectionView!.bounds.height
            
            attributes.frame.origin.y = self.collectionView!.bounds.origin.y + percentageDistance * retractedCardStackHeight + distanceFromTopToRetractedStack
    
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let superAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)!.copy() as! UICollectionViewLayoutAttributes
        
        setYCoordinateForAttributes(superAttributes)
        
        return superAttributes
    }

    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        super.shouldInvalidateLayoutForBoundsChange(newBounds)
        
        return true
    }
    
    
    override func invalidationContextForBoundsChange(newBounds: CGRect)
        
        -> UICollectionViewLayoutInvalidationContext
    {
        let context = super.invalidationContextForBoundsChange(newBounds)
        
        var indexPathsToInvalidate = [NSIndexPath]()
        
        let bounds = self.collectionView!.bounds
        let attributesInOldBounds = super.layoutAttributesForElementsInRect(bounds)
        indexPathsToInvalidate += attributesInOldBounds?
            .map { (attributes) -> NSIndexPath in return attributes.indexPath }
            ?? []
        
        let attributesInNewBounds = super.layoutAttributesForElementsInRect(newBounds)
        indexPathsToInvalidate += attributesInNewBounds?
            .map { (attributes) -> NSIndexPath in return attributes.indexPath }
            ?? []
        
//        let items = indexPathsToInvalidate
//            .map { (path) -> Int in return path.item }
//            .sort()
        
        context.invalidateItemsAtIndexPaths(indexPathsToInvalidate)
        
        return context
    }
}