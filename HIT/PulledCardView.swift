//
//  PulledCardView.swift
//  HIT
//
//  Created by Nathan Melehan on 2/2/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

enum PulledCardViewState: StateMachineDataSource
{
    case WaitingForData
    case ReloadData
    case LayoutViews
    
    case AtRest
    case TrackingPan(UIPanGestureRecognizer)
    case ReturningToRest
    
    case HintingEdit(UIPanGestureRecognizer)
    case ConfirmEdit(UIPanGestureRecognizer)
    
    case HintingDelete(UIPanGestureRecognizer)
    case ConfirmDelete(UIPanGestureRecognizer)
    
    case HintingSettings(UIPanGestureRecognizer)
    case ConfirmSettings(UIPanGestureRecognizer)
    
    case HintingShuffle(UIPanGestureRecognizer)
    case ConfirmShuffle(UIPanGestureRecognizer)
    
    
    func shouldTransitionFrom(from: PulledCardViewState, to: PulledCardViewState) -> Should<PulledCardViewState>
    {
        switch (from, to)
        {
        case (.WaitingForData, .ReloadData):    return .Redirect(.AtRest)
        case (_, .ReloadData):                  return .Redirect(.AtRest)
//        case (.ReloadData, .LayoutViews):       return .Redirect(.AtRest)
//        case (.LayoutViews, .AtRest):           return .Continue
        case (.ReloadData, .AtRest):            return .Continue
            
//        case (.AtRest, .LayoutViews):           return .Redirect(.AtRest)
//        case (.AtRest, .ReloadData):            return .Redirect(.AtRest)
            
        case (.AtRest, .TrackingPan):           return .Continue
        case (.ReturningToRest, .AtRest):       return .Continue
            
        case (.TrackingPan, .TrackingPan):      return .Continue
        case (.TrackingPan, .ReturningToRest):  return .Continue
        case (.ReturningToRest, .TrackingPan):  return .Continue
            
            
            
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
            
        case (.TrackingPan,     .HintingShuffle):    return .Continue
        case (.TrackingPan,     .ConfirmShuffle):    return .Continue
        case (.HintingShuffle,  .HintingShuffle):    return .Continue
        case (.HintingShuffle,  .ConfirmShuffle):    return .Continue
        case (.ConfirmShuffle,  .ConfirmShuffle):    return .Continue
        case (.ConfirmShuffle,  .HintingShuffle):    return .Continue
        case (.HintingShuffle,  .ReturningToRest):  return .Continue
        case (.HintingShuffle,  .HintingEdit):      return .Continue
            
        case (.TrackingPan,     .HintingEdit):      return .Continue
        case (.TrackingPan,     .ConfirmEdit):      return .Continue
        case (.HintingEdit,     .HintingEdit):      return .Continue
        case (.HintingEdit,     .ConfirmEdit):      return .Continue
        case (.ConfirmEdit,     .ConfirmEdit):      return .Continue
        case (.ConfirmEdit,     .HintingEdit):      return .Continue
        case (.HintingEdit,     .ReturningToRest):  return .Continue
        case (.HintingEdit,     .HintingShuffle):   return .Continue
            
        default:
            return .Abort
        }
    }
}

@objc protocol PulledCardViewDelegate {
    func pulledCard() -> CardView?
    func cardsDisplayedInStack() -> [CardView]
}

@IBDesignable class PulledCardView: XibDesignedView, StateMachineDelegate, UIDynamicAnimatorDelegate
{

