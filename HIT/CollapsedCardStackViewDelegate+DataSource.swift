//
//  CardCollectionViewDataSource.swift
//  HIT
//
//  Created by Nathan Melehan on 2/8/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

@objc protocol CollapsedCardStackViewDataSource
{
    func numberOfItems() -> Int
    func pulledCard() -> Int
    func cardAtTopOfStack() -> Int
    func numberOfItemsToDisplayInStack() -> Int
    
    func cardViewForItem(item: Int) -> TestCardView
    
    func commitDeletionForItem(item: Int)
}

@objc protocol CollapsedCardStackViewDelegate
{
    optional func shouldDeletePulledCard() -> Bool
    optional func shouldShowSettings() -> Bool
    optional func shouldShufflePulledCard() -> Bool
    optional func shouldEditPulledCard() -> Bool
    
    optional func didHintDelete()
    optional func didHintSettings()
    optional func didHintShuffle()
    optional func didHintEdit()
}