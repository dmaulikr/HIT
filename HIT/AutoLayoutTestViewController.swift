//
//  AutoLayoutTestViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/11/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

class AutoLayoutTestViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    
    
    //
    //
    //
    //
    // MARK: - Properties
    
    var animator: UIDynamicAnimator?
    var attachmentBehavior: UIAttachmentBehavior?
    var startStateSnapBehavior: UISnapBehavior?
    var endStateSnapBehavior: UISnapBehavior?
    var dynamicItemBehavior: UIDynamicItemBehavior?
    
    var currentEndStateView: UIView!
    var currentConstraintSet: [NSLayoutConstraint]!
    
    
    
    //
    //
    //
    //
    // MARK: - Methods
    
    func orientationChanged(notification: NSNotification) {
        // pause animator
        // add constraints back
        print("orientation changed")
        
        animator?.removeAllBehaviors()
        addConstraints()
        theView.transform = CGAffineTransformIdentity
    }
    
    func dropConstraints() {
        print("dropping constraints")
        NSLayoutConstraint.deactivateConstraints(
            currentConstraintSet)
        theView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func addConstraints() {
        print("added constraints")
        
        theView.translatesAutoresizingMaskIntoConstraints = false
        currentConstraintSet = theView.mirrorView(currentEndStateView, byReplacingConstraints: currentConstraintSet)
    }
    
    
    //
    //
    //
    //
    // MARK: - Outlets
    
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var startStateView: UIView!
    @IBOutlet weak var endStateView: UIView!
    
    @IBOutlet var startStateViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var startStateViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var startStateViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var startStateViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet var endStateViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var endStateViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var endStateViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var endStateViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet var theViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var theViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var theViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var theViewCenterYConstraint: NSLayoutConstraint!
    
  
    
    
    //
    //
    //
    //
    // MARK: - Actions
    
    @IBAction func handlePanGestureRecognizer(sender: UIPanGestureRecognizer) {
        // run animator
        // add attachment behavior
        // drop constraints
        
        let translation = sender.translationInView(self.view)
        if sender.state == .Began {
            print("\(NSDate()): \(sender.state.rawValue)\n")
            
            dropConstraints()
            animator?.removeAllBehaviors()
            
            attachmentBehavior = UIAttachmentBehavior(item: theView,
                attachedToAnchor: theView.center)
            
            attachmentBehavior?.length = 0
            animator?.addBehavior(attachmentBehavior!)
            
            animator?.addBehavior(dynamicItemBehavior!)
        }
        else if sender.state == .Changed {
            
//            print("\(NSDate()): \(sender.state.rawValue)\n")
            
            let anchor = attachmentBehavior!.anchorPoint
            let newAnchor = CGPoint(x: anchor.x,
                y: anchor.y + translation.y)
            attachmentBehavior?.anchorPoint = newAnchor
        }
        else {
            print("\(NSDate()): \(sender.state.rawValue)\n")
            
            if sender.velocityInView(self.view).y > 0 {
                animator?.addBehavior(startStateSnapBehavior!)
                animator?.removeBehavior(endStateSnapBehavior!)
                currentEndStateView = startStateView
            }
            else {
                animator?.addBehavior(endStateSnapBehavior!)
                animator?.removeBehavior(startStateSnapBehavior!)
                currentEndStateView = endStateView
            }
            
            animator?.removeBehavior(self.attachmentBehavior!)
            attachmentBehavior = nil
        }
        
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    
    
    //
    //
    //
    //
    // MARK: - UIDynamicAnimatorDelegate
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        // condition ensures that animation didn't pause
        // just because user hasn't moved their finger
        print("animator paused")
        
        if attachmentBehavior == nil {
            print("and attachment is nil")
            
            animator.removeAllBehaviors()
            addConstraints()
        }
    }
    
    
    
    //
    //
    //
    //
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "orientationChanged:",
            name: UIDeviceOrientationDidChangeNotification,
            object: UIDevice.currentDevice())
        
        animator = UIDynamicAnimator(referenceView: self.view)
        animator?.delegate = self
        
        dynamicItemBehavior = UIDynamicItemBehavior(items: [theView])
        dynamicItemBehavior?.allowsRotation = false
        
        currentConstraintSet = [theViewWidthConstraint, theViewHeightConstraint, theViewCenterXConstraint, theViewCenterYConstraint]
        currentEndStateView = startStateView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("laid out subviews")
        
        // update behaviors
        startStateSnapBehavior = UISnapBehavior(item: theView, snapToPoint: startStateView.center)
        startStateSnapBehavior?.damping = 0.5
        endStateSnapBehavior = UISnapBehavior(item: theView, snapToPoint: endStateView.center)
        endStateSnapBehavior?.damping = 0.1
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
