//
//  SettingsTransitionController.swift
//  HIT
//
//  Created by Nathan Melehan on 2/29/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class SettingsTransitionController: NSObject,
    UIViewControllerAnimatedTransitioning,
    UIViewControllerInteractiveTransitioning
{
    var transitionProgress: CGFloat = 0 {
        didSet {
            updateTransition()
        }
    }
    
    var transitionContext: UIViewControllerContextTransitioning?
    
    
    func updateTransition()
    {
        guard transitionContext != nil else { return }
        
        transitionContext?.updateInteractiveTransition(transitionProgress)
        let toView = transitionContext?.viewForKey(UITransitionContextToViewKey)
        toView?.alpha = transitionProgress
    }
    
    func finishTransition()
    {
        guard transitionContext != nil else { return }
        
        transitionContext?.updateInteractiveTransition(1.0)
        let toView = transitionContext?.viewForKey(UITransitionContextToViewKey)
        toView?.alpha = 1.0
        transitionContext?.finishInteractiveTransition()
        transitionContext?.completeTransition(true)
    }
    
    func cancelTransition()
    {
        guard transitionContext != nil else { return }
        
        transitionContext?.updateInteractiveTransition(0.0)
        let toView = transitionContext?.viewForKey(UITransitionContextToViewKey)
        toView?.alpha = 0.0
        transitionContext?.cancelInteractiveTransition()
        transitionContext?.completeTransition(false)
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)
        -> NSTimeInterval
    {
        return 0
    }
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        print("start interactive")
        
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            as! CollapsedCardStackViewController
        let ccsv = fromVC.collapsedCardStackView
        ccsv.removeFromSuperview()
        
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        containerView?.addSubview(toVC!.view)

        toVC!.view.addSubview(ccsv)
        NSLayoutConstraint.pinItem(ccsv, toItem: toVC!.view, withAttribute: .Left).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: toVC!.view, withAttribute: .Right).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: toVC!.view, withAttribute: .Top).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: toVC!.view, withAttribute: .Bottom).active = true
        
//        toVC?.view.alpha = 0.0
    }
}
