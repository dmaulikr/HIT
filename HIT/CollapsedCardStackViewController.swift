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
    
    // MARK: - View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        super.prepareForSegue(segue, sender: sender)
        
        switch segue.identifier ?? ""
        {
        case "Show Settings":
            let settingsVC = segue.destinationViewController
            settingsVC.transitioningDelegate = self
            
        default: break
        }
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
    
    // MARK: - CollapsedCardStackViewDelegate
    
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
    
//    func collapsedCardStackViewDidPromptSettingsView(ccsv: CollapsedCardStackView) {
//        performSegueWithIdentifier("Show Settings", sender: self)
//    }
    
    // MARK: - Settings transition
    
    var settingsTransitionController = SettingsTransitionController()
    
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController)
        
        -> UIViewControllerAnimatedTransitioning?
    {
        return settingsTransitionController
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning?
    {
        return settingsTransitionController
    }
    
    func collapsedCardStackViewDidBeginSettingsPresentation(
        ccsv: CollapsedCardStackView,
        presentationProgress: CGFloat)
    {
        print("delegate.didBegin: \(presentationProgress)")
        settingsTransitionController = SettingsTransitionController()
        settingsTransitionController.transitionProgress = presentationProgress
        performSegueWithIdentifier("Show Settings", sender: self)
    }
    
    func collapsedCardStackViewDidUpdateSettingsPresentation(
        ccsv: CollapsedCardStackView,
        presentationProgress: CGFloat)
    {
        print("delegate.didUpdate: \(presentationProgress)")
        if presentationProgress == 1
        {
            print("finish transition")
            settingsTransitionController.finishTransition()
        }
        else {
            settingsTransitionController.transitionProgress = presentationProgress
        }
    }
    
    func collapsedCardStackViewDidDismissSettingsPresentation(ccsv: CollapsedCardStackView)
    {
        print("delegate.didDismiss")
        settingsTransitionController.cancelTransition()
    }
}
