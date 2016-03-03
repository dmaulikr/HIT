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
    
    func cardViewForItem(item: Int) -> CardView
    
    func commitDeletionForItem(item: Int)
}

@objc protocol CollapsedCardStackViewDelegate
{
    func pulledCard() -> Int
    func rangeOfCardsInCollapsedStack() -> NSRange
    
    optional func shouldDeletePulledCard() -> Bool
    optional func shouldShowSettings() -> Bool
    optional func shouldShufflePulledCard() -> Bool
    optional func shouldEditPulledCard() -> Bool
    
    optional func didHintDelete()
    optional func didHintSettings()
    optional func didHintShuffle()
    optional func didHintEdit()
    
    optional func collapsedCardStackViewDidPromptSettingsView(ccsv: CollapsedCardStackView)
    
    optional func collapsedCardStackViewShouldPresentSettings(ccsv: CollapsedCardStackView) -> Bool
    optional func collapsedCardStackViewDidBeginSettingsPresentation(ccsv: CollapsedCardStackView, presentationProgress: CGFloat)
    optional func collapsedCardStackViewDidUpdateSettingsPresentation(ccsv: CollapsedCardStackView, presentationProgress: CGFloat)
    optional func collapsedCardStackViewDidDismissSettingsPresentation(ccsv: CollapsedCardStackView)
    
    optional func collapsedCardStackViewWillShuffle(ccsv: CollapsedCardStackView)
    optional func collapsedCardStackViewDidShuffle(ccsv: CollapsedCardStackView)
    optional func collapsedCardStackViewDidFailToShuffle(ccsv: CollapsedCardStackView)
}