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
    case AtRest
    case TrackingPan(UIPanGestureRecognizer)
    case ReturningToRest
    
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
        case (.AtRest, .TrackingPan):
            return .Continue
        case (.ReturningToRest, .AtRest):
            return .Continue
            
        case (.TrackingPan, .TrackingPan):
            return .Continue
        case (.TrackingPan, .ReturningToRest):
            return .Continue
        case (.ReturningToRest, .TrackingPan):
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
        case (.HintingEdit, .ReturningToRest):
            return .Continue
            
            
        
        case (.TrackingPan,     .HintingSettings):  return .Continue
        case (.TrackingPan,     .ConfirmSettings):  return .Continue
        case (.HintingSettings, .HintingSettings):  return .Continue
        case (.HintingSettings, .ConfirmSettings):  return .Continue
        case (.ConfirmSettings, .ConfirmSettings):  return .Continue
        case (.ConfirmSettings, .HintingSettings):  return .Continue
        case (.HintingSettings, .ReturningToRest):  return .Continue
        case (.HintingSettings, .HintingDelete):    return .Continue
            
        case (.TrackingPan,     .HintingDelete):    return .Continue
        case (.TrackingPan,     .ConfirmDelete):    return .Continue
        case (.HintingDelete,   .HintingDelete):    return .Continue
        case (.HintingDelete,   .ConfirmDelete):    return .Continue
        case (.ConfirmDelete,   .ConfirmDelete):    return .Continue
        case (.ConfirmDelete,   .HintingDelete):    return .Continue
        case (.HintingDelete,   .ReturningToRest):  return .Continue
        case (.HintingDelete,   .HintingSettings):  return .Continue

        case (.ReturningToRest, .HintingCreate):    return .Continue
        case (.HintingCreate,   .InteractiveCreate): return .Continue
        case (.InteractiveCreate, .ExecuteCreate):
            return .Redirect(.ReturningToRest)
        case (.InteractiveCreate, .ReturningToRest):
            return .Continue
            
        default:
            return .Abort
        }
    }
}

class PulledCardDragTestViewController: UIViewController, UIDynamicAnimatorDelegate, StateMachineDelegate
{
    
    
    
