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
    
    
    
    
    func pulledCard() -> Int
    {
        if let currentCard = collapsedCardStackView.pulledCard {
            let nextCard = (currentCard - 5 + 1)%5 + 5
            print("next card: \(nextCard)")
            return nextCard
        }
        else {
            let randomCard = GKRandomSource.sharedRandom().nextIntWithUpperBound(5) + 5
            print("randomCard: \(randomCard)")
            return randomCard
        }
    }
    
    func rangeOfCardsInCollapsedStack() -> NSRange
    {
        return NSMakeRange(5, 5)
    }
}
