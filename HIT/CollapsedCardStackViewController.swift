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
        let randomCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(90)
        range = NSMakeRange(randomCard, 5)
        collapsedCardStackView.setRangeOfCardsInCollapsedStack(range, animated: false)
    }
    
    func pulledCard() -> Int
    {
        let randomCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(5) + range.location
        print("randomCard: \(randomCard)")
        return randomCard
    }
    
    func rangeOfCardsInCollapsedStack() -> NSRange
    {
        return range
    }
}