    //
    // MARK: - Properties
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.view)
        animator.delegate = self
        //        animator.debugEnabled = true
        return animator
    }()
    
    
    // Guides for the collision boundaries which constrain card movement
    @IBOutlet weak var tlBoundary: StatePlaceholderView!
    @IBOutlet weak var blBoundary: StatePlaceholderView!
    @IBOutlet weak var brBoundary: StatePlaceholderView!
    @IBOutlet weak var trBoundary: StatePlaceholderView!
    
    
    // Card
    @IBOutlet weak var cardView: CustomBoundsPlaceholderView!
    @IBOutlet weak var cardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardCenterYConstraint: NSLayoutConstraint!
    
    var cardRestingAnchorLocation: CGPoint!
    var cardAttachmentBehavior: UIAttachmentBehavior!
    var cardDynamicItemBehavior: UIDynamicItemBehavior!
    
    
    // Hinting Settings Icon
    @IBOutlet weak var hintingSettingsIconView: HintingIconView!
    @IBOutlet var hintingSettingsIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingSettingsIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingSettingsIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var hintingSettingsIconCenterYConstraint: NSLayoutConstraint!
    
    private var hintingSettingsIconRestingAnchorLocation: CGPoint!
    var hintingSettingsIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingSettings
    @IBOutlet weak var hintingSettingsTrackingSpanView: StatePlaceholderView!
    var hintingSettingsSpanWidth: CGFloat {
        get {
            return hintingSettingsTrackingSpanView.frame.width
        }
    }
    
    
    // Hinting Delete Icon
    @IBOutlet weak var hintingDeleteIconView: HintingIconView!
    @IBOutlet var hintingDeleteIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingDeleteIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingDeleteIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var hintingDeleteIconCenterYConstraint: NSLayoutConstraint!
    
    private var hintingDeleteIconRestingAnchorLocation: CGPoint!
    var hintingDeleteIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingDelete
    @IBOutlet weak var hintingDeleteTrackingSpanView: StatePlaceholderView!
    var hintingDeleteSpanWidth: CGFloat {
        get {
            return hintingDeleteTrackingSpanView.frame.width
        }
    }
    
    
    //
    // MARK: - State
    
    typealias StateType = CardState
    lazy var machine: StateMachine<PulledCardDragTestViewController> = {
        return StateMachine(initialState: .ReturningToRest, delegate: self)
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
    
    func updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        if attachmentAxis == nil
        {
            let translation = panGR.translationInView(self.view)
            attachmentAxis = Axis(translation: translation)
            print(attachmentAxis)
            print(translation)
        }
        
        let translation = panGR.translationInView(self.view)
        let newAnchor = CGPoint(
            x: cardRestingAnchorLocation.x + (attachmentAxis == .Horizontal ? translation.x : 0),
            y: cardRestingAnchorLocation.y + (attachmentAxis == .Vertical ? translation.y : 0))
        cardAttachmentBehavior?.anchorPoint = newAnchor
        cardAttachmentBehavior?.damping = 1.0
        cardAttachmentBehavior?.frequency = 14.0
    }
    
    func returnCardAttachmentBehaviorToRestingLocation()
    {
        cardAttachmentBehavior?.anchorPoint = cardRestingAnchorLocation
        cardAttachmentBehavior?.damping = 1.0
        cardAttachmentBehavior?.frequency = 7.0
        attachmentAxis = nil
    }
    
    func updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self.view)
        
        let trackingDelay
            = hintingSettingsIconWidthConstraint.constant
            + hintingSettingsIconLeadingConstraint.constant * 2
        
        if translation.x > trackingDelay
        {
            hintingSettingsIconView.dialProgress
                = (translation.x - trackingDelay)
                / (hintingSettingsSpanWidth - trackingDelay)
            
            if hintingSettingsIconTrackingAttachmentBehavior == nil
            {
                hintingSettingsIconTrackingAttachmentBehavior
                    = UIAttachmentBehavior(item: hintingSettingsIconView,
                        attachedToAnchor: hintingSettingsIconRestingAnchorLocation)
                hintingSettingsIconTrackingAttachmentBehavior!.length = 0
                hintingSettingsIconTrackingAttachmentBehavior!.damping = 1.0
                hintingSettingsIconTrackingAttachmentBehavior!.frequency = 1.5
                animator.addBehavior(hintingSettingsIconTrackingAttachmentBehavior!)
            }
            
            let newAnchor = CGPoint(
                x: hintingSettingsIconRestingAnchorLocation.x + translation.x - trackingDelay,
                y: hintingSettingsIconRestingAnchorLocation.y)
            hintingSettingsIconTrackingAttachmentBehavior?.anchorPoint = newAnchor
        }
        else
        {
            hintingSettingsIconView.dialProgress = 0
        }
    }
    
    func returnHintingSettingsIconToRestingLocation()
    {
        hintingSettingsIconView.dialProgress = 0
        if hintingSettingsIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingSettingsIconTrackingAttachmentBehavior!)
            hintingSettingsIconTrackingAttachmentBehavior = nil
        }
    }
    
    func updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self.view)
        
        let trackingDelay
            = hintingDeleteIconWidthConstraint.constant
            + hintingDeleteIconTrailingConstraint.constant * 2
        
        if translation.x < -1*trackingDelay
        {
            hintingDeleteIconView.dialProgress
                = abs(translation.x + trackingDelay) / (hintingDeleteSpanWidth - trackingDelay)
            
            if hintingDeleteIconTrackingAttachmentBehavior == nil
            {
                hintingDeleteIconTrackingAttachmentBehavior
                    = UIAttachmentBehavior(item: hintingDeleteIconView,
                        attachedToAnchor: hintingDeleteIconRestingAnchorLocation)
                hintingDeleteIconTrackingAttachmentBehavior!.length = 0
                hintingDeleteIconTrackingAttachmentBehavior!.damping = 1.0
                hintingDeleteIconTrackingAttachmentBehavior!.frequency = 1.5
                animator.addBehavior(hintingDeleteIconTrackingAttachmentBehavior!)
            }
            
            let newAnchor = CGPoint(
                x: hintingDeleteIconRestingAnchorLocation.x + translation.x + trackingDelay,
                y: hintingDeleteIconRestingAnchorLocation.y)
            hintingDeleteIconTrackingAttachmentBehavior?.anchorPoint = newAnchor
        }
        else
        {
            hintingDeleteIconView.dialProgress = 0
        }
    }
    
    func returnHintingDeleteIconToRestingLocation()
    {
        hintingDeleteIconView.dialProgress = 0
        if hintingDeleteIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingDeleteIconTrackingAttachmentBehavior!)
            hintingDeleteIconTrackingAttachmentBehavior = nil
        }
    }
    
    func didTransitionFrom(from: StateType, to: StateType)
    {
        
        switch (from, to)
        {
            
        case (.TrackingPan, .TrackingPan(let panGR)):
            print(".TrackingPan -> .TrackingPan")
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.TrackingPan, .ReturningToRest):
            print(".TrackingPan -> .HintingDelete")
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.ReturningToRest, .TrackingPan(let panGR)):
            print(".ReturningToRest -> .TrackingPan")
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
            
        // .HintingSettings cases
            
        case (.TrackingPan, .HintingSettings(let panGR)):
            print(".TrackingPan -> .HintingSettings")
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingSettings, .HintingSettings(let panGR)):
            print(".HintingSettings -> .HintingSettings")
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingSettings, .TrackingPan):
            print(".HintingSettings -> .TrackingPan")
            returnHintingSettingsIconToRestingLocation()
            
        case (.HintingSettings, .ReturningToRest):
            print(".HintingSettings -> .ReturningToRest")
            returnHintingSettingsIconToRestingLocation()
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.HintingSettings, .HintingDelete(let panGR)):
            print(".HintingSettings -> .HintingDelete")
            returnHintingSettingsIconToRestingLocation()
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        // .HintingDelete cases
            
        case (.TrackingPan, .HintingDelete(let panGR)):
            print(".TrackingPan -> .HintingDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete, .HintingDelete(let panGR)):
            print(".HintingDelete -> .HintingDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete, .TrackingPan):
            print(".HintingDelete -> .TrackingPan")
            returnHintingDeleteIconToRestingLocation()
            
        case (.HintingDelete, .ReturningToRest):
            print(".HintingDelete -> .ReturningToRest")
            returnHintingDeleteIconToRestingLocation()
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
            {
                if sender.translationInView(view).x >= 0 {
                    machine.state = .HintingSettings(sender)
                }
                else if sender.translationInView(view).x < 0 {
                    machine.state = .HintingDelete(sender)
                }
            }
            else {
                print("set to tracking pan")
                machine.state = .TrackingPan(sender)
            }
        }
        else
        {
            machine.state = .ReturningToRest
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
    
    func setupCardBehaviors()
    {
        NSLayoutConstraint.deactivateConstraints(
            [cardHeightConstraint, cardWidthConstraint,
                cardCenterXConstraint, cardCenterYConstraint])
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
        
        cardDynamicItemBehavior = UIDynamicItemBehavior(items: [cardView])
        cardDynamicItemBehavior.allowsRotation = false
        cardDynamicItemBehavior.friction = 0
        cardDynamicItemBehavior.resistance = 10.0
        cardDynamicItemBehavior.elasticity = 0
        animator.addBehavior(cardDynamicItemBehavior)
        
        cardRestingAnchorLocation = cardView.center
        
        cardAttachmentBehavior = UIAttachmentBehavior(
            item: cardView,
            attachedToAnchor: cardRestingAnchorLocation)
        cardAttachmentBehavior?.length = 0
        animator.addBehavior(cardAttachmentBehavior!)
    }
    
    func setupHintingSettingsIconBehaviors()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingSettingsIconWidthConstraint, hintingSettingsIconHeightConstraint,
                hintingSettingsIconLeadingConstraint, hintingSettingsIconCenterYConstraint])
        hintingSettingsIconView.translatesAutoresizingMaskIntoConstraints = true
        
        let hintingSettingsIconRestingAttachmentBehavior =
        UIAttachmentBehavior(item: hintingSettingsIconView,
            attachedToAnchor: hintingSettingsIconView.center)
        hintingSettingsIconRestingAttachmentBehavior.length = 0
        hintingSettingsIconRestingAttachmentBehavior.damping = 1.0
        hintingSettingsIconRestingAttachmentBehavior.frequency = 2.0
        animator.addBehavior(hintingSettingsIconRestingAttachmentBehavior)
        
        hintingSettingsIconRestingAnchorLocation = hintingSettingsIconView.center
    }
    
    func setupHintingDeleteIconBehaviors()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingDeleteIconWidthConstraint, hintingDeleteIconHeightConstraint,
            hintingDeleteIconTrailingConstraint, hintingDeleteIconCenterYConstraint])
        hintingDeleteIconView.translatesAutoresizingMaskIntoConstraints = true
        
        let hintingDeleteIconRestingAttachmentBehavior =
            UIAttachmentBehavior(item: hintingDeleteIconView,
                attachedToAnchor: hintingDeleteIconView.center)
        hintingDeleteIconRestingAttachmentBehavior.length = 0
        hintingDeleteIconRestingAttachmentBehavior.damping = 1.0
        hintingDeleteIconRestingAttachmentBehavior.frequency = 2.0
        animator.addBehavior(hintingDeleteIconRestingAttachmentBehavior)
        
        hintingDeleteIconRestingAnchorLocation = hintingDeleteIconView.center
    }
    
    override func viewDidLayoutSubviews()
    {
        if animator.behaviors.count == 0
        {
            setupCardBehaviors()
            setupHintingSettingsIconBehaviors()
            setupHintingDeleteIconBehaviors()
        }
    }
}
