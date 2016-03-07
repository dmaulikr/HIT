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
            return .Continue
        case (.Uninitialized, .WillDismiss):
            return .Continue
            
        case (.WillPresent, .StartPresentation):
            return .Continue
        case (.StartPresentation, .ContinuePresentation):
            return .Continue
        case (.ContinuePresentation, .ContinuePresentation(let progress)) where progress <= 0:
            return .Redirect(.CancelPresentation)
        case (.ContinuePresentation, .ContinuePresentation(let progress)) where progress >= 1:
            return .Redirect(.FinishPresentation)
        case (.ContinuePresentation, .ContinuePresentation):
            return .Continue
        case (.ContinuePresentation, .CancelPresentation):
            return .Continue
        case (.ContinuePresentation, .FinishPresentation):
            return .Continue
            
        case (.WillDismiss, .StartDismissal):
            return .Continue
        case (.StartDismissal, .ContinueDismissal):
            return .Continue
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
            
            
        case (.WillDismiss, .StartDismissal):
            print(".WillDismiss, .StartDismissal")
            
        case (.StartDismissal, .ContinueDismissal):
            print(".StartDismissal, .ContinueDismissal")
            
        case (.ContinueDismissal, .ContinueDismissal):
            print(".ContinueDismissal, .ContinueDismissal")
            
        case (.ContinueDismissal, .CancelDismissal):
            print(".ContinueDismissal, .CancelDismissal")
            
        case (.ContinueDismissal, .FinishDismissal):
            print(".ContinueDismissal, .FinishDismissal")
            
            
        default:
            break
        }
    }
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        machine.state = .StartPresentation(transitionContext)
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
    
    
    // MARK: - Updating presentation
    
    func setupPresentation(transitionContext: UIViewControllerContextTransitioning)
    {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            as! CollapsedCardStackViewController
        let ccsv = fromVC.collapsedCardStackView
        //        ccsv.removeFromSuperview()
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        containerView?.addSubview(toVC!.view)
        
        containerView!.addSubview(ccsv)
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Left).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Right).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Top).active = true
        NSLayoutConstraint.pinItem(ccsv, toItem: containerView!, withAttribute: .Bottom).active = true
        
        toVC?.view.alpha = transitionProgress
    }
    
    func updatePresentation()
    {
        transitionContext!.updateInteractiveTransition(transitionProgress)
        let toView = transitionContext!.viewForKey(UITransitionContextToViewKey)
        toView!.alpha = transitionProgress
    }
    
    func finishPresentation()
    {
        ccsvFromContainerView()?.userInteractionEnabled = false
        
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
