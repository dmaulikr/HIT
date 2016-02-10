//
//  UserMantraDataManager+CollapsedCardStackViewDataSource.swift
//  HIT
//
//  Created by Nathan Melehan on 2/8/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

extension UserMantraDataManager: CollapsedCardStackViewDataSource
{
    func numberOfItems() -> Int
    {
        return mantras.count
    }
    
    func cardViewForItem(item: Int) -> TestCardView
    {
        let cardView = TestCardView()
        let cardColor = UIColor.randomColor().colorWithAlphaComponent(1.0)
        cardView.backgroundView.backgroundColor = cardColor
        cardView.mantra = mantraWithId(item)
        return cardView
    }
    
    func commitDeletionForItem(item: Int)
    {
        
    }
}