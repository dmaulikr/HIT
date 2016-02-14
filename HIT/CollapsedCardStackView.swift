//
//  CollapsedCardStackView.swift
//  HIT
//
//  Created by Nathan Melehan on 2/2/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

enum CollapsedCardStackViewState: StateMachineDataSource
{
    case WaitingForData
    case ReloadData
    case ForceLayout
    
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
    case ExecuteShuffle
    
    
    func shouldTransitionFrom(from: CollapsedCardStackViewState, to: CollapsedCardStackViewState) -> Should<CollapsedCardStackViewState>
    {
        switch (from, to)
        {
        case (_, .ReloadData):                  return .Redirect(.AtRest)
        case (_, .ForceLayout):                 return .Redirect(.AtRest)
        case (.ForceLayout, .AtRest):           return .Continue
        case (.ReloadData, .AtRest):            return .Continue
            
        case (.AtRest, .TrackingPan):           return .Continue
        case (.ReturningToRest, .AtRest):       return .Continue
            
        case (.TrackingPan, .TrackingPan):      return .Continue
        case (.TrackingPan, .ReturningToRest):  return .Continue
        case (.ReturningToRest, .TrackingPan):  return .Continue
            
            
            
        case (.TrackingPan,     .HintingSettings):  return .Continue
        case (.HintingSettings, .HintingSettings):  return .Continue
        case (.HintingSettings, .ReturningToRest):  return .Continue
        case (.HintingSettings, .HintingDelete):    return .Continue
            
            
        case (.TrackingPan,     .HintingDelete):    return .Continue
        case (.HintingDelete,   .HintingDelete):    return .Continue
        case (.HintingDelete,   .ReturningToRest):  return .Continue
        case (.HintingDelete,   .HintingSettings):  return .Continue

            
        case (.TrackingPan,     .HintingShuffle):    return .Continue
        case (.HintingShuffle,  .HintingShuffle):    return .Continue
            
        case (.HintingShuffle,  .ConfirmShuffle):    return .Continue
        case (.ConfirmShuffle,  .ConfirmShuffle):    return .Continue
        case (.ConfirmShuffle,  .HintingShuffle):    return .Continue
        case (.ConfirmShuffle,  .ExecuteShuffle):    return .Redirect(.ReturningToRest)
        case (.ExecuteShuffle,  .ReturningToRest):   return .Continue
            
        case (.HintingShuffle,  .ReturningToRest):  return .Continue
        case (.HintingShuffle,  .HintingEdit):      return .Continue
            
            
        case (.TrackingPan,     .HintingEdit):      return .Continue
        case (.HintingEdit,     .HintingEdit):      return .Continue
        case (.HintingEdit,     .ReturningToRest):  return .Continue
        case (.HintingEdit,     .HintingShuffle):   return .Continue

            
        default:
            return .Abort
        }
    }
}

@IBDesignable class CollapsedCardStackView: XibDesignedView, StateMachineDelegate, UIDynamicAnimatorDelegate
{
    //
    // MARK: - Properties
    
    @IBOutlet var delegate: CollapsedCardStackViewDelegate? {
        didSet {
            reloadData()
        }
    }
    
