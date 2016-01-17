//
//  CardCollectionViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/28/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "CardCollectionViewCell"
//private let cardSupplementaryViewReuseIdentifier = "CardCollectionViewCell"

class CardCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var testButton: UIButton!
    
    var cardFlowLayout = CollectionViewCardFlowLayout()
    var pulledCardFlowLayout = CollectionViewPulledCardFlowLayout()
    
    @IBAction func testButtonPressed(sender: AnyObject) {
        print("pressed")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        collectionView.alwaysBounceVertical = true
//        collectionView.registerClass(
//            CardCollectionViewCell.self,
//            forSupplementaryViewOfKind: CollectionViewCardFlowLayout.SupplementaryViewKind.Card.rawValue,
//            withReuseIdentifier: cardSupplementaryViewReuseIdentifier)
        
        collectionView.setCollectionViewLayout(cardFlowLayout, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cardFlowLayout.itemSize = CGSize(width: view.bounds.width-4, height: 25)
        cardFlowLayout.cardHeight = 400
        cardFlowLayout.cardMargin = 100
        cardFlowLayout.slowingLimit = 75
        cardFlowLayout.topInset = 0
        cardFlowLayout.minimumLineSpacing = 0
        
        pulledCardFlowLayout.itemSize = CGSize(width: view.bounds.width-4, height: 25)
        pulledCardFlowLayout.cardHeight = 400
        pulledCardFlowLayout.cardMargin = 100
        pulledCardFlowLayout.slowingLimit = 75
        pulledCardFlowLayout.topInset = 0
        pulledCardFlowLayout.minimumLineSpacing = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 10000
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


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        print(indexPath)
        
        // Have to embed setCollectionViewLayout:animated: in an animation
        // block as a work around for content offset bug.
        if collectionView.collectionViewLayout.isKindOfClass(CollectionViewPulledCardFlowLayout.self)
        {
            cardFlowLayout.invalidateLayout()
//            let currentContentOffset = collectionView.contentOffset
            collectionView.scrollEnabled = true
            
            collectionView.transitionToCollectionViewLayout(
                cardFlowLayout,
                duration: 0.5,
                easing: QuadraticEaseInOut,
                completion: nil)
//            collectionView.transitionToCollectionViewLayout(cardFlowLayout, duration: 2.0, completion: nil)

//            UIView.animateWithDuration(2.0) { () -> Void in
//                collectionView.setCollectionViewLayout(self.cardFlowLayout, animated: false)
//                collectionView.contentOffset = currentContentOffset
//            }
        }
        else
        {
            pulledCardFlowLayout.cardAtTopOfStack = cardFlowLayout.cardAtTopOfStack
            pulledCardFlowLayout.pulledCard = indexPath
            
            collectionView.transitionToCollectionViewLayout(
                pulledCardFlowLayout,
                duration: 0.5,
                easing: QuadraticEaseInOut,
                completion: nil)
//            collectionView.transitionToCollectionViewLayout(pulledCardFlowLayout, duration: 2.0, completion: nil)

            
//            pulledCardFlowLayout.invalidateLayout()
//            let currentContentOffset = collectionView.contentOffset
//            collectionView.scrollEnabled = false
//            UIView.animateWithDuration(2.0) { () -> Void in
//                collectionView.setCollectionViewLayout(self.pulledCardFlowLayout, animated: false)
//                collectionView.contentOffset = currentContentOffset
//            }
        }
        
//        collectionView.setCollectionViewLayout(pulledCardFlowLayout, animated: false)
//        collectionView.contentOffset
        
        return false
    }
    
    func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        
        let transitionLayout = TLTransitionLayout(
            currentLayout: fromLayout,
            nextLayout: toLayout,
            supplementaryKinds: [])
        
        print("getting transition layout")
        
        transitionLayout.toContentOffset = fromLayout.collectionView!.contentOffset
        
        return transitionLayout
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
