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
    
    var cardFlowLayout = PullableCardFlowLayout()
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
        if cardFlowLayout.stackIsRetracted
        {
            cardFlowLayout.returnToCardFlow()
        }
        else {
            cardFlowLayout.pullCardAtIndexPath(indexPath)
        }
        
        return false
    }
}