    @IBOutlet var dataSource: CollapsedCardStackViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
//        animator.debugEnabled = true
        return animator
    }()
    
    var panGR: UIPanGestureRecognizer?


    //
    // MARK: - State
    
    typealias StateType = CollapsedCardStackViewState
    lazy var machine: StateMachine<CollapsedCardStackView> = {
        return StateMachine(initialState: .WaitingForData, delegate: self)
    }()
    
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
            
        case (_, .ForceLayout):
            print("_ (\(fromState)) -> .ForceLayout")
            break
            
        case (.ForceLayout, .AtRest):
            print(".ForceLayout -> .AtRest")
            teardownAllDynamicAnimation()
            
        case (.ReloadData, .AtRest):
            print(".ReloadData -> .AtRest")
            break
            
        case (.AtRest, .TrackingPan(let panGR)):
            print(".AtRest -> .TrackingPan")
            buildPulledCardDynamicAnimation()
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
            teardownAllDynamicAnimation()
            
            
            // .HintingSettings cases
            
        case (.TrackingPan, .HintingSettings(let panGR)):
            print(".TrackingPan -> .HintingSettings")
            buildHintingIconViewDynamicAnimationForViewState(toState)
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
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
            // .HintingDelete cases
            
        case (.TrackingPan, .HintingDelete(let panGR)):
            print(".TrackingPan -> .HintingDelete")
            buildHintingIconViewDynamicAnimationForViewState(toState)
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
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
            // .HintingShuffle cases
            
        case (.TrackingPan, .HintingShuffle(let panGR)):
            print(".TrackingPan -> .HintingShuffle")
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            updateConstraintsOfCardsInStack()
            
        case (.HintingShuffle, .HintingShuffle(let panGR)):
            print(".HintingShuffle -> .HintingShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
        case (.HintingShuffle,  .ConfirmShuffle(let panGR)):
            print(".HintingShuffle -> .ConfirmShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ConfirmShuffle,  .ConfirmShuffle(let panGR)):
            print(".ConfirmShuffle -> .ConfirmShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ConfirmShuffle,  .HintingShuffle(let panGR)):
            print(".ConfirmShuffle -> .HintingShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ConfirmShuffle,  .ExecuteShuffle):
            print(".ConfirmShuffle -> .ExecuteShuffle")
            shufflePulledCard()
            
        case (.ExecuteShuffle,  .ReturningToRest):
            print(".ExecuteShuffle -> .ReturningToRest")
            returnHintingShuffleIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            updateConstraintsOfCardsInStack()
            
            
        case (.HintingShuffle, .ReturningToRest):
            print(".HintingShuffle -> .ReturningToRest")
            returnHintingShuffleIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            updateConstraintsOfCardsInStack()
            
        case (.HintingShuffle, .HintingEdit(let panGR)):
            print(".HintingSettings -> .HintingShuffle")
            returnHintingShuffleIconPresentationToRestingState()
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            updateConstraintsOfCardsInStack()
            
            
            // .HintingEdit cases
            
        case (.TrackingPan, .HintingEdit(let panGR)):
            print(".TrackingPan -> .HintingEdit")
            buildHintingIconViewDynamicAnimationForViewState(toState)
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
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            updateConstraintsOfCardsInStack()
            
            
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
                if sender.translationInView(self).y >= 0
                {
                    if sender.translationInView(self).y >= hintingShuffleSpanHeight
                    {
                        machine.state = .ConfirmShuffle(sender)
                    }
                    else
                    {
                        machine.state = .HintingShuffle(sender)
                    }
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
            switch machine.state
            {
            case .ConfirmShuffle:
                machine.state = .ExecuteShuffle
            default:
                machine.state = .ReturningToRest
            }
            print("\n")
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
    
    var previousBounds: CGRect?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layout subviews")
        
        if previousBounds != bounds
        {
            print("bounds aren't equal")
            previousBounds = bounds
            machine.state = .ForceLayout
        }
    }
    
    
    //
    //
    //
    
    
    // MARK: - Pulled Card
    
    var pulledCard: Int?
    var pulledCardView: TestCardView?
    @IBOutlet weak var pulledCardPlaceholderView: CustomBoundsPlaceholderView!
    var pulledCardRestingAnchorLocation: CGPoint!
    var pulledCardAttachmentBehavior: UIAttachmentBehavior!
    var pulledCardDynamicItemBehavior: UIDynamicItemBehavior!
    var boundaryCollisionBehavior: UICollisionBehavior!
    @IBOutlet weak var attachmentGuidelinesView: UIView!
    var pulledCardViewConstraints: [NSLayoutConstraint]?
    
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
    
    func buildPulledCardDynamicAnimation()
    {
        guard let pulledCardView = pulledCardView else { return }
        
        NSLayoutConstraint.deactivateConstraints(pulledCardViewConstraints!)
        pulledCardView.translatesAutoresizingMaskIntoConstraints = true
        setNeedsLayout()
        
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
    
    func teardownPulledCardDynamicAnimation()
    {
        if pulledCardAttachmentBehavior != nil {
            animator.removeBehavior(boundaryCollisionBehavior)
            animator.removeBehavior(pulledCardDynamicItemBehavior)
            animator.removeBehavior(pulledCardAttachmentBehavior)
            boundaryCollisionBehavior = nil
            pulledCardDynamicItemBehavior = nil
            pulledCardAttachmentBehavior = nil
        }
        
        attachmentAxis = nil
        
        pulledCardView?.translatesAutoresizingMaskIntoConstraints = false
        pulledCardViewConstraints = pulledCardView?.mirrorView(pulledCardPlaceholderView,
            byReplacingConstraints: pulledCardViewConstraints ?? [])
        setNeedsLayout()
    }
    
    
    //
    // MARK: - Collapsed Card Stack
    
    @IBOutlet weak var firstCollapsedCardPlaceholderView: StatePlaceholderView!
    @IBOutlet weak var collapsedCardStackGapConstraint: NSLayoutConstraint!
    
    var cardAtTopOfStack: Int?
    
    typealias StackedCardViewConstraints =
        (centerX: NSLayoutConstraint, top: NSLayoutConstraint,
        width: NSLayoutConstraint, height: NSLayoutConstraint)
    
    typealias CardViewConstraintPair = (cardView: TestCardView, constraints: StackedCardViewConstraints?)
    
    var cardsInStack = [Int: CardViewConstraintPair]()
//    var cardViewsInStack = [Int: TestCardView]()
//    var topConstraintsOfCardsInStack = [Int: NSLayoutConstraint]()
    
    private func topConstantForCard(card: Int) -> CGFloat?
    {
        guard let cardAtTopOfStack = cardAtTopOfStack else
        {
            return nil
        }
        
        var indexOffset: CGFloat = CGFloat(card - cardAtTopOfStack)
        
        guard   let pulledCard = pulledCard
                where card != pulledCard
                else
        {
            return indexOffset * collapsedCardStackGapConstraint.constant
        }
    
        if pulledCard >= cardAtTopOfStack
        {
            // Handles shifting cards above and below the pulled card
            // when the view is in the .HintingShuffle state
            if card > pulledCard {
                switch machine.state {
                case .HintingShuffle:
                    break
                    
                default:
                    indexOffset -= 1
                }
            }
            else {
                switch machine.state {
                case .HintingShuffle:
                    indexOffset -= 0.1
                    
                default:
                    break
                }
            }
        }
        
        return indexOffset * collapsedCardStackGapConstraint.constant
    }
    
    func updateConstraintsOfCardsInStack()
    {
        guard let pulledCard = pulledCard else { return }
        
        layoutIfNeeded()
        
        var cardIndexesBeforePulledCard
            = self.cardsInStack.keys
            .filter { $0 < pulledCard }
            .sort()
        
        var cardIndexesAfterPulledCard
            = self.cardsInStack.keys
            .filter { $0 > pulledCard }
            .sort()
        
        switch machine.state
        {
        case .HintingShuffle:
            cardIndexesAfterPulledCard = cardIndexesAfterPulledCard.reverse()
        default:
            cardIndexesBeforePulledCard = cardIndexesBeforePulledCard.reverse()
        }
        
        for (loopIndex, card) in cardIndexesBeforePulledCard.enumerate()
        {
            UIView.animateWithDuration(0.2 + Double(loopIndex)*0.15) {
                let newTopConstant = self.topConstantForCard(card)!
                self.cardsInStack[card]?.constraints?.top.constant = newTopConstant
                self.layoutIfNeeded()
            }
        }
        
        for (loopIndex, card) in cardIndexesAfterPulledCard.enumerate()
        {
            UIView.animateWithDuration(0.2 + Double(loopIndex)*0.15) {
                let newTopConstant = self.topConstantForCard(card)!
                self.cardsInStack[card]?.constraints?.top.constant = newTopConstant
                self.layoutIfNeeded()
            }
        }
    }
    
    
    //
    // MARK: - .HintingSettings
    
    @IBOutlet weak var hintingSettingsIconView: HintingIconView!
    @IBOutlet var hintingSettingsIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingSettingsIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingSettingsIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var hintingSettingsIconCenterYConstraint: NSLayoutConstraint!
    
    private var hintingSettingsIconRestingAnchorLocation: CGPoint!
    private var hintingSettingsIconRestingAttachmentBehavior: UIAttachmentBehavior?
    private var hintingSettingsIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingSettings
    @IBOutlet weak var hintingSettingsTrackingSpanView: StatePlaceholderView!
    var hintingSettingsSpanWidth: CGFloat {
        get {
            return hintingSettingsTrackingSpanView.frame.width
        }
    }
    
    func buildHintingSettingsIconDynamicAnimation()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingSettingsIconWidthConstraint, hintingSettingsIconHeightConstraint,
                hintingSettingsIconLeadingConstraint, hintingSettingsIconCenterYConstraint])
        hintingSettingsIconView.translatesAutoresizingMaskIntoConstraints = true
        
        if hintingSettingsIconRestingAttachmentBehavior == nil {
            hintingSettingsIconRestingAttachmentBehavior =
                UIAttachmentBehavior(item: hintingSettingsIconView,
                    attachedToAnchor: hintingSettingsIconView.center)
        }
        hintingSettingsIconRestingAttachmentBehavior!.length = 0
        hintingSettingsIconRestingAttachmentBehavior!.damping = 1.0
        hintingSettingsIconRestingAttachmentBehavior!.frequency = 2.0
        animator.addBehavior(hintingSettingsIconRestingAttachmentBehavior!)
        
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
    
    func teardownHintingSettingsIconDynamicAnimation()
    {
        returnHintingSettingsIconPresentationToRestingState()
        
        if hintingSettingsIconRestingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingSettingsIconRestingAttachmentBehavior!)
            hintingSettingsIconRestingAttachmentBehavior = nil
        }
        
        hintingSettingsIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(
            [hintingSettingsIconWidthConstraint, hintingSettingsIconHeightConstraint,
                hintingSettingsIconLeadingConstraint, hintingSettingsIconCenterYConstraint])
    }
    
    
    //
    // MARK: - .HintingDelete
    
    @IBOutlet weak var hintingDeleteIconView: HintingIconView!
    @IBOutlet var hintingDeleteIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingDeleteIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingDeleteIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var hintingDeleteIconCenterYConstraint: NSLayoutConstraint!
    
    private var hintingDeleteIconRestingAnchorLocation: CGPoint!
    private var hintingDeleteIconRestingAttachmentBehavior: UIAttachmentBehavior?
    private var hintingDeleteIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingDelete
    @IBOutlet weak var hintingDeleteTrackingSpanView: StatePlaceholderView!
    var hintingDeleteSpanWidth: CGFloat {
        get {
            return hintingDeleteTrackingSpanView.frame.width
        }
    }
    
    func buildHintingDeleteIconDynamicAnimation()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingDeleteIconWidthConstraint, hintingDeleteIconHeightConstraint,
                hintingDeleteIconTrailingConstraint, hintingDeleteIconCenterYConstraint])
        hintingDeleteIconView.translatesAutoresizingMaskIntoConstraints = true
        
        if hintingDeleteIconRestingAttachmentBehavior == nil {
            hintingDeleteIconRestingAttachmentBehavior =
                UIAttachmentBehavior(item: hintingDeleteIconView,
                    attachedToAnchor: hintingDeleteIconView.center)
        }
        hintingDeleteIconRestingAttachmentBehavior!.length = 0
        hintingDeleteIconRestingAttachmentBehavior!.damping = 1.0
        hintingDeleteIconRestingAttachmentBehavior!.frequency = 2.0
        animator.addBehavior(hintingDeleteIconRestingAttachmentBehavior!)
        
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
    
    func teardownHintingDeleteIconDynamicAnimation()
    {
        returnHintingDeleteIconPresentationToRestingState()
        
        if hintingDeleteIconRestingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingDeleteIconRestingAttachmentBehavior!)
            hintingDeleteIconRestingAttachmentBehavior = nil
        }
        
        hintingDeleteIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(
            [hintingDeleteIconWidthConstraint, hintingDeleteIconHeightConstraint,
                hintingDeleteIconTrailingConstraint, hintingDeleteIconCenterYConstraint])
    }
    
    
    //
    // MARK: - .HintingShuffle
    
    @IBOutlet weak var hintingShuffleIconView: HintingIconView!
    @IBOutlet var hintingShuffleIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingShuffleIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingShuffleIconCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var hintingShuffleIconTopConstraint: NSLayoutConstraint!
    
    private var hintingShuffleIconRestingAnchorLocation: CGPoint!
    private var hintingShuffleIconRestingAttachmentBehavior: UIAttachmentBehavior?
    private var hintingShuffleIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingShuffle
    @IBOutlet weak var hintingShuffleTrackingSpanView: StatePlaceholderView!
    var hintingShuffleSpanHeight: CGFloat {
        get {
            return hintingShuffleTrackingSpanView.frame.height
        }
    }
    
    func buildHintingShuffleIconDynamicAnimation()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingShuffleIconWidthConstraint, hintingShuffleIconHeightConstraint,
                hintingShuffleIconCenterXConstraint, hintingShuffleIconTopConstraint])
        hintingShuffleIconView.translatesAutoresizingMaskIntoConstraints = true
        
        if hintingShuffleIconRestingAttachmentBehavior == nil {
            hintingShuffleIconRestingAttachmentBehavior =
                UIAttachmentBehavior(item: hintingShuffleIconView,
                    attachedToAnchor: hintingShuffleIconView.center)
        }
        hintingShuffleIconRestingAttachmentBehavior!.length = 0
        hintingShuffleIconRestingAttachmentBehavior!.damping = 1.0
        hintingShuffleIconRestingAttachmentBehavior!.frequency = 2.0
        animator.addBehavior(hintingShuffleIconRestingAttachmentBehavior!)
        
        hintingShuffleIconRestingAnchorLocation = hintingShuffleIconView.center
    }
    
    func updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self)
        
        var trackingDelay
            = hintingShuffleIconHeightConstraint.constant
            + hintingShuffleIconTopConstraint.constant * 2
        if trackingDelay > hintingShuffleSpanHeight {
            trackingDelay = 0
        }
        
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
    
    func teardownHintingShuffleIconDynamicAnimation()
    {
        returnHintingShuffleIconPresentationToRestingState()
        
        if hintingShuffleIconRestingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingShuffleIconRestingAttachmentBehavior!)
            hintingShuffleIconRestingAttachmentBehavior = nil
        }
        
        
        hintingShuffleIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(
            [hintingShuffleIconWidthConstraint, hintingShuffleIconHeightConstraint,
                hintingShuffleIconTopConstraint, hintingShuffleIconCenterXConstraint])
    }
    
    func shufflePulledCard()
    {
        guard   let oldPulledCard = pulledCard,
                let oldPulledCardView = pulledCardView,
                let oldAttachmentBehavior = pulledCardAttachmentBehavior,
                let oldDynamicItemBehavior = pulledCardDynamicItemBehavior,
                let oldCollisionBehavior = boundaryCollisionBehavior
                else { return }
        
        delegate?.collapsedCardStackViewWillShuffle?(self)
        
        guard   let nextPulledCard = delegate?.pulledCard()
                where nextPulledCard != pulledCard
                else { return }
        
        if cardsInStack.keys.contains(nextPulledCard)
        {
            let cardConstraintPair = cardsInStack[nextPulledCard]!
            cardsInStack.removeValueForKey(nextPulledCard)
            print("cardsInStack after removing value for key \(nextPulledCard): \(cardsInStack)")
            pulledCard = nextPulledCard
            pulledCardView = cardConstraintPair.cardView
            if let oldConstraints = cardConstraintPair.constraints {
                NSLayoutConstraint.deactivateConstraints([oldConstraints.top, oldConstraints.centerX,
                    oldConstraints.width, oldConstraints.height])
                pulledCardView?.translatesAutoresizingMaskIntoConstraints = true

            }
            buildPulledCardDynamicAnimation()
            
            animator.removeBehavior(oldAttachmentBehavior)
            animator.removeBehavior(oldDynamicItemBehavior)
            animator.removeBehavior(oldCollisionBehavior)
            
            oldPulledCardView.translatesAutoresizingMaskIntoConstraints = false
            let newConstraints = stackingConstraintsForCardView(oldPulledCardView, atCardIndex: oldPulledCard)!
            NSLayoutConstraint.activateConstraints([newConstraints.top, newConstraints.centerX, newConstraints.width, newConstraints.height])
            cardsInStack[oldPulledCard] = (oldPulledCardView, newConstraints)
            updateConstraintsOfCardsInStack()
        }
        
        // Determine if old pulled card will end up in card stack
//        let restingPosition: CGPoint
//        
//        if pulledCard < cardAtTopOfStack! {
//            restingPosition = firstCollapsedCardPlaceholderView.center
//        }
//        else if pulledCard > cardAtTopOfStack
        
        // Determine final resting position of old pulled card
        // Attach behavior for card to resting position
        // Set a new pulled card, ensure it's different from old one
        // Build attachment behavior for new pulled card
        // Set initial position of new pulled card
    }
    
    
    //
    // MARK: - .HintingEdit
    
    @IBOutlet weak var hintingEditIconView: HintingIconView!
    @IBOutlet var hintingEditIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var hintingEditIconBottomConstraint: NSLayoutConstraint!
    
    private var hintingEditIconRestingAnchorLocation: CGPoint!
    private var hintingEditIconRestingAttachmentBehavior: UIAttachmentBehavior?
    private var hintingEditIconTrackingAttachmentBehavior: UIAttachmentBehavior?
    
    // Represents the width or range of the tracking gesture
    // across which the UI state is set to .HintingEdit
    @IBOutlet weak var hintingEditTrackingSpanView: StatePlaceholderView!
    var hintingEditSpanHeight: CGFloat {
        get {
            return hintingEditTrackingSpanView.frame.height
        }
    }
    
    func buildHintingEditIconDynamicAnimation()
    {
        NSLayoutConstraint.deactivateConstraints(
            [hintingEditIconWidthConstraint, hintingEditIconHeightConstraint,
                hintingEditIconCenterXConstraint, hintingEditIconBottomConstraint])
        hintingEditIconView.translatesAutoresizingMaskIntoConstraints = true
        
        if hintingEditIconRestingAttachmentBehavior == nil {
            hintingEditIconRestingAttachmentBehavior =
                UIAttachmentBehavior(item: hintingEditIconView,
                    attachedToAnchor: hintingEditIconView.center)
        }
        hintingEditIconRestingAttachmentBehavior!.length = 0
        hintingEditIconRestingAttachmentBehavior!.damping = 1.0
        hintingEditIconRestingAttachmentBehavior!.frequency = 2.0
        animator.addBehavior(hintingEditIconRestingAttachmentBehavior!)
        
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
    
    func teardownHintingEditIconDynamicAnimation()
    {
        returnHintingEditIconPresentationToRestingState()
        
        if hintingEditIconRestingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingEditIconRestingAttachmentBehavior!)
            hintingEditIconRestingAttachmentBehavior = nil
        }
        
        hintingEditIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(
            [hintingEditIconWidthConstraint, hintingEditIconHeightConstraint,
                hintingEditIconBottomConstraint, hintingEditIconCenterXConstraint])
    }
    
    
    // 
    // MARK: - Etc
    
    func stackingConstraintsForCardView(cardView: TestCardView, atCardIndex cardIndex: Int)
        -> StackedCardViewConstraints?
    {
        guard let topConstant = topConstantForCard(cardIndex) else { return nil }
        
        let widthConstraint = NSLayoutConstraint.pinItem(
            cardView, toItem: firstCollapsedCardPlaceholderView, withAttribute: .Width)
        let heightConstraint = NSLayoutConstraint.pinItem(
            cardView, toItem: firstCollapsedCardPlaceholderView, withAttribute: .Height)
        let centerXConstraint = NSLayoutConstraint.pinItem(
            cardView, toItem: firstCollapsedCardPlaceholderView, withAttribute: .CenterX)
        let topConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: firstCollapsedCardPlaceholderView,
            attribute: .Top,
            multiplier: 1.0,
            constant: topConstant)
        
        return (centerX: centerXConstraint, top: topConstraint, width: widthConstraint, height: heightConstraint)
    }
    
    private func loadData()
    {
        guard   let dataSource = dataSource,
                let delegate = delegate
                else { return }
        
        pulledCard = delegate.pulledCard()
        pulledCardView = dataSource.cardViewForItem(pulledCard!)
        if let pulledCardView = pulledCardView
        {
            pulledCardView.accessibilityIdentifier = "Pulled Card View"
            addSubview(pulledCardView)
            pulledCardView.translatesAutoresizingMaskIntoConstraints = false
            pulledCardViewConstraints = pulledCardView.mirrorView(pulledCardPlaceholderView,
                byReplacingConstraints: [])
        }
        
        cardAtTopOfStack = delegate.cardAtTopOfStack()
        let cardsInStackRange = (cardAtTopOfStack!..<cardAtTopOfStack! + delegate.numberOfItemsToDisplayInStack())
        
        for card in cardsInStackRange
        {
            if card == pulledCard { continue }
            
            let cardView = dataSource.cardViewForItem(card)
            
            if let pulledCardView = pulledCardView
            {
                if card < pulledCard {
                    insertSubview(cardView, belowSubview: pulledCardView)
                }
                else {
                    addSubview(cardView)
                }
            }
            else
            {
                addSubview(cardView)
            }
            
            let constraints = stackingConstraintsForCardView(cardView, atCardIndex: card)!
            
            cardView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(
                [constraints.centerX, constraints.top,
                constraints.width, constraints.height])
            
            cardsInStack[card] = (cardView, constraints)
//            cardViewsInStack[card] = cardView
//            topConstraintsOfCardsInStack[card] = topConstraint
        }
    }
    
    func teardownAllDynamicAnimation()
    {
        teardownPulledCardDynamicAnimation()
        teardownHintingSettingsIconDynamicAnimation()
        teardownHintingDeleteIconDynamicAnimation()
        teardownHintingShuffleIconDynamicAnimation()
        teardownHintingEditIconDynamicAnimation()
        updateConstraintsOfCardsInStack()
    }
    
    func buildHintingIconViewDynamicAnimationForViewState(state: CollapsedCardStackViewState)
    {
        switch state
        {
        case .HintingSettings:
            hintingSettingsIconView.hidden = false
            buildHintingSettingsIconDynamicAnimation()
            
            hintingDeleteIconView.hidden = true
            teardownHintingDeleteIconDynamicAnimation()
            
            hintingShuffleIconView.hidden = true
            teardownHintingShuffleIconDynamicAnimation()
            
            hintingEditIconView.hidden = true
            teardownHintingEditIconDynamicAnimation()
            
        case .HintingDelete:
            hintingSettingsIconView.hidden = true
            teardownHintingSettingsIconDynamicAnimation()
            
            hintingDeleteIconView.hidden = false
            buildHintingDeleteIconDynamicAnimation()
            
            hintingShuffleIconView.hidden = true
            teardownHintingShuffleIconDynamicAnimation()
            
            hintingEditIconView.hidden = true
            teardownHintingEditIconDynamicAnimation()
            
        case .HintingShuffle:
            hintingSettingsIconView.hidden = true
            teardownHintingSettingsIconDynamicAnimation()
            
            hintingDeleteIconView.hidden = true
            teardownHintingDeleteIconDynamicAnimation()
            
            hintingShuffleIconView.hidden = false
            buildHintingShuffleIconDynamicAnimation()
            
            hintingEditIconView.hidden = true
            teardownHintingEditIconDynamicAnimation()
            
        case .HintingEdit:
            hintingSettingsIconView.hidden = true
            teardownHintingSettingsIconDynamicAnimation()
            
            hintingDeleteIconView.hidden = true
            teardownHintingDeleteIconDynamicAnimation()
            
            hintingShuffleIconView.hidden = true
            teardownHintingShuffleIconDynamicAnimation()
            
            hintingEditIconView.hidden = false
            buildHintingEditIconDynamicAnimation()
            
        default:
            break
        }
    }
}
