//
//  AttachmentTestViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/25/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

class AttachmentTestViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    
    
    //
    //
    //
    //
    // MARK: - Properties
    
    var animator: UIDynamicAnimator?
    var attachmentBehavior: UIAttachmentBehavior?
    
    
    
    //
    //
    //
    //
    // MARK: - Outlets
    
    
    
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
        let attachedView = cells[0]
        if sender.state == .Began {
            let anchor = CGPoint(x: attachedView.center.x, y: attachedView.center.y + translation.y)
            attachmentBehavior = UIAttachmentBehavior(item: attachedView,
                attachedToAnchor: anchor)
//            attachmentBehavior = UIAttachmentBehavior.slidingAttachmentWithItem(
//                attachedView,
//                attachmentAnchor: anchor,
//                axisOfTranslation: CGVector(dx: 1, dy: 0))
            attachmentBehavior?.damping = 0
            attachmentBehavior?.frequency = 0
            attachmentBehavior?.length = 0
            animator?.addBehavior(attachmentBehavior!)
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
//        print("animator paused")
//        
//        if attachmentBehavior == nil {
//            print("and attachment is nil")
//            
//            animator.removeAllBehaviors()
//            addConstraints()
//        }
    }
    
    
    
    //
    //
    //
    //
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let springBehavior = UIAttachmentBehavior(
//            item: attachedView2,
//            attachedToAnchor: CGPoint(x: view.bounds.width/2, y: view.bounds.height - attachedView2.bounds.size.height))
//        animator?.addBehavior(springBehavior)
//        springBehavior.length = 0
//        springBehavior.damping = 1
//        springBehavior.frequency = 2.0
//        
//        let tetherBehavior = UIAttachmentBehavior(
//            item: attachedView,
//            attachedToItem: attachedView2)
//        animator?.addBehavior(tetherBehavior)
//        tetherBehavior.length = 150
//        tetherBehavior.damping = 1.0
//        tetherBehavior.frequency = 2.0
    }
    
    var cells = [StatePlaceholderView]()
    let cellHeight: CGFloat = 50
    
    func loadCells()
    {
        for i in 0..<7
        {
            let cellView = StatePlaceholderView()
            cellView.frame = CGRect(
                x: 50,
                y: view.bounds.height - CGFloat(i+1) * (cellHeight),
                width: view.bounds.width-100,
                height: cellHeight)
            cellView.backgroundColor = UIColor.randomColor()
            cellView.placeholderColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            self.view.addSubview(cellView)
            cells.append(cellView)
        }
        
        for i in 1..<7 {
            let cellBelow = cells[i-1]
            let cellAbove = cells[i]
            
            let attachmentLeft = UIAttachmentBehavior(
                item: cellBelow,
                offsetFromCenter: UIOffset(
                    horizontal: -1*cellBelow.bounds.width/2,
                    vertical: -1*cellBelow.bounds.height/2),
                attachedToItem: cellAbove,
                offsetFromCenter: UIOffset(
                    horizontal: -1*cellAbove.bounds.width/2,
                    vertical: cellAbove.bounds.height/2))
            attachmentLeft.length = 0
            attachmentLeft.damping = 1
            attachmentLeft.frequency = 5
            animator?.addBehavior(attachmentLeft)
            
            let attachmentRight = UIAttachmentBehavior(
                item: cellBelow,
                offsetFromCenter: UIOffset(
                    horizontal: cellBelow.bounds.width/2,
                    vertical: -1*cellBelow.bounds.height/2),
                attachedToItem: cellAbove,
                offsetFromCenter: UIOffset(
                    horizontal: cellAbove.bounds.width/2,
                    vertical: cellAbove.bounds.height/2))
            attachmentRight.length = 0
            attachmentRight.damping = 1
            attachmentRight.frequency = 5
            animator?.addBehavior(attachmentRight)
        }
        
        let collision = UICollisionBehavior(items: cells)
        collision.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collision)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        animator = UIDynamicAnimator(referenceView: self.view)
        animator?.delegate = self
        animator?.debugEnabled = true
        
        loadCells()
    }

}
