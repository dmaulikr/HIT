//
//  PulledCardDragTestViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 1/23/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit
import CoreMotion

class PulledCardDragTestViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    // Outlets
    
    @IBOutlet weak var tlBoundary: StatePlaceholderView!
    @IBOutlet weak var blBoundary: StatePlaceholderView!
    @IBOutlet weak var brBoundary: StatePlaceholderView!
    @IBOutlet weak var trBoundary: StatePlaceholderView!
    
    @IBOutlet weak var cardView: CustomBoundsPlaceholderView!
    @IBOutlet weak var cardViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewXConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewYConstraint: NSLayoutConstraint!
    
    
    // Properties
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.view)
        animator.delegate = self
        return animator
    }()
    
    var motionManager: CMMotionManager?
    
    var attachmentBehavior: UIAttachmentBehavior?
    
    // Actions
    
    @IBAction func pannedInView(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(self.view)
        if sender.state == .Began || sender.state == .Changed
        {
//            let anchor = attachmentBehavior!.anchorPoint
//            let newAnchor = CGPoint(x: locatio,
//                y: anchor.y + translation.y)
            attachmentBehavior?.anchorPoint = location
        }
        else {
            attachmentBehavior?.anchorPoint = CGPoint(
                x: view.bounds.width/2, y: view.bounds.height/2)
        }
        
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    
    
    // UIViewController
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews()
    {
        if animator.behaviors.count == 0
        {
            print("did layout subviews")
            
            NSLayoutConstraint.deactivateConstraints(
                [cardViewHeightConstraint, cardViewWidthConstraint,
                    cardViewXConstraint, cardViewYConstraint])
            cardView.translatesAutoresizingMaskIntoConstraints = true
            
            let pathDiameter = 16
            let rectContainingBoundaryPath = CGRect(
                x: -1*pathDiameter/2,
                y: -1*pathDiameter/2,
                width: pathDiameter,
                height: pathDiameter)
            let customBoundaryPath = UIBezierPath(
                ovalInRect: rectContainingBoundaryPath)
            cardView.collisionBoundsType = .Path
            cardView.collisionBoundingPath = customBoundaryPath
            
            let boundaryShapeLayer = CAShapeLayer()
            boundaryShapeLayer.path = customBoundaryPath.CGPath
            boundaryShapeLayer.fillColor = UIColor.blueColor().CGColor
            boundaryShapeLayer.strokeColor = UIColor.orangeColor().CGColor
            boundaryShapeLayer.frame = CGRect(
                origin: CGPoint(
                    x: cardView.bounds.width/2,
                    y: cardView.bounds.height/2),
                size: rectContainingBoundaryPath.size)
            cardView.layer.addSublayer(boundaryShapeLayer)
            
            let boundaryCollisionBehavior = UICollisionBehavior(items: [cardView])
            boundaryCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
            boundaryCollisionBehavior.addBoundaryWithIdentifier("topleft",
                forPath: UIBezierPath(rect: tlBoundary.frame))
            boundaryCollisionBehavior.addBoundaryWithIdentifier("bottomleft",
                forPath: UIBezierPath(rect: blBoundary.frame))
            boundaryCollisionBehavior.addBoundaryWithIdentifier("bottomright",
                forPath: UIBezierPath(rect: brBoundary.frame))
            boundaryCollisionBehavior.addBoundaryWithIdentifier("topright",
                forPath: UIBezierPath(rect: trBoundary.frame))
            animator.addBehavior(boundaryCollisionBehavior)
            
            let itemBehavior = UIDynamicItemBehavior(items: [cardView])
            itemBehavior.allowsRotation = false
            itemBehavior.friction = 0
            itemBehavior.resistance = 10.0
            animator.addBehavior(itemBehavior)
            
            attachmentBehavior = UIAttachmentBehavior(
                item: cardView,
                attachedToAnchor: cardView.center)
            attachmentBehavior?.length = 0
            attachmentBehavior?.damping = 1.0
            attachmentBehavior?.frequency = 2.0
            animator.addBehavior(attachmentBehavior!)
            
            animator.debugEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
