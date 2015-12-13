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
    var panAttachmentBehavior: UIAttachmentBehavior?
    var snapBehavior: UISnapBehavior?
    var dynamicItemBehavior: UIDynamicItemBehavior?
    
    
    
    //
    //
    //
    //
    // MARK: - Methods
    
    func orientationChanged(notification: NSNotification) {
        // pause animator
        // add constraints back
        animator?.removeAllBehaviors()
        addConstraints()
        theView.transform = CGAffineTransformIdentity
    }
    
    func dropConstraints() {
        theView.translatesAutoresizingMaskIntoConstraints = true
        leftConstraint.active = false
        rightConstraint.active = false
        topConstraint.active = false
        bottomConstraint.active = false
    }
    
    func addConstraints() {
        theView.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint.active = true
        rightConstraint.active = true
        topConstraint.active = true
        bottomConstraint.active = true
    }
    
    
    //
    //
    //
    //
    // MARK: - Outlets
    
    @IBOutlet weak var theView: UIView!
    
    @IBOutlet var leftConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var rightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    
    
    //
    //
    //
    //
    // MARK: - Actions
    
    @IBAction func setNeedsLayoutButtonPressed() {
        self.view.setNeedsLayout()
    }
    
    @IBAction func dropConstraintsButtonPressed() {
        dropConstraints()
    }
    
    @IBAction func addConstraintsBackButtonPressed() {
        addConstraints()
    }
    
    @IBAction func handlePanGestureRecognizer(sender: UIPanGestureRecognizer) {
        // run animator
        // add attachment behavior
        // drop constraints
        
        let translation = sender.translationInView(self.view)
        if sender.state == .Began {
            dropConstraints()
            
            panAttachmentBehavior = UIAttachmentBehavior(item: theView,
                attachedToAnchor: theView.center)
            panAttachmentBehavior?.length = 0
            animator?.addBehavior(panAttachmentBehavior!)
            
            if dynamicItemBehavior == nil {
                dynamicItemBehavior = UIDynamicItemBehavior(items: [theView])
                dynamicItemBehavior?.allowsRotation = false
                animator?.addBehavior(dynamicItemBehavior!)
            }
            
            if snapBehavior == nil {
                snapBehavior = UISnapBehavior(item: theView, snapToPoint: theView.center)
                animator?.addBehavior(snapBehavior!)
            }
        }
        else if sender.state == .Changed {
            let anchor = panAttachmentBehavior!.anchorPoint
            let newAnchor = CGPoint(x: anchor.x + translation.x,
                y: anchor.y + translation.y)
            panAttachmentBehavior?.anchorPoint = newAnchor
        }
        else if sender.state == .Ended {
            animator?.removeBehavior(self.panAttachmentBehavior!)
            panAttachmentBehavior = nil
        }
        
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    
    
    //
    //
    //
    //
    // MARK: - UIDynamicAnimatorDelegate
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
        snapBehavior = nil
        dynamicItemBehavior = nil
        addConstraints()
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // update behaviors
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
