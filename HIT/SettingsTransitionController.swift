//
//  SettingsTransitionController.swift
//  HIT
//
//  Created by Nathan Melehan on 2/29/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

enum SettingsTransitionControllerState: StateMachineDataSource
{
    case Uninitialized
    
    case WillPresent
    case StartPresentation(UIViewControllerContextTransitioning)
    case ContinuePresentation(CGFloat)
    case CancelPresentation
    case FinishPresentation
    
    case WillDismiss
    case StartDismissal(UIViewControllerContextTransitioning)
    case ContinueDismissal(CGFloat)
    case CancelDismissal
    case FinishDismissal
    
    
    func shouldTransitionFrom(
        from: SettingsTransitionControllerState,
        to: SettingsTransitionControllerState)
        
        -> Should<SettingsTransitionControllerState>
    {
        switch (from, to)
        {
        case (.Uninitialized, .WillPresent):
            // Determines transition's path at initialization
            return .Continue
            
        case (.WillPresent, .StartPresentation):
            // startInteractiveTransition() was called.
            return .Continue
            
        case (.StartPresentation, .ContinuePresentation(let newProgress)) where newProgress <= 0:
            // Sometimes the animation pauses at zero progress at the outset.
            // This condition prevents the animation from prematurely canceling.
            return .Abort
            
        case (.StartPresentation, .ContinuePresentation(let newProgress)) where newProgress >= 1:
            // Sometimes the user drags quickly enough to immediately 
            // finish the presentation.
            return .Redirect(.FinishPresentation)
            
        case (.StartPresentation, .ContinuePresentation):
            // Card is moving inside presentation interval.
            return .Continue
            
        case (.ContinuePresentation, .ContinuePresentation(let progress)) where progress <= 0:
            // Card has moved back to initial position for presentation.
            // The transition gets cancelled at this point.
            return .Redirect(.CancelPresentation)
            
        case (.ContinuePresentation, .ContinuePresentation(let progress)) where progress >= 1:
            // Card has moved to final position for presentation.
            // The transition gets finished at this point.
            return .Redirect(.FinishPresentation)
            
        case (.ContinuePresentation, .ContinuePresentation):
            // Card is moving inside presentation interval.
            return .Continue
            
        case (.ContinuePresentation, .CancelPresentation):
            return .Continue
            
        case (.ContinuePresentation, .FinishPresentation):
            return .Continue
            
            
        case (.Uninitialized, .WillDismiss):
            // Determines transition's path at initialization
            return .Continue
        case (.WillDismiss, .StartDismissal):
            return .Redirect(.ContinueDismissal(1))
        case (.StartDismissal, .ContinueDismissal):
            return .Redirect(.FinishDismissal)
        case (.ContinueDismissal, .ContinueDismissal(let progress)) where progress <= 0:
            return .Redirect(.CancelDismissal)
        case (.ContinueDismissal, .ContinueDismissal(let progress)) where progress >= 1:
            return .Redirect(.FinishDismissal)
        case (.ContinueDismissal, .ContinueDismissal):
            return .Continue
        case (.ContinueDismissal, .CancelDismissal):
            return .Continue
        case (.ContinueDismissal, .FinishDismissal):
            return .Continue
            
        default:
            return .Abort
        }
    }
}


