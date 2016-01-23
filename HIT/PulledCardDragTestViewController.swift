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
//        animator.debugEnabled = true
        return animator
    }()
    
    var motionManager: CMMotionManager?
    
    var attachmentBehavior: UIAttachmentBehavior?
    
    // Actions
    
    @IBAction func pannedInView(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        if sender.state == .Began || sender.state == .Changed
        {
            let anchor = attachmentBehavior!.anchorPoint
            let newAnchor = CGPoint(x: anchor.x + translation.x,
                y: anchor.y + translation.y)
            attachmentBehavior?.anchorPoint = newAnchor
            attachmentBehavior?.damping = 1.0
            attachmentBehavior?.frequency = 3.0
        }
        else {
            attachmentBehavior?.anchorPoint = CGPoint(
                x: view.bounds.width/2, y: view.bounds.height/2)
            attachmentBehavior?.damping = 1.0
            attachmentBehavior?.frequency = 2.0
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
        
        cardView.layer.cornerRadius = 3
        cardView.clipsToBounds = true
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
            
            let pathDiameter = 18
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
            
            let laneCornerRadius: CGFloat = 10
            let boundaryCollisionBehavior = UICollisionBehavior(items: [cardView])
            boundaryCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
            boundaryCollisionBehavior.addBoundaryWithIdentifier("topleft",
                forPath: UIBezierPath(
                    roundedRect: tlBoundary.frame,
                    cornerRadius: laneCornerRadius))
            boundaryCollisionBehavior.addBoundaryWithIdentifier("bottomleft",
                forPath: UIBezierPath(
                    roundedRect: blBoundary.frame,
                    cornerRadius: laneCornerRadius))
            boundaryCollisionBehavior.addBoundaryWithIdentifier("bottomright",
                forPath: UIBezierPath(
                    roundedRect: brBoundary.frame,
                    cornerRadius: laneCornerRadius))
            boundaryCollisionBehavior.addBoundaryWithIdentifier("topright",
                forPath: UIBezierPath(
                    roundedRect: trBoundary.frame,
                    cornerRadius: laneCornerRadius))
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
            animator.addBehavior(attachmentBehavior!)
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