    @IBOutlet var delegate: PulledCardViewDelegate? {
        didSet {
            reloadData()
        }
    }
    
    
    // MARK: - Properties
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        //        animator.debugEnabled = true
        return animator
    }()
    
    var panGR: UIPanGestureRecognizer?
    
    @IBOutlet weak var attachmentGuidelinesView: UIView!
    
    
    // Pulled Card Placeholder
    @IBOutlet weak var pulledCardPlaceholderView: CustomBoundsPlaceholderView!
    var pulledCardRestingAnchorLocation: CGPoint!
    var pulledCardAttachmentBehavior: UIAttachmentBehavior!
    var pulledCardDynamicItemBehavior: UIDynamicItemBehavior!
    var boundaryCollisionBehavior: UICollisionBehavior!
    
    
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
    
    
    // Hinting Shuffle Icon
    @IBOutlet weak var hintingShuffleIconView: HintingIconView!
    @IBOutlet var hintingShuffleIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingShuffleIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingShuffleIconCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var hintingShuffleIconTopConstraint: NSLayoutConstraint!
    
    private var hintingShuffleIconRestingAnchorLocation: CGPoint!
    var hintingShuffleIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingShuffle
    @IBOutlet weak var hintingShuffleTrackingSpanView: StatePlaceholderView!
    var hintingShuffleSpanHeight: CGFloat {
        get {
            return hintingShuffleTrackingSpanView.frame.height
        }
    }
    
    
    // Hinting Edit Icon
    @IBOutlet weak var hintingEditIconView: HintingIconView!
    @IBOutlet var hintingEditIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconBottomConstraint: NSLayoutConstraint!
    
    private var hintingEditIconRestingAnchorLocation: CGPoint!
    var hintingEditIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingEdit
    @IBOutlet weak var hintingEditTrackingSpanView: StatePlaceholderView!
    var hintingEditSpanHeight: CGFloat {
        get {
            return hintingEditTrackingSpanView.frame.height
        }
    }
    
    
    // Retracted Card Stack Placeholder View
    @IBOutlet weak var retractedCardStackPlaceholderView: StatePlaceholderView!


    //
    // MARK: - State
    
    typealias StateType = PulledCardViewState
    lazy var machine: StateMachine<PulledCardView> = {
        return StateMachine(initialState: .WaitingForData, delegate: self)
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
    
    var pulledCardView: CardView?
    var cardsInStack = [CardView]()
    
    func didTransitionFrom(fromState: StateType, toState: StateType)
    {
        
        switch (fromState, toState)
        {
        case (.WaitingForData, .ReloadData):
            print(".WaitingForData -> .ReloadData")
            panGR = UIPanGestureRecognizer(target: self, action: "pannedInView:")
            self.addGestureRecognizer(panGR!)
            loadData()
            
        case (_, .ReloadData):
            print("_ (\(fromState)) -> .ReloadData")
            loadData()
            
//        case (.ReloadData, .LayoutViews):
//            print(".ReloadData -> .LayoutViews")
//            layoutCards()
            
        case (.ReloadData, .AtRest):
            print(".ReloadData -> .AtRest")
            atRest()
            
//        case (.AtRest, .LayoutViews):
//            print(".AtRest -> .LayoutViews")
//            layoutCards()
            
        case (.AtRest, .TrackingPan(let panGR)):
            print(".AtRest -> .TrackingPan")
            buildPulledCardBehaviors()
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.TrackingPan, .TrackingPan(let panGR)):
            print(".TrackingPan -> .TrackingPan")
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.TrackingPan, .ReturningToRest):
            print(".TrackingPan -> .ReturningToRest")
            returnPulledCardPresentationToRestingState()
            
        case (.ReturningToRest, .TrackingPan(let panGR)):
            print(".ReturningToRest -> .TrackingPan")
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ReturningToRest, .AtRest):
            print(".ReturningToRest -> .AtRest")
            atRest()
            
            
            // .HintingSettings cases
            
        case (.TrackingPan, .HintingSettings(let panGR)):
            print(".TrackingPan -> .HintingSettings")
            displayHintingIconViewForState(toState)
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingSettings, .HintingSettings(let panGR)):
            print(".HintingSettings -> .HintingSettings")
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingSettings, .ReturningToRest):
            print(".HintingSettings -> .ReturningToRest")
            returnHintingSettingsIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            
        case (.HintingSettings, .HintingDelete(let panGR)):
            print(".HintingSettings -> .HintingDelete")
            returnHintingSettingsIconPresentationToRestingState()
            displayHintingIconViewForState(toState)
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
            // .HintingDelete cases
            
        case (.TrackingPan, .HintingDelete(let panGR)):
            print(".TrackingPan -> .HintingDelete")
            displayHintingIconViewForState(toState)
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete, .HintingDelete(let panGR)):
            print(".HintingDelete -> .HintingDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete, .ReturningToRest):
            print(".HintingDelete -> .ReturningToRest")
            returnHintingDeleteIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            
        case (.HintingDelete, .HintingSettings(let panGR)):
            print(".HintingSettings -> .HintingDelete")
            returnHintingDeleteIconPresentationToRestingState()
            displayHintingIconViewForState(toState)
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
            // .HintingShuffle cases
            
        case (.TrackingPan, .HintingShuffle(let panGR)):
            print(".TrackingPan -> .HintingShuffle")
            displayHintingIconViewForState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingShuffle, .HintingShuffle(let panGR)):
            print(".HintingShuffle -> .HintingShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingShuffle, .ReturningToRest):
            print(".HintingShuffle -> .ReturningToRest")
            returnHintingShuffleIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            
        case (.HintingShuffle, .HintingEdit(let panGR)):
            print(".HintingSettings -> .HintingShuffle")
            returnHintingShuffleIconPresentationToRestingState()
            displayHintingIconViewForState(toState)
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
            // .HintingEdit cases
            
        case (.TrackingPan, .HintingEdit(let panGR)):
            print(".TrackingPan -> .HintingEdit")
            displayHintingIconViewForState(toState)
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .HintingEdit(let panGR)):
            print(".HintingEdit -> .HintingEdit")
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .ReturningToRest):
            print(".HintingEdit -> .ReturningToRest")
            returnHintingEditIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            
        case (.HintingEdit, .HintingShuffle(let panGR)):
            print(".HintingSettings -> .HintingShuffle")
            returnHintingEditIconPresentationToRestingState()
            displayHintingIconViewForState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
        default:
            break
            
        }
    }
    
    func pannedInView(sender: UIPanGestureRecognizer)
    {
        if sender.state == .Began || sender.state == .Changed
        {
            if attachmentAxis == .Horizontal
            {
                if sender.translationInView(self).x >= 0 {
                    machine.state = .HintingSettings(sender)
                }
                else if sender.translationInView(self).x < 0 {
                    machine.state = .HintingDelete(sender)
                }
            }
            else if attachmentAxis == .Vertical {
                if sender.translationInView(self).y >= 0 {
                    machine.state = .HintingShuffle(sender)
                }
                else if sender.translationInView(self).y < 0 {
                    machine.state = .HintingEdit(sender)
                }
            }
            else {
                machine.state = .TrackingPan(sender)
            }
        }
        else
        {
            machine.state = .ReturningToRest
            print("\n")
        }
    }
    
    private func loadData()
    {
        // remove cached views
        // add new views from delegate
        // set behaviors
        
        pulledCardView = delegate?.pulledCard()
        if let pulledCardView = pulledCardView {
            addSubview(pulledCardView)
        }
        
        cardsInStack = delegate?.cardsDisplayedInStack() ?? []
        for card in cardsInStack
        {
            addSubview(card)
        }
    }
    
    func reloadData()
    {
        machine.state = .ReloadData
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        machine.state = .AtRest
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        print("update constraints")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layout subviews")
        print("xibView.bounds = \(self.xibView.bounds)")
    }
    
    //
    //
    //
    //
    //
    //
    
    var pulledCardViewConstraints: [NSLayoutConstraint]?
    
    func atRest()
    {
        print("atRest()")
        teardownPulledCardBehaviors()
        teardownHintingSettingsIconBehaviors()
        teardownHintingDeleteIconBehaviors()
        teardownHintingShuffleIconBehaviors()
        teardownHintingEditIconBehaviors()
    }
    
    func buildPulledCardBehaviors()
    {
        guard let pulledCardView = pulledCardView else { return }
        
        pulledCardView.translatesAutoresizingMaskIntoConstraints = true
        NSLayoutConstraint.deactivateConstraints(pulledCardViewConstraints!)
        pulledCardView.frame = pulledCardPlaceholderView.frame
        
        let pathDiameter = 18
        let rectContainingBoundaryPath = CGRect(
            x: -1*pathDiameter/2,
            y: -1*pathDiameter/2,
            width: pathDiameter,
            height: pathDiameter)
        let customBoundaryPath = UIBezierPath(
            ovalInRect: rectContainingBoundaryPath)
        pulledCardView.collisionBoundsType = .Path
        pulledCardView.collisionBoundingPath = customBoundaryPath
        
        let laneCornerRadius: CGFloat = 5
        boundaryCollisionBehavior = UICollisionBehavior(items: [pulledCardView])
        for (index, boundaryCollisionView) in attachmentGuidelinesView.subviews.enumerate()
        {
            boundaryCollisionBehavior.addBoundaryWithIdentifier("guideline \(index)",
                forPath: UIBezierPath(
                    roundedRect: boundaryCollisionView.frame,
                    cornerRadius: laneCornerRadius))
        }
        animator.addBehavior(boundaryCollisionBehavior)
        
        pulledCardDynamicItemBehavior = UIDynamicItemBehavior(items: [pulledCardView])
        pulledCardDynamicItemBehavior.allowsRotation = false
        pulledCardDynamicItemBehavior.friction = 0
        pulledCardDynamicItemBehavior.resistance = 10.0
        pulledCardDynamicItemBehavior.elasticity = 0
        animator.addBehavior(pulledCardDynamicItemBehavior)
        
        pulledCardRestingAnchorLocation = pulledCardPlaceholderView.center
        
        pulledCardAttachmentBehavior = UIAttachmentBehavior(
            item: pulledCardView,
            attachedToAnchor: pulledCardRestingAnchorLocation)
        pulledCardAttachmentBehavior?.length = 0
        animator.addBehavior(pulledCardAttachmentBehavior!)
    }
    
    func updatePulledCardPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        if attachmentAxis == nil
        {
            let translation = panGR.translationInView(self)
            attachmentAxis = Axis(translation: translation)
            print(attachmentAxis)
            print(translation)
        }
        
        let translation = panGR.translationInView(self)
        let newAnchor = CGPoint(
            x: pulledCardRestingAnchorLocation.x + (attachmentAxis == .Horizontal ? translation.x : 0),
            y: pulledCardRestingAnchorLocation.y + (attachmentAxis == .Vertical ? translation.y : 0))
        pulledCardAttachmentBehavior?.anchorPoint = newAnchor
        pulledCardAttachmentBehavior?.damping = 1.0
        pulledCardAttachmentBehavior?.frequency = 14.0
    }
    
    func returnPulledCardPresentationToRestingState()
    {
        pulledCardAttachmentBehavior?.anchorPoint = pulledCardRestingAnchorLocation
        pulledCardAttachmentBehavior?.damping = 1.0
        pulledCardAttachmentBehavior?.frequency = 7.0
        attachmentAxis = nil
    }
    
    func teardownPulledCardBehaviors()
    {
//        guard pulledCardAttachmentBehavior != nil else { return }
        
        if pulledCardAttachmentBehavior != nil {
            animator.removeBehavior(boundaryCollisionBehavior)
            animator.removeBehavior(pulledCardDynamicItemBehavior)
            animator.removeBehavior(pulledCardAttachmentBehavior)
            boundaryCollisionBehavior = nil
            pulledCardDynamicItemBehavior = nil
            pulledCardAttachmentBehavior = nil
        }
        
        pulledCardView?.translatesAutoresizingMaskIntoConstraints = false
        pulledCardViewConstraints = pulledCardView?.mirrorView(pulledCardPlaceholderView, byReplacingConstraints: [])
    }
    
    
    //
    // .HintingSettings behaviors
    
    func buildHintingSettingsIconBehaviors()
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
    
    func updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self)
        
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
    
    func returnHintingSettingsIconPresentationToRestingState()
    {
        hintingSettingsIconView.dialProgress = 0
        if hintingSettingsIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingSettingsIconTrackingAttachmentBehavior!)
            hintingSettingsIconTrackingAttachmentBehavior = nil
        }
    }
    
    func teardownHintingSettingsIconBehaviors()
    {
        if hintingSettingsIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingSettingsIconTrackingAttachmentBehavior!)
            hintingSettingsIconTrackingAttachmentBehavior = nil
        }
        
        NSLayoutConstraint.activateConstraints(
            [hintingSettingsIconWidthConstraint, hintingSettingsIconHeightConstraint,
                hintingSettingsIconLeadingConstraint, hintingSettingsIconCenterYConstraint])
        hintingSettingsIconView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    //
    // .HintingDelete behaviors
    
    func buildHintingDeleteIconBehaviors()
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
    
    func updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self)
        
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
    
    func returnHintingDeleteIconPresentationToRestingState()
    {
        hintingDeleteIconView.dialProgress = 0
        if hintingDeleteIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingDeleteIconTrackingAttachmentBehavior!)
            hintingDeleteIconTrackingAttachmentBehavior = nil
        }
    }
    
    func teardownHintingDeleteIconBehaviors()
    {
        if hintingDeleteIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingDeleteIconTrackingAttachmentBehavior!)
            hintingDeleteIconTrackingAttachmentBehavior = nil
        }
        
        NSLayoutConstraint.activateConstraints(
            [hintingDeleteIconWidthConstraint, hintingDeleteIconHeightConstraint,
                hintingDeleteIconTrailingConstraint, hintingDeleteIconCenterYConstraint])
        hintingDeleteIconView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    //
    // .HintingShuffle behaviors
    
    func buildHintingShuffleIconBehaviors()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingShuffleIconWidthConstraint, hintingShuffleIconHeightConstraint,
                hintingShuffleIconCenterXConstraint, hintingShuffleIconTopConstraint])
        hintingShuffleIconView.translatesAutoresizingMaskIntoConstraints = true
        
        let hintingShuffleIconRestingAttachmentBehavior =
        UIAttachmentBehavior(item: hintingShuffleIconView,
            attachedToAnchor: hintingShuffleIconView.center)
        hintingShuffleIconRestingAttachmentBehavior.length = 0
        hintingShuffleIconRestingAttachmentBehavior.damping = 1.0
        hintingShuffleIconRestingAttachmentBehavior.frequency = 2.0
        animator.addBehavior(hintingShuffleIconRestingAttachmentBehavior)
        
        hintingShuffleIconRestingAnchorLocation = hintingShuffleIconView.center
    }
    
    func updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self)
        
        let trackingDelay
            = hintingShuffleIconHeightConstraint.constant
            + hintingShuffleIconTopConstraint.constant * 2
        
        if translation.y > trackingDelay
        {
            hintingShuffleIconView.dialProgress
                = (translation.y - trackingDelay)
                / (hintingShuffleSpanHeight - trackingDelay)
            
            if hintingShuffleIconTrackingAttachmentBehavior == nil
            {
                hintingShuffleIconTrackingAttachmentBehavior
                    = UIAttachmentBehavior(item: hintingShuffleIconView,
                        attachedToAnchor: hintingShuffleIconRestingAnchorLocation)
                hintingShuffleIconTrackingAttachmentBehavior!.length = 0
                hintingShuffleIconTrackingAttachmentBehavior!.damping = 1.0
                hintingShuffleIconTrackingAttachmentBehavior!.frequency = 1.5
                animator.addBehavior(hintingShuffleIconTrackingAttachmentBehavior!)
            }
            
            let newAnchor = CGPoint(
                x: hintingShuffleIconRestingAnchorLocation.x,
                y: hintingShuffleIconRestingAnchorLocation.y + translation.y - trackingDelay)
            hintingShuffleIconTrackingAttachmentBehavior?.anchorPoint = newAnchor
        }
        else
        {
            hintingShuffleIconView.dialProgress = 0
        }
    }
    
    func returnHintingShuffleIconPresentationToRestingState()
    {
        hintingShuffleIconView.dialProgress = 0
        if hintingShuffleIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingShuffleIconTrackingAttachmentBehavior!)
            hintingShuffleIconTrackingAttachmentBehavior = nil
        }
    }
    
    func teardownHintingShuffleIconBehaviors()
    {
        if hintingShuffleIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingShuffleIconTrackingAttachmentBehavior!)
            hintingShuffleIconTrackingAttachmentBehavior = nil
        }
        
        NSLayoutConstraint.activateConstraints(
            [hintingShuffleIconWidthConstraint, hintingShuffleIconHeightConstraint,
                hintingShuffleIconTopConstraint, hintingShuffleIconCenterXConstraint])
        hintingShuffleIconView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    //
    // .HintingEdit behaviors
    
    func buildHintingEditIconBehaviors()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingEditIconWidthConstraint, hintingEditIconHeightConstraint,
                hintingEditIconCenterXConstraint, hintingEditIconBottomConstraint])
        hintingEditIconView.translatesAutoresizingMaskIntoConstraints = true
        
        let hintingEditIconRestingAttachmentBehavior =
        UIAttachmentBehavior(item: hintingEditIconView,
            attachedToAnchor: hintingEditIconView.center)
        hintingEditIconRestingAttachmentBehavior.length = 0
        hintingEditIconRestingAttachmentBehavior.damping = 1.0
        hintingEditIconRestingAttachmentBehavior.frequency = 2.0
        animator.addBehavior(hintingEditIconRestingAttachmentBehavior)
        
        hintingEditIconRestingAnchorLocation = hintingEditIconView.center
    }
    
    func updateHintingEditIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self)
        
        let trackingDelay
        = hintingEditIconHeightConstraint.constant
            + hintingEditIconBottomConstraint.constant * 2
        
        if translation.y < -1*trackingDelay
        {
            hintingEditIconView.dialProgress
                = abs(translation.y + trackingDelay)
                / (hintingEditSpanHeight - trackingDelay)
            
            if hintingEditIconTrackingAttachmentBehavior == nil
            {
                hintingEditIconTrackingAttachmentBehavior
                    = UIAttachmentBehavior(item: hintingEditIconView,
                        attachedToAnchor: hintingEditIconRestingAnchorLocation)
                hintingEditIconTrackingAttachmentBehavior!.length = 0
                hintingEditIconTrackingAttachmentBehavior!.damping = 1.0
                hintingEditIconTrackingAttachmentBehavior!.frequency = 1.5
                animator.addBehavior(hintingEditIconTrackingAttachmentBehavior!)
            }
            
            let newAnchor = CGPoint(
                x: hintingEditIconRestingAnchorLocation.x,
                y: hintingEditIconRestingAnchorLocation.y + translation.y + trackingDelay)
            hintingEditIconTrackingAttachmentBehavior?.anchorPoint = newAnchor
        }
        else
        {
            hintingEditIconView.dialProgress = 0
        }
    }
    
    func returnHintingEditIconPresentationToRestingState()
    {
        hintingEditIconView.dialProgress = 0
        if hintingEditIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingEditIconTrackingAttachmentBehavior!)
            hintingEditIconTrackingAttachmentBehavior = nil
        }
    }
    
    func teardownHintingEditIconBehaviors()
    {
        if hintingEditIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingEditIconTrackingAttachmentBehavior!)
            hintingEditIconTrackingAttachmentBehavior = nil
        }
        
        NSLayoutConstraint.activateConstraints(
            [hintingEditIconWidthConstraint, hintingEditIconHeightConstraint,
                hintingEditIconBottomConstraint, hintingEditIconCenterXConstraint])
        hintingEditIconView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    //
    //
    //
    
    func displayHintingIconViewForState(state: PulledCardViewState)
    {
        switch state
        {
        case .HintingSettings:
            hintingSettingsIconView.hidden = false
            buildHintingSettingsIconBehaviors()
            
            hintingDeleteIconView.hidden = true
            teardownHintingDeleteIconBehaviors()
            
            hintingShuffleIconView.hidden = true
            teardownHintingShuffleIconBehaviors()
            
            hintingEditIconView.hidden = true
            teardownHintingEditIconBehaviors()
            
        case .HintingDelete:
            hintingSettingsIconView.hidden = true
            teardownHintingSettingsIconBehaviors()
            
            hintingDeleteIconView.hidden = false
            buildHintingDeleteIconBehaviors()
            
            hintingShuffleIconView.hidden = true
            teardownHintingShuffleIconBehaviors()
            
            hintingEditIconView.hidden = true
            teardownHintingEditIconBehaviors()
            
        case .HintingShuffle:
            hintingSettingsIconView.hidden = true
            teardownHintingSettingsIconBehaviors()
            
            hintingDeleteIconView.hidden = true
            teardownHintingDeleteIconBehaviors()
            
            hintingShuffleIconView.hidden = false
            buildHintingShuffleIconBehaviors()
            
            hintingEditIconView.hidden = true
            teardownHintingEditIconBehaviors()
            
        case .HintingEdit:
            hintingSettingsIconView.hidden = true
            teardownHintingSettingsIconBehaviors()
            
            hintingDeleteIconView.hidden = true
            teardownHintingDeleteIconBehaviors()
            
            hintingShuffleIconView.hidden = true
            teardownHintingShuffleIconBehaviors()
            
            hintingEditIconView.hidden = false
            buildHintingEditIconBehaviors()
            
        default:
            break
        }
    }
    
    //
    //
    //
    
    func layoutCardStack()
    {
        print("layout card stack, bounds = \(self.bounds), xibView.bounds = \(self.xibView.bounds)")
        
        let gap: CGFloat = 10
        for (index, cardView) in cardsInStack.enumerate()
        {
            cardView.frame = pulledCardPlaceholderView.frame
            cardView.frame.origin.y
                = retractedCardStackPlaceholderView.frame.origin.y
                + gap*CGFloat(index)
            print("card stack view, frame = \(cardView.frame)")
        }
    }

}