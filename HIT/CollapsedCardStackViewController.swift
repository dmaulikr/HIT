//
//  PulledCardViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 2/2/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit
import GameKit

class CollapsedCardStackViewController: UIViewController, CollapsedCardStackViewDelegate {

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
            collapsedCardStackView.dataSource = dataSource
            collapsedCardStackView.delegate = self
        }
    }
    
    var range = NSMakeRange(0, 5)
    
    @IBAction func setRandomRangeButtonPressed()
    {
        let randomCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(5)
        range = NSMakeRange(randomCard, 5)
//        print(collapsedCardStackView)
        collapsedCardStackView.setRangeOfCardsInCollapsedStack(range, animated: true)
    }
    
    var currentPulledCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(5)
    
    func pulledCard() -> Int
    {
//        var randomCard = currentPulledCard
//        while currentPulledCard == randomCard {
//            randomCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(5) + range.location
//        }
//        print("randomCard: \(randomCard)")
//        currentPulledCard = randomCard
//        return randomCard
        return 0
    }
    
    func rangeOfCardsInCollapsedStack() -> NSRange
    {
        return range
    }
}
