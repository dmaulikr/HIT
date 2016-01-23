//
//  PulledCardDragTestViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 1/23/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

enum CardState: StateMachineDataSource
{
    case AnchoredAtRest
    case TrackingPan(UIPanGestureRecognizer)
    case ReturnToAnchor
    
    case HintingEdit(UIPanGestureRecognizer)
    case ConfirmEdit(UIPanGestureRecognizer)
    case ExecuteEdit
    
    case HintingDelete(UIPanGestureRecognizer)
    case ConfirmDelete(UIPanGestureRecognizer)
    case ExecuteDelete
    
    case HintingSettings(UIPanGestureRecognizer)
    case ConfirmSettings(UIPanGestureRecognizer)
    case ExecuteSettings
    
    case HintingShuffle(UIPanGestureRecognizer)
    case ConfirmShuffle(UIPanGestureRecognizer)
    case ExecuteShuffle
    
    func shouldTransitionFrom(from: CardState, to: CardState) -> Should<CardState>
    {
        switch (from, to)
        {
        case (.TrackingPan, .TrackingPan):
            return .Continue
        case (.TrackingPan, .ReturnToAnchor):
            return .Continue
        case (.ReturnToAnchor, .TrackingPan):
            return .Continue
            
        case (.TrackingPan, .HintingEdit):
            return .Continue
        case (.TrackingPan, .ConfirmEdit):
            return .Continue
        case (.HintingEdit, .ConfirmEdit):
            return .Continue
        case (.ConfirmEdit, .HintingEdit):
            return .Continue
        case (.HintingEdit, .TrackingPan):
            return .Continue
        case (.ConfirmEdit, .TrackingPan):
            return .Continue
        case (.HintingEdit, .ReturnToAnchor):
            return .Continue
            
        case (.TrackingPan, .HintingDelete):
            return .Continue
        case (.TrackingPan, .ConfirmDelete):
            return .Continue
        case (.HintingDelete, .ConfirmDelete):
            return .Continue
        case (.ConfirmDelete, .HintingDelete):
            return .Continue
        case (.HintingDelete, .TrackingPan):
            return .Continue
        case (.ConfirmDelete, .TrackingPan):
            return .Continue
            
        case (.TrackingPan, .HintingSettings):
            return .Continue
        case (.TrackingPan, .ConfirmSettings):
            return .Continue
        case (.HintingSettings, .ConfirmSettings):
            return .Continue
        case (.ConfirmSettings, .HintingSettings):
            return .Continue
        case (.HintingSettings, .TrackingPan):
            return .Continue
        case (.ConfirmSettings, .TrackingPan):
            return .Continue
            
        default:
            return .Abort
        }
    }
}

class PulledCardDragTestViewController: UIViewController, UIDynamicAnimatorDelegate, StateMachineDelegate
{
    
    
    
    //
    // MARK: - IBOutlets
    
    @IBOutlet weak var tlBoundary: StatePlaceholderView!
    @IBOutlet weak var blBoundary: StatePlaceholderView!
    @IBOutlet weak var brBoundary: StatePlaceholderView!
    @IBOutlet weak var trBoundary: StatePlaceholderView!
    
    @IBOutlet weak var cardView: CustomBoundsPlaceholderView!
    @IBOutlet weak var cardViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewXConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewYConstraint: NSLayoutConstraint!
    
    
    
    //
    // MARK: - Properties
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.view)
        animator.delegate = self
        animator.debugEnabled = true
        return animator
    }()
    
    var attachmentBehavior: UIAttachmentBehavior?
    
    var itemBehavior: UIDynamicItemBehavior!
    
    
    
    //
    // MARK: - State
    
    typealias StateType = CardState
    lazy var machine: StateMachine<PulledCardDragTestViewController> = {
        return StateMachine(initialState: .ReturnToAnchor, delegate: self)
    }()
    
    enum Axis {
        case Horizontal, Vertical
        
        init?(translation: CGPoint)
        {
            if abs(translation.x) == abs(translation.y) { return nil }
            
            self = abs(translation.y) > abs(translation.x)
                ? Axis.Vertical
                : Axis.Horizontal
        }
    }
    
    var attachmentAxis: Axis?
    
    
    
    //
    // MARK: - StateMachineDelegate
    
    func didTransitionFrom(from: StateType, to: StateType)
    {
        
        
        switch (from, to)
        {
            
        case (.ReturnToAnchor, .TrackingPan):
            let v = itemBehavior.linearVelocityForItem(cardView)
            print(v)
            itemBehavior.addLinearVelocity(CGPoint(x: -1*v.x, y: -1*v.y), forItem: cardView)
            print(v)
            
        default:
            break
            
        }
        
        
        switch to
        {
            
            
        case .TrackingPan(let panGR):
            
            let translation = panGR.translationInView(self.view)
            if attachmentAxis == nil
            {
                attachmentAxis = Axis(translation: translation)
                print(attachmentAxis)
                print(translation)
            }
            let anchor = attachmentBehavior!.anchorPoint
            let newAnchor = CGPoint(
                x: anchor.x + (attachmentAxis == .Horizontal ? translation.x : 0),
                y: anchor.y + (attachmentAxis == .Vertical ? translation.y : 0))
            attachmentBehavior?.anchorPoint = newAnchor
            attachmentBehavior?.damping = 1.0
            attachmentBehavior?.frequency = 7.0
            
            
        case .ReturnToAnchor:
            
            attachmentBehavior?.anchorPoint = CGPoint(
                x: view.bounds.width/2, y: view.bounds.height/2)
            attachmentBehavior?.damping = 1.0
            attachmentBehavior?.frequency = 2.0
            attachmentAxis = nil
            
            
        default:
            break
            
        }
    }
    
    
    
    //
    // MARK: - IBActions
    
    @IBAction func pannedInView(sender: UIPanGestureRecognizer)
    {
        if sender.state == .Began || sender.state == .Changed
        {
            machine.state = .TrackingPan(sender)
        }
        else {
            machine.state = .ReturnToAnchor
            print("\n")
        }
        
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    
    
    //
    // MARK: - UIViewController
    
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
            
            let laneCornerRadius: CGFloat = 20
            let boundaryCollisionBehavior = UICollisionBehavior(items: [cardView])
//            boundaryCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
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
            
            itemBehavior = UIDynamicItemBehavior(items: [cardView])
            itemBehavior.allowsRotation = false
            itemBehavior.friction = 0
            itemBehavior.resistance = 10.0
            itemBehavior.elasticity = 0
            animator.addBehavior(itemBehavior)
            
            attachmentBehavior = UIAttachmentBehavior(
                item: cardView,
                attachedToAnchor: cardView.center)
            attachmentBehavior?.length = 0
            animator.addBehavior(attachmentBehavior!)
        }
    }
}
