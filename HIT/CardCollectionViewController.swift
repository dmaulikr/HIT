//
//  CardCollectionViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/28/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "CardCollectionViewCell"

class CardCollectionViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    PullableCardFlowLayoutDelegate
{
    
    
    
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
        cardFlowLayout.pullableCardFlowLayoutDelegate = self
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
            collectionView.scrollEnabled = false
        }
        
        return false
    }

    
    
    //
    //
    //
    //
    // MARK: - PullableCardFlowLayoutDelegate
    
    func layout(layout: PullableCardFlowLayout, didPullCardAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func layout(layout: PullableCardFlowLayout, willPullCardAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func layoutWillReturnToCardFlow(layout: PullableCardFlowLayout)
    {
        
    }
    
    func layoutDidReturnToCardFlow(layout: PullableCardFlowLayout)
    {
        collectionView.scrollEnabled = true
    }
}
