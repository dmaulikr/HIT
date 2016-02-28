//
//  PulledCardViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 2/2/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit
import GameKit

class   CollapsedCardStackViewController:
        UIViewController,
        CollapsedCardStackViewDelegate,
        UIViewControllerTransitioningDelegate
{

    @IBOutlet weak var collapsedCardStackView: CollapsedCardStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    // Data controller
    
    let dataSource: UserMantraDataManager = UserMantraDataManager.sharedManager
    
    override func viewDidLayoutSubviews()
    {
        if collapsedCardStackView.delegate == nil
        {
            range = randomRange()
            collapsedCardStackView.dataSource = dataSource
            collapsedCardStackView.delegate = self
        }
    }
    
    var rangeLength: Int {
        get {
            return min(5, dataSource.numberOfItems())
        }
    }
    var range: NSRange?
    
    func randomRange() -> NSRange
    {
        let randomCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(
            dataSource.numberOfItems() - rangeLength)
        return NSMakeRange(randomCard, rangeLength)
    }
    
    @IBAction func setRandomRangeButtonPressed()
    {
        range = randomRange()
        collapsedCardStackView.setRangeOfCardsInCollapsedStack(range!, animated: true)
    }
    
    var currentPulledCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(5)
    
    func pulledCard() -> Int
    {
        if dataSource.numberOfItems() == 1 {
            return 0
        }
        
        var randomCard = currentPulledCard
        while currentPulledCard == randomCard {
            randomCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(dataSource.numberOfItems())
        }
        print("randomCard: \(randomCard)")
        currentPulledCard = randomCard
        return randomCard
    }
    
    func rangeOfCardsInCollapsedStack() -> NSRange
    {
        return range!
    }
    
    func shouldShufflePulledCard() -> Bool {
        return true
    }
    
    func collapsedCardStackViewDidPromptSettingsView(ccsv: CollapsedCardStackView) {
        performSegueWithIdentifier("Show Settings", sender: self)
    }
    
    
}