class SettingsTransitionController: NSObject,
    UIViewControllerAnimatedTransitioning,
    UIViewControllerInteractiveTransitioning,
    StateMachineDelegate
{
    var transitionContext: UIViewControllerContextTransitioning?
    
    
    
    //
    // MARK: - State transition effects and causes
    
    typealias StateType = SettingsTransitionControllerState
    lazy var machine: StateMachine<SettingsTransitionController> = {
        return StateMachine(initialState: .Uninitialized, delegate: self)
    }()
    
    init(presenting: Bool) {
        super.init()
        machine.state = presenting ? .WillPresent : .WillDismiss
    }
    
    func didTransitionFrom(fromState: StateType, toState: StateType)
    {
        
        switch (fromState, toState)
        {
//        case (.Uninitialized, .WillPresent):
//            print(".Uninitialized, .WillPresent")
//            
//        case (.Uninitialized, .WillDismiss):
//            print(".Uninitialized, .WillDismiss")
            
            
        case (.WillPresent, .StartPresentation(let transitionContext)):
            print(".WillPresent, .StartPresentation")
            setupPresentation(transitionContext)
            
        case (.StartPresentation, .ContinuePresentation):
            print(".StartPresentation, .ContinuePresentation")
            updatePresentation()
            
        case (.ContinuePresentation, .ContinuePresentation):
            print(".ContinuePresentation, .ContinuePresentation")
            updatePresentation()
            
        case (.ContinuePresentation, .CancelPresentation):
            print(".ContinuePresentation, .CancelPresentation")
            cancelPresentation()
            
        case (.ContinuePresentation, .FinishPresentation):
            print(".ContinuePresentation, .FinishPresentation")
            finishPresentation()
            
            
        case (.WillDismiss, .StartDismissal(let transitionContext)):
            print(".WillDismiss, .StartDismissal")
            setupDismissal(transitionContext)
            
        case (.StartDismissal, .ContinueDismissal):
            print(".StartDismissal, .ContinueDismissal")
            updateDismissal()
            
        case (.ContinueDismissal, .ContinueDismissal):
            print(".ContinueDismissal, .ContinueDismissal")
            updateDismissal()
            
        case (.ContinueDismissal, .CancelDismissal):
            print(".ContinueDismissal, .CancelDismissal")
            cancelDismissal()
            
        case (.ContinueDismissal, .FinishDismissal):
            print(".ContinueDismissal, .FinishDismissal")
            finishDismissal()
            
            
        default:
            break
        }
    }
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        switch machine.state
        {
        case .WillPresent:
            machine.state = .StartPresentation(transitionContext)
        case .WillDismiss:
            machine.state = .StartDismissal(transitionContext)
        default:
            break
        }
    }
    
    var transitionProgress: CGFloat = 0 {
        didSet
        {
            switch machine.state
            {
            case .StartPresentation, .ContinuePresentation:
                machine.state = .ContinuePresentation(transitionProgress)
            case .StartDismissal, .ContinueDismissal:
                machine.state = .ContinueDismissal(transitionProgress)
            default:
                break
            }
        }
    }
    
    
    // MARK: - Managing presentation
    
    func setupPresentation(transitionContext: UIViewControllerContextTransitioning)
    {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            as! CollapsedCardStackViewController
        let ccsv = fromVC.collapsedCardStackView
        //        ccsv.removeFromSuperview()
        let ccsvFrame = ccsv.frame
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        containerView?.addSubview(toVC!.view)
        
        containerView!.addSubview(ccsv)
//        ccsv.translatesAutoresizingMaskIntoConstraints = true
//        ccsv.frame = ccsvFrame
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Left).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Right).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Top).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Bottom).active = true
        
        toVC?.view.alpha = transitionProgress
        toVC?.view.alpha = 0
    }
    
    func updatePresentation()
    {
        transitionContext!.updateInteractiveTransition(transitionProgress)
//        let toView = transitionContext!.viewForKey(UITransitionContextToViewKey)
//        toView!.alpha = transitionProgress
    }
    
    func finishPresentation()
    {
        ccsvFromContainerView()?.userInteractionEnabled = false
        
        
        let toView = transitionContext!.viewForKey(UITransitionContextToViewKey)
        toView!.alpha = transitionProgress
        
        transitionContext?.finishInteractiveTransition()
        transitionContext?.completeTransition(true)
    }
    
    func ccsvFromContainerView() -> CollapsedCardStackView?
    {
        let ccsv = transitionContext?.containerView()?.subviews
            .filter ({ return ($0 as? CollapsedCardStackView) != nil }).first
        return ccsv as? CollapsedCardStackView
    }
    
    func cancelPresentation()
    {
        // Add CollapsedCardStackView back to original VC
        if let ccsv = ccsvFromContainerView()
        {
            let fromView = transitionContext?
                .viewControllerForKey(UITransitionContextFromViewControllerKey)?
                .view
            fromView?.addSubview(ccsv)
            NSLayoutConstraint.pinItem(ccsv, toItem: fromView!, withAttribute: .Left).active = true
            NSLayoutConstraint.pinItem(ccsv, toItem: fromView!, withAttribute: .Right).active = true
            NSLayoutConstraint.pinItem(ccsv, toItem: fromView!, withAttribute: .Top).active = true
            NSLayoutConstraint.pinItem(ccsv, toItem: fromView!, withAttribute: .Bottom).active = true
        }
        
        transitionContext?.cancelInteractiveTransition()
        transitionContext?.completeTransition(false)
    }
    
    
    // MARK: - Managing dismissal
    
    func setupDismissal(transitionContext: UIViewControllerContextTransitioning)
    {
        self.transitionContext = transitionContext
        print("setupDismissal")
        ccsvFromContainerView()?.dismissSettings()
    }
    
    func updateDismissal()
    {
        transitionContext!.updateInteractiveTransition(transitionProgress)
//        let toView = transitionContext!.viewForKey(UITransitionContextToViewKey)
//        toView!.alpha = transitionProgress
    }
    
    func finishDismissal()
    {
        // Add CollapsedCardStackView back to original VC
        if let ccsv = ccsvFromContainerView()
        {
            ccsv.userInteractionEnabled = true
            
            let toView = transitionContext?
                .viewControllerForKey(UITransitionContextToViewControllerKey)?
                .view
            toView?.addSubview(ccsv)
            NSLayoutConstraint.pinItem(ccsv, toItem: toView!, withAttribute: .Left).active = true
            NSLayoutConstraint.pinItem(ccsv, toItem: toView!, withAttribute: .Right).active = true
            NSLayoutConstraint.pinItem(ccsv, toItem: toView!, withAttribute: .Top).active = true
            NSLayoutConstraint.pinItem(ccsv, toItem: toView!, withAttribute: .Bottom).active = true
        }
        
        transitionContext?.finishInteractiveTransition()
        transitionContext?.completeTransition(true)
    }
    
    func cancelDismissal()
    {
        transitionContext?.cancelInteractiveTransition()
        transitionContext?.completeTransition(false)
    }
    
    
    // MARK: - Required UIViewControllerAnimatorTransitioning protocol methods
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        // nothing here!
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)
        -> NSTimeInterval
    {
        return 0
    }
}
