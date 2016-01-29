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
    
    case HintingCreate(UIPanGestureRecognizer)
    case InteractiveCreate
    case ExecuteCreate
    
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
        case (.HintingEdit, .HintingEdit):
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
            
        case (.ReturnToAnchor, .HintingCreate):
            return .Continue
        case (.HintingCreate, .InteractiveCreate):
            return .Continue
        case (.InteractiveCreate, .ExecuteCreate):
            return .Redirect(.ReturnToAnchor)
        case (.InteractiveCreate, .ReturnToAnchor):
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
    
    @IBOutlet weak var hintingEditIconView: HintingIconView!
    @IBOutlet var hintingEditIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconCenterYConstraint: NSLayoutConstraint!
    private var hintingEditIconViewAnchorLocation: CGPoint!
    var hintingEditIconViewTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    
    //
    // MARK: - Properties
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.view)
        animator.delegate = self
        animator.debugEnabled = true
        return animator
    }()
    
    var attachmentAnchorLocation: CGPoint!
    var attachmentBehavior: UIAttachmentBehavior?
    
    var itemBehavior: UIDynamicItemBehavior!
    
    
    
    //
    // MARK: - State
    
    typealias StateType = CardState
    lazy var machine: StateMachine<PulledCardDragTestViewController> = {
        return StateMachine(initialState: .ReturnToAnchor, delegate: self)
    }()
    
    enum Axis
    {
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
    
    func updateCardRestingAttachmentBehaviorWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self.view)
        let newAnchor = CGPoint(
            x: attachmentAnchorLocation.x + (attachmentAxis == .Horizontal ? translation.x : 0),
            y: attachmentAnchorLocation.y + (attachmentAxis == .Vertical ? translation.y : 0))
        attachmentBehavior?.anchorPoint = newAnchor
        attachmentBehavior?.damping = 1.0
        attachmentBehavior?.frequency = 14.0
    }
    
    func returnCardAttachmentBehaviorToRestingLocation() {
        attachmentBehavior?.anchorPoint = attachmentAnchorLocation
        attachmentBehavior?.damping = 1.0
        attachmentBehavior?.frequency = 7.0
        attachmentAxis = nil
    }
    
    func updateHintingEditIconViewPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        if hintingEditIconViewTrackingAttachmentBehavior == nil
        {
            hintingEditIconViewTrackingAttachmentBehavior
                = UIAttachmentBehavior(item: hintingEditIconView,
                    attachedToAnchor: hintingEditIconViewAnchorLocation)
            hintingEditIconViewTrackingAttachmentBehavior!.length = 0
            hintingEditIconViewTrackingAttachmentBehavior!.damping = 1.0
            hintingEditIconViewTrackingAttachmentBehavior!.frequency = 1.0
            animator.addBehavior(hintingEditIconViewTrackingAttachmentBehavior!)
        }
        
        let translation = panGR.translationInView(self.view)
        let newAnchor = CGPoint(
            x: hintingEditIconViewAnchorLocation.x + translation.x,
            y: hintingEditIconViewAnchorLocation.y)
        hintingEditIconViewTrackingAttachmentBehavior?.anchorPoint = newAnchor
    }
    
    func stopHintingEditIconViewTrackingAttachmentBehavior()
    {
        animator.removeBehavior(hintingEditIconViewTrackingAttachmentBehavior!)
        hintingEditIconViewTrackingAttachmentBehavior = nil
    }
    
    func didTransitionFrom(from: StateType, to: StateType)
    {
        
        switch (from, to)
        {
            
        case (.TrackingPan, .TrackingPan(let panGR)):
            if attachmentAxis == nil
            {
                let translation = panGR.translationInView(self.view)
                attachmentAxis = Axis(translation: translation)
                print(attachmentAxis)
                print(translation)
            }
            updateCardRestingAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.TrackingPan, .ReturnToAnchor):
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.ReturnToAnchor, .TrackingPan(let panGR)):
            if attachmentAxis == nil
            {
                let translation = panGR.translationInView(self.view)
                attachmentAxis = Axis(translation: translation)
                print(attachmentAxis)
                print(translation)
            }
            updateCardRestingAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.TrackingPan, .HintingEdit(let panGR)):
            print(".TrackingPan -> .HintingEdit")
            updateHintingEditIconViewPresentationWithPanGestureRecognizer(panGR)
            updateCardRestingAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .HintingEdit(let panGR)):
            print(".HintingEdit -> .HintingEdit")
            updateHintingEditIconViewPresentationWithPanGestureRecognizer(panGR)
            updateCardRestingAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .TrackingPan):
            print(".HintingEdit -> .TrackingPan")
            stopHintingEditIconViewTrackingAttachmentBehavior()
            
        case (.HintingEdit, .ReturnToAnchor):
            print(".HintingEdit -> .ReturnToAnchor")
            stopHintingEditIconViewTrackingAttachmentBehavior()
            returnCardAttachmentBehaviorToRestingLocation()
            
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
            if attachmentAxis == .Horizontal
                && sender.translationInView(view).x > 0
            {
                machine.state = .HintingEdit(sender)
            }
            else {
                print("set to tracking pan")
                machine.state = .TrackingPan(sender)
            }
        }
        else
        {
            machine.state = .ReturnToAnchor
            print("\n")
        }
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
    
    func setupCardBehaviors() {
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
        
        let laneCornerRadius: CGFloat = 5
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
        
        attachmentAnchorLocation = cardView.center
        
        attachmentBehavior = UIAttachmentBehavior(
            item: cardView,
            attachedToAnchor: attachmentAnchorLocation)
        attachmentBehavior?.length = 0
        animator.addBehavior(attachmentBehavior!)
    }
    
    func setupHintingEditIconBehaviors() {
        NSLayoutConstraint.deactivateConstraints(
            [hintingEditIconWidthConstraint, hintingEditIconHeightConstraint,
            hintingEditIconViewLeadingConstraint, hintingEditIconCenterYConstraint])
        hintingEditIconView.translatesAutoresizingMaskIntoConstraints = true
        
        let hintingEditIconViewAnchorAttachmentBehavior =
            UIAttachmentBehavior(item: hintingEditIconView,
                attachedToAnchor: hintingEditIconView.center)
        hintingEditIconViewAnchorAttachmentBehavior.length = 0
        hintingEditIconViewAnchorAttachmentBehavior.damping = 1.0
        hintingEditIconViewAnchorAttachmentBehavior.frequency = 2.0
        animator.addBehavior(hintingEditIconViewAnchorAttachmentBehavior)
        
        hintingEditIconViewAnchorLocation = hintingEditIconView.center
    }
    
    override func viewDidLayoutSubviews()
    {
        if animator.behaviors.count == 0
        {
            setupCardBehaviors()
            setupHintingEditIconBehaviors()
        }
    }
}
