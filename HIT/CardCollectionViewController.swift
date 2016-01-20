//
//  CardCollectionViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/28/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "CardCollectionViewCell"

class CardCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    //
    //
    //
    //
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    //
    //
    //
    //
    // MARK: - Properties
    
    var cardFlowLayout = CollectionViewCardFlowLayout()
    var pulledCardLayout = CollectionViewPulledCardLayout()
    
    var cardTransitionLayout: CardTransitionLayout?
    
    
    
    //
    //
    //
    //
    // MARK: - View lifecycle

    override func viewDidLoad()
    {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        collectionView.alwaysBounceVertical = true
        collectionView.setCollectionViewLayout(cardFlowLayout, animated: false)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        cardFlowLayout.itemSize = CGSize(width: view.bounds.width-4, height: 25)
        cardFlowLayout.cardHeight = 400
        cardFlowLayout.cardMargin = 100
        cardFlowLayout.slowingLimit = 75
        cardFlowLayout.topInset = 150
        cardFlowLayout.minimumLineSpacing = 0
        
        pulledCardLayout.cardSize = cardFlowLayout.cardSize
    }
    
    
    //
    //
    //
    //
    // MARK: - IBActions
    
    
    @IBAction func finishTransition() {
        self.collectionView.finishInteractiveTransition()
    }


    
    //
    //
    //
    //
    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 100
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            cellReuseIdentifier,
            forIndexPath: indexPath) as! CardCollectionViewCell
        
        let cardColor = UIColor.randomColor()
        cell.cardView.cardTitleView.backgroundColor = cardColor
        cell.cardView.xibView.backgroundColor = cardColor
        cell.cardView.title.text = "\(indexPath.item)"
        return cell
    }

    
    
    //
    //
    //
    //
    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath)
        
        -> Bool
    {
        // Have to embed setCollectionViewLayout:animated: in an animation
        // block as a work around for content offset bug.
        if collectionView.collectionViewLayout.isKindOfClass(CollectionViewPulledCardLayout.self)
        {
            cardFlowLayout.invalidateLayout()
//            let currentContentOffset = collectionView.contentOffset
            collectionView.scrollEnabled = true
            
            collectionView.transitionToCollectionViewLayout(
                cardFlowLayout,
                duration: 0.4,
                easing: QuadraticEaseInOut,
                completion: { (completed, finish) in
                    self.cardFlowLayout.invalidateLayout()
                    print("content offset after transition back: \(collectionView.contentOffset)")
                })
//            collectionView.transitionToCollectionViewLayout(cardFlowLayout, duration: 2.0, completion: nil)

//            UIView.animateWithDuration(2.0) { () -> Void in
//                collectionView.setCollectionViewLayout(self.cardFlowLayout, animated: false)
//                collectionView.contentOffset = currentContentOffset
//            }
        }
        else
        {
//            pulledCardFlowLayout.cardAtTopOfStack = cardFlowLayout.cardAtTopOfStack
//            pulledCardFlowLayout.pulledCard = indexPath
            
            pulledCardLayout.pulledCard = indexPath
            pulledCardLayout.contentSize = cardFlowLayout.collectionViewContentSize()
            
            pulledCardLayout.centerX = self.collectionView.bounds.width / 2
            
            let itemsInStack
                = cardFlowLayout.layoutAttributesForElementsInRect(collectionView.bounds)?
                    .map { $0.indexPath.item } ?? []
            
            print(itemsInStack)
            pulledCardLayout.itemsInStack = itemsInStack
            print(pulledCardLayout.itemsInStack)
            
//            collectionView.transitionToCollectionViewLayout(
//                pulledCardLayout,
//                duration: 0.5,
//                easing: QuadraticEaseInOut,
//                completion: nil)
//            collectionView.transitionToCollectionViewLayout(pulledCardFlowLayout, duration: 2.0, completion: nil)

            
//            pulledCardFlowLayout.invalidateLayout()
//            let currentContentOffset = collectionView.contentOffset
//            collectionView.scrollEnabled = false
//            UIView.animateWithDuration(2.0) { () -> Void in
//                collectionView.setCollectionViewLayout(self.pulledCardFlowLayout, animated: false)
//                collectionView.contentOffset = currentContentOffset
//            }
            
            collectionView.startInteractiveTransitionToCollectionViewLayout(pulledCardLayout,
                completion: { (completed, finish) in
                    print("interactive transition completion handler called,\n   completed: \(completed), finish: \(finish)")
                    print("content offset after transition: \(collectionView.contentOffset)")
                    collectionView.contentOffset = self.cardTransitionLayout!.toContentOffset
                    print("content offset after transition, after setting: \(collectionView.contentOffset)")
                    print("collection view layout type: \(collectionView.collectionViewLayout.dynamicType)")
                    self.cardTransitionLayout = nil
                    print("\n\n\n\n\n")
            })
        }
        
//        collectionView.setCollectionViewLayout(pulledCardFlowLayout, animated: false)
//        collectionView.contentOffset
        
        return false
    }
    
    func collectionView(collectionView: UICollectionView,
        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
        newLayout toLayout: UICollectionViewLayout)
        
        -> UICollectionViewTransitionLayout
    {
        if fromLayout.isKindOfClass(CollectionViewCardFlowLayout.self)
            && toLayout.isKindOfClass(CollectionViewPulledCardLayout.self)
        {
            print("providing CardTransitionLayout")
            
            cardTransitionLayout = CardTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
            return cardTransitionLayout!
        }
        else
        {
            print("providing TLTransitionLayout")

            let transitionLayout = TLTransitionLayout(
                currentLayout: fromLayout,
                nextLayout: toLayout,
                supplementaryKinds: [])
            
            transitionLayout.toContentOffset
                = fromLayout.collectionView!.contentOffset
            
            return transitionLayout
        }
    }
}
