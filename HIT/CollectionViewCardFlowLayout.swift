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
    
    // MARK: - UICollectionViewFlowLayout override
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
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
        let superAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        superAttributes?.zIndex = indexPath.item * 2
        
        return superAttributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
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
            cardAttributes.zIndex = indexPath.item * 2 + 1
            
            return cardAttributes
        }
    }
    
}
