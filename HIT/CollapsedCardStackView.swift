//
//  CollapsedCardStackView.swift
//  HIT
//
//  Created by Nathan Melehan on 2/2/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit



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
    // MARK: - State transition effects and causes
    
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
            
        case (.ForceLayout, .ExecuteDelete):
            print(".ForceLayout -> .ExecuteDelete")
            teardownAllDynamicAnimation()
            
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
//            print(".HintingSettings -> .HintingSettings")
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
            
    
            // MARK: Delete cases
            
        case (.TrackingPan, .HintingDelete(let panGR)):
            print(".TrackingPan -> .HintingDelete")
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete, .HintingDelete(let panGR)):
//            print(".HintingDelete -> .HintingDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete,  .ConfirmDelete(let panGR)):
            print(".HintingDelete -> .ConfirmDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ConfirmDelete,  .ConfirmDelete(let panGR)):
            //            print(".ConfirmDelete -> .ConfirmDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ConfirmDelete,  .HintingDelete(let panGR)):
            print(".ConfirmDelete -> .HintingDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ConfirmDelete,  .ExecuteDelete):
            print(".ConfirmDelete -> .ExecuteDelete")
            deletePulledCard()
            
        case (.ExecuteDelete,  .NoData):
            print(".ExecuteDelete -> .NoData")
            
        case (.ExecuteDelete,  .ReturningToRest):
            print(".ExecuteDelete -> .ReturningToRest")
            returnHintingDeleteIconPresentationToRestingState()
            
        case (.ExecuteDelete,  .AtRest):
            print(".ExecuteDelete -> .AtRest")
            
        case (.HintingDelete, .ReturningToRest):
            print(".HintingDelete -> .ReturningToRest")
            returnHintingDeleteIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            
        case (.HintingDelete, .HintingSettings(let panGR)):
            print(".HintingDelete -> .HintingSettings")
            returnHintingDeleteIconPresentationToRestingState()
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
            // MARK: Shuffle cases
            
        case (.TrackingPan, .HintingShuffle(let panGR)):
            print(".TrackingPan -> .HintingShuffle")
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            updatePresentationOfCardsInStack(animated: true)
            
        case (.HintingShuffle, .HintingShuffle(let panGR)):
//            print(".HintingShuffle -> .HintingShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
            
        case (.HintingShuffle,  .ConfirmShuffle(let panGR)):
            print(".HintingShuffle -> .ConfirmShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.ConfirmShuffle,  .ConfirmShuffle(let panGR)):
//            print(".ConfirmShuffle -> .ConfirmShuffle")
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
            
            
        case (.HintingShuffle, .ReturningToRest):
            print(".HintingShuffle -> .ReturningToRest")
            returnHintingShuffleIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            updatePresentationOfCardsInStack(animated: true)
            
        case (.HintingShuffle, .HintingEdit(let panGR)):
            print(".HintingShuffle -> .HintingEdit")
            returnHintingShuffleIconPresentationToRestingState()
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            updatePresentationOfCardsInStack(animated: true)
            
            
            // .HintingEdit cases
            
        case (.TrackingPan, .HintingEdit(let panGR)):
            print(".TrackingPan -> .HintingEdit")
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .HintingEdit(let panGR)):
//            print(".HintingEdit -> .HintingEdit")
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .ReturningToRest):
            print(".HintingEdit -> .ReturningToRest")
            returnHintingEditIconPresentationToRestingState()
            returnPulledCardPresentationToRestingState()
            
        case (.HintingEdit, .HintingShuffle(let panGR)):
            print(".HintingEdit -> .HintingShuffle")
            returnHintingEditIconPresentationToRestingState()
            buildHintingIconViewDynamicAnimationForViewState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updatePulledCardPresentationWithPanGestureRecognizer(panGR)
            updatePresentationOfCardsInStack(animated: true)
            
            
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
                else if sender.translationInView(self).x < 0
                {
                    if sender.translationInView(self).x <= -1*hintingDeleteSpanWidth
                    {
                        machine.state = .ConfirmDelete(sender)
                    }
                    else
                    {
                        machine.state = .HintingDelete(sender)
                    }
                }
            }
            else if attachmentAxis == .Vertical {
                if sender.translationInView(self).y >= 0
                {
                    if !shouldShuffle()
                    {
                        machine.state = .TrackingPan(sender)
                    }
                    else if sender.translationInView(self).y >= hintingShuffleSpanHeight
                    {
                        machine.state = .ConfirmShuffle(sender)
                    }
                    else
                    {
                        machine.state = .HintingShuffle(sender)
                    }
                }
                else if sender.translationInView(self).y < 0
                {
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
            case .ConfirmDelete:
                machine.state = .ExecuteDelete
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
//        print("layout subviews")
        
        if previousBounds != bounds
        {
            print("bounds aren't equal")
            previousBounds = bounds
            machine.state = .ForceLayout
        }
    }
    
    
    //
    // MARK: - Pulled Card
    
    var pulledCard: Int?
    var pulledCardViewWrapper: CCSVCardViewWrapper?
    @IBOutlet weak var pulledCardPlaceholderView: CustomBoundsPlaceholderView!
    var pulledCardRestingAnchorLocation: CGPoint {
        get {
            return pulledCardPlaceholderView.center
        }
    }
    var pulledCardAttachmentBehavior: UIAttachmentBehavior!
    var pulledCardDynamicItemBehavior: UIDynamicItemBehavior!
    var boundaryCollisionBehavior: UICollisionBehavior!
    @IBOutlet weak var attachmentGuidelinesView: UIView!
    var pulledCardViewWrapperConstraints: [NSLayoutConstraint]?
    
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
        guard let pulledCardViewWrapper = pulledCardViewWrapper else { return }
        
        if pulledCardViewWrapperConstraints != nil
        {
            NSLayoutConstraint.deactivateConstraints(pulledCardViewWrapperConstraints!)
            pulledCardViewWrapper.translatesAutoresizingMaskIntoConstraints = true
            pulledCardViewWrapperConstraints = nil
        }
        
        let pathDiameter = 18
        let rectContainingBoundaryPath = CGRect(
            x: -1*pathDiameter/2,
            y: -1*pathDiameter/2,
            width: pathDiameter,
            height: pathDiameter)
        let customBoundaryPath = UIBezierPath(
            ovalInRect: rectContainingBoundaryPath)
        pulledCardViewWrapper.collisionBoundsType = .Path
        pulledCardViewWrapper.collisionBoundingPath = customBoundaryPath
        
        let laneCornerRadius: CGFloat = 5
        boundaryCollisionBehavior = UICollisionBehavior(items: [pulledCardViewWrapper])
        for (index, boundaryCollisionView) in attachmentGuidelinesView.subviews.enumerate()
        {
            boundaryCollisionBehavior.addBoundaryWithIdentifier("guideline \(index)",
                forPath: UIBezierPath(
                    roundedRect: boundaryCollisionView.frame,
                    cornerRadius: laneCornerRadius))
        }
        animator.addBehavior(boundaryCollisionBehavior)
        
        pulledCardDynamicItemBehavior = UIDynamicItemBehavior(items: [pulledCardViewWrapper])
        pulledCardDynamicItemBehavior.allowsRotation = false
        pulledCardDynamicItemBehavior.friction = 0
        pulledCardDynamicItemBehavior.resistance = 10.0
        pulledCardDynamicItemBehavior.elasticity = 0
        animator.addBehavior(pulledCardDynamicItemBehavior)
        
        pulledCardAttachmentBehavior = UIAttachmentBehavior(
            item: pulledCardViewWrapper,
            attachedToAnchor: pulledCardRestingAnchorLocation)
        pulledCardAttachmentBehavior.length = 0
        pulledCardAttachmentBehavior.damping = 1.0
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
        
        if pulledCardViewWrapperConstraints == nil
        {
            pulledCardViewWrapper?.translatesAutoresizingMaskIntoConstraints = false
            pulledCardViewWrapperConstraints = pulledCardViewWrapper?.mirrorView(pulledCardPlaceholderView,
                byReplacingConstraints: [])
        }
    }
    
    func pullCard(cardIndex: Int, animated: Bool)
    {
        guard let dataSource = dataSource else { return }
        
        
        defer {
            updatePresentationOfCardsInStack(animated: animated)
            attachmentAxis = nil
        }
        
        
        guard animated else
        {
            let cardViewWrapper: CCSVCardViewWrapper
            
            if cardsInStack.keys.contains(cardIndex)
            {
                let cardConstraintPair = cardsInStack[cardIndex]!
                cardsInStack.removeValueForKey(cardIndex)
                
                cardViewWrapper = cardConstraintPair.cardViewWrapper
                let oldConstraints = cardConstraintPair.constraints
                
                pulledCardViewWrapperConstraints = cardConstraintPair
                    .cardViewWrapper
                    .mirrorView(pulledCardPlaceholderView,
                        byReplacingConstraints: [oldConstraints.top, oldConstraints.centerX,
                            oldConstraints.width, oldConstraints.height])
            }
            else
            {
                cardViewWrapper = CCSVCardViewWrapper
                    .wrapperWithCardView(dataSource.cardViewForItem(cardIndex))
                insertCardViewInSubviews(cardViewWrapper, atCardIndex: cardIndex)
                
                cardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
                pulledCardViewWrapperConstraints = cardViewWrapper
                    .mirrorView(pulledCardPlaceholderView,
                        byReplacingConstraints: [])
            }
            
            pulledCard = cardIndex
            pulledCardViewWrapper = cardViewWrapper
            pulledCardViewWrapper!.accessibilityIdentifier = "Pulled Card View"
            
            return
        }
        
        
        if cardsInStack.keys.contains(cardIndex)
        {
            let cardConstraintPair = cardsInStack[cardIndex]!
            cardsInStack.removeValueForKey(cardIndex)
            
            let oldConstraints = cardConstraintPair.constraints
            NSLayoutConstraint.deactivateConstraints([oldConstraints.top, oldConstraints.centerX,
                oldConstraints.width, oldConstraints.height])
            cardConstraintPair.cardViewWrapper.translatesAutoresizingMaskIntoConstraints = true
            
            pulledCard = cardIndex
            pulledCardViewWrapper = cardConstraintPair.cardViewWrapper
        }
        else
        {
            let newCardViewWrapper = CCSVCardViewWrapper
                .wrapperWithCardView(dataSource.cardViewForItem(cardIndex))
            newCardViewWrapper.frame = firstCollapsedCardPlaceholderView.frame
            newCardViewWrapper.frame.origin.y += topConstantForCard(cardIndex)
            insertCardViewInSubviews(newCardViewWrapper, atCardIndex: cardIndex)
            
            pulledCard = cardIndex
            pulledCardViewWrapper = newCardViewWrapper
        }
        
        pulledCardViewWrapper!.accessibilityIdentifier = "Pulled Card View"
        buildPulledCardDynamicAnimation()
        pulledCardAttachmentBehavior.frequency = 3.0
    }
    
    
    //
    // MARK: - Collapsed Card Stack
    
    @IBOutlet weak var firstCollapsedCardPlaceholderView: StatePlaceholderView!
    @IBOutlet weak var collapsedCardStackGapConstraint: NSLayoutConstraint!
    
    var totalNumberOfCardsInCollection = 0
    var rangeOfCardsInCollapsedStack = NSMakeRange(0, 0)
    
    typealias StackedCardViewConstraintSet =
        (centerX: NSLayoutConstraint, top: NSLayoutConstraint,
        width: NSLayoutConstraint, height: NSLayoutConstraint)
    
    typealias CardViewAndConstraintSetPair = (cardViewWrapper: CCSVCardViewWrapper, constraints: StackedCardViewConstraintSet)
    
    var cardsInStack = [Int: CardViewAndConstraintSetPair]()
    
    private func topConstantForOffscreenCard() -> CGFloat
    {
        return self.bounds.size.height - firstCollapsedCardPlaceholderView.frame.origin.y
    }
    
    private func topConstantForCard(card: Int) -> CGFloat
    {
        // Returns vertical spacing/offset from the placeholder view
        // of the first card in the collapsed stack
        
        guard rangeOfCardsInCollapsedStack.swiftRange().contains(card) else
        {
            // if the card is outside of the range, then position the card
            // just offscreen past the bottom edge
            
            return topConstantForOffscreenCard()
        }
        
        let firstCardInCollapsedStack = rangeOfCardsInCollapsedStack.location
        
        var indexOffset: CGFloat = max(CGFloat(card - firstCardInCollapsedStack), 0)
    
        if  let pulledCard = pulledCard
        {
            if rangeOfCardsInCollapsedStack.swiftRange().contains(pulledCard)
                && card > pulledCard
            {
                // Handles shifting cards that follow the pulled card.
                // When the view is not in the .HintingShuffle state
                // and the card parameter follows the pulled card, 
                // we shift it up by one so there is no gap exposed.
                
                switch machine.state {
                case .HintingShuffle:
                    break
                    
                default:
                    indexOffset -= 1
                }
            }
            else
            {
                // In the .HintingShuffle state: 
                // When the pulled card precedes all of the cards in the stack,
                // we shift the stack down (away from the pulled card).
                // When the pulled card follows all of the cards in the stack,
                // we shift the stack up (toward the pulled card).
                
                switch machine.state {
                case .HintingShuffle:
                    if pulledCard < rangeOfCardsInCollapsedStack.swiftRange().first
                    {
                        indexOffset += 1
                    }
                    else if pulledCard >= rangeOfCardsInCollapsedStack.swiftRange().last
                    {
                        indexOffset -= 1
                    }
                    
                default:
                    break
                }
            }
        }
        
        return indexOffset * collapsedCardStackGapConstraint.constant
    }
    
    
    func stackingConstraintsForCardViewWrapper(cardViewWrapper: CCSVCardViewWrapper, atCardIndex cardIndex: Int)
        -> StackedCardViewConstraintSet
    {
        let topConstant = topConstantForCard(cardIndex)
        
        let widthConstraint = NSLayoutConstraint.pinItem(
            cardViewWrapper, toItem: firstCollapsedCardPlaceholderView, withAttribute: .Width)
        let heightConstraint = NSLayoutConstraint.pinItem(
            cardViewWrapper, toItem: firstCollapsedCardPlaceholderView, withAttribute: .Height)
        let centerXConstraint = NSLayoutConstraint.pinItem(
            cardViewWrapper, toItem: firstCollapsedCardPlaceholderView, withAttribute: .CenterX)
        let topConstraint = NSLayoutConstraint(
            item: cardViewWrapper,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: firstCollapsedCardPlaceholderView,
            attribute: .Top,
            multiplier: 1.0,
            constant: topConstant)
        
        return (centerX: centerXConstraint, top: topConstraint, width: widthConstraint, height: heightConstraint)
    }
    
    typealias CardViewWrapperAndBehaviorSetPair = (cardViewWrapper: CCSVCardViewWrapper, behaviors: [UIDynamicBehavior])
    var pulledCardsDynamicallyAnimatingToCollapsedState = [Int : CardViewWrapperAndBehaviorSetPair]()
    
    func teardownPulledCardCollapsingDynamicAnimation(cardIndex: Int, animated: Bool)
    {
        guard   let cardViewWrapperAndBehaviorSetPair = pulledCardsDynamicallyAnimatingToCollapsedState[cardIndex]
                else { return }
        
        pulledCardsDynamicallyAnimatingToCollapsedState.removeValueForKey(cardIndex)
        cardViewWrapperAndBehaviorSetPair.behaviors.forEach { animator.removeBehavior($0) }
        
        let cardViewWrapper = cardViewWrapperAndBehaviorSetPair.cardViewWrapper
        let constraints = stackingConstraintsForCardViewWrapper(cardViewWrapper, atCardIndex: cardIndex)
        
        guard animated else
        {
            if rangeOfCardsInCollapsedStack.swiftRange().contains(cardIndex)
            {
                cardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activateConstraints([constraints.top, constraints.centerX, constraints.width, constraints.height])
            }
            else
            {
                cardViewWrapper.removeFromSuperview()
            }
            return
        }
        
        let animationBlock = {
            cardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints([constraints.top, constraints.centerX, constraints.width, constraints.height])
            self.layoutIfNeeded()
        }
        
        layoutIfNeeded()
        if rangeOfCardsInCollapsedStack.swiftRange().contains(cardIndex)
        {
            UIView.animateWithDuration(0.25, animations: animationBlock)
            cardsInStack[cardIndex] = (cardViewWrapper, constraints)
        }
        else
        {
            UIView.animateWithDuration(0.25, animations: animationBlock,
                completion: { (finished) in
                    cardViewWrapper.removeFromSuperview()
            })
        }
    }
    
    func updatePresentationOfCardsInStack(animated animated: Bool)
    {
        let cardsThatHaveMoved = cardsInStack.keys
            .filter { self.cardsInStack[$0]!.constraints.top.constant != self.topConstantForCard($0) }
        
        
        defer {
            // Force contraints on pulled cards that are
            // collapsing under dynamic animation
            
            for cardIndex in pulledCardsDynamicallyAnimatingToCollapsedState.keys
            {
                teardownPulledCardCollapsingDynamicAnimation(cardIndex, animated: animated)
            }
        }
        
        
        guard animated else
        {
            cardsThatHaveMoved.forEach {
                let newTopConstant = self.topConstantForCard($0)
                self.cardsInStack[$0]?.constraints.top.constant = newTopConstant
            }
            return
        }
        
        
        layoutIfNeeded()
        for (loopIndex, card) in cardsThatHaveMoved.sort().enumerate()
        {
            UIView.animateWithDuration(0.4 + Double(loopIndex)*0.1) {
                let newTopConstant = self.topConstantForCard(card)
                self.cardsInStack[card]?.constraints.top.constant = newTopConstant
                self.layoutIfNeeded()
            }
        }
    }
    
    func insertCardViewInSubviews(newCardView: UIView, atCardIndex newCardIndex: Int)
    {
        var cardsOnScreen = [Int: CCSVCardViewWrapper]()
        
        if  let pulledCard = pulledCard,
            let pulledCardViewWrapper = pulledCardViewWrapper
        {
            cardsOnScreen[pulledCard] = pulledCardViewWrapper
        }
 
        for (cardIndex, viewAndBehaviorSetPair) in pulledCardsDynamicallyAnimatingToCollapsedState
        {
            cardsOnScreen[cardIndex] = viewAndBehaviorSetPair.cardViewWrapper
        }
        
        for (cardIndex, viewAndConstraintSetPair) in cardsInStack
        {
            cardsOnScreen[cardIndex] = viewAndConstraintSetPair.cardViewWrapper
        }
        
        if let firstFollowingCard = cardsOnScreen.keys.filter({ $0 > newCardIndex }).sort().first
        {
            insertSubview(newCardView, belowSubview: cardsOnScreen[firstFollowingCard]!)
        }
        else
        {
            addSubview(newCardView)
        }
    }
    
    func setRangeOfCardsInCollapsedStack(newRange: NSRange, animated: Bool)
    {
        print("setting range to: \(newRange)")
        
        guard let dataSource = dataSource else { return }
        
        
        // find and insert new ones that aren't already on screen
        
        var cardIndexesOnScreen
            = Array(cardsInStack.keys)
            + Array(pulledCardsDynamicallyAnimatingToCollapsedState.keys)
        if let pulledCard = pulledCard {
            cardIndexesOnScreen.append(pulledCard)
        }
        let cardsToAdd = newRange.swiftRange().filter { !cardIndexesOnScreen.contains($0) }
        for card in cardsToAdd
        {
            let cardViewWrapper = CCSVCardViewWrapper
                .wrapperWithCardView(dataSource.cardViewForItem(card))
            insertCardViewInSubviews(cardViewWrapper, atCardIndex: card)
            
            let constraints = stackingConstraintsForCardViewWrapper(cardViewWrapper, atCardIndex: card)
            constraints.top.constant = topConstantForOffscreenCard()
            cardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(
                [constraints.centerX, constraints.top,
                    constraints.width, constraints.height])
            
            cardsInStack[card] = (cardViewWrapper, constraints)
        }
        
        
        
        rangeOfCardsInCollapsedStack = newRange
        
        
        
        // remove old ones
        let cardsToRemove = cardsInStack.keys
            .filter({ !newRange.swiftRange().contains($0) })
            .sort()
        
        if !animated
        {
            cardsToRemove.forEach {
                cardsInStack[$0]!.cardViewWrapper.removeFromSuperview()
                cardsInStack.removeValueForKey($0)
            }
        }
        else
        {
            self.layoutIfNeeded()
            for (loopIndex, card) in cardsToRemove.reverse().enumerate()
            {
                let viewAndConstraintSetPair = cardsInStack[card]!
                let cardViewWrapper = viewAndConstraintSetPair.cardViewWrapper
                let constraints = viewAndConstraintSetPair.constraints
                
                let animationBlock = {
                    constraints.top.constant = self.topConstantForCard(card)
                    self.layoutIfNeeded()
                }
                
                UIView.animateWithDuration(0.2 + Double(loopIndex)*0.15,
                    animations: animationBlock,
                    completion: { (finished) in
                        cardViewWrapper.removeFromSuperview()
                })
                cardsInStack.removeValueForKey(card)
            }
        }
        
        
        
        
        updatePresentationOfCardsInStack(animated: animated)
    }
    
    
    //
    // MARK: - Settings view states, behaviors, and properties
    
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
    
    func shouldShuffle() -> Bool
    {
        if totalNumberOfCardsInCollection <= 1
        {
            return false
        }
        
        if let shouldShuffle = delegate?.shouldShufflePulledCard?()
        {
            return shouldShuffle
        }
        
        return true
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
    // MARK: - Deletion view states, behaviors, and properties
    
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
    
    
    var pulledCardDynamicallyAnimatingToDeletedState: (Int, CardViewWrapperAndBehaviorSetPair)?
    
    func shiftCardIndexesFollowingDeletedCard(deletedCardIndex: Int)
    {
        let cardsInStackFollowingDeletedCard
            = cardsInStack.keys.filter({ $0 > deletedCardIndex }).sort()
        for cardIndex in cardsInStackFollowingDeletedCard
        {
            cardsInStack[cardIndex - 1] = cardsInStack.removeValueForKey(cardIndex)
        }
        
        let collapsingCardsFollowingDeletedCard
            = pulledCardsDynamicallyAnimatingToCollapsedState
                .keys.filter({ $0 > deletedCardIndex }).sort()
        for cardIndex in collapsingCardsFollowingDeletedCard
        {
            pulledCardsDynamicallyAnimatingToCollapsedState[cardIndex - 1]
                = pulledCardsDynamicallyAnimatingToCollapsedState.removeValueForKey(cardIndex)
        }
    }
    
    func pullNextCardAndAdjustRange(deletedCardIndex: Int, animated: Bool)
    {
        totalNumberOfCardsInCollection -= 1
        shiftCardIndexesFollowingDeletedCard(deletedCardIndex)
        
        guard totalNumberOfCardsInCollection > 0 else
        {
            machine.state = .NoData
            return
        }
        
        
        let nextCard = deletedCardIndex < totalNumberOfCardsInCollection
            ? deletedCardIndex
            : totalNumberOfCardsInCollection - 1
        pullCard(nextCard, animated: animated)
        
        let newRange: NSRange
        if rangeOfCardsInCollapsedStack.length >= totalNumberOfCardsInCollection
        {
            newRange = NSMakeRange(0, totalNumberOfCardsInCollection)
        }
        else if rangeOfCardsInCollapsedStack.swiftRange().endIndex > totalNumberOfCardsInCollection
        {
            let oldRange = rangeOfCardsInCollapsedStack
            newRange = NSMakeRange(
                totalNumberOfCardsInCollection - oldRange.length,
                oldRange.length)
        }
        else if deletedCardIndex < rangeOfCardsInCollapsedStack.location
        {
            newRange = NSMakeRange(
                rangeOfCardsInCollapsedStack.location - 1,
                rangeOfCardsInCollapsedStack.length)
        }
        else
        {
            newRange = rangeOfCardsInCollapsedStack
        }
        setRangeOfCardsInCollapsedStack(newRange, animated: animated)
        
        
        if animated {
            machine.state = .ReturningToRest
        }
        else {
            machine.state = .AtRest
        }
    }
    
    func teardownPulledCardDeletionDynamicAnimation(animated animated: Bool)
    {
        guard   let card = pulledCardDynamicallyAnimatingToDeletedState?.0,
                let cardViewWrapperAndBehaviorSetPair = pulledCardDynamicallyAnimatingToDeletedState?.1
                else
        {
            return
        }
        
        pulledCardDynamicallyAnimatingToDeletedState = nil
        
        cardViewWrapperAndBehaviorSetPair.behaviors.forEach { animator.removeBehavior($0) }
        cardViewWrapperAndBehaviorSetPair.cardViewWrapper.removeFromSuperview()
        
        pullNextCardAndAdjustRange(card, animated: animated)
    }
    
    func deletePulledCard()
    {
        print("deletePulledCard")
        
        guard   let oldPulledCard = pulledCard,
                let oldPulledCardViewWrapper = pulledCardViewWrapper,
                let oldAttachmentBehavior = pulledCardAttachmentBehavior,
                let oldDynamicItemBehavior = pulledCardDynamicItemBehavior,
                let oldCollisionBehavior = boundaryCollisionBehavior
                else { return }
        
        pulledCard = nil
        pulledCardViewWrapper = nil
        pulledCardAttachmentBehavior = nil
        pulledCardDynamicItemBehavior = nil
        boundaryCollisionBehavior = nil
        dataSource?.commitDeletionForItem(oldPulledCard)
        
        animator.removeBehavior(oldCollisionBehavior)
        let cardViewAndBehaviorSetPair
            = (cardViewWrapper: oldPulledCardViewWrapper,
                behaviors: [oldAttachmentBehavior, oldDynamicItemBehavior])
        
        pulledCardDynamicallyAnimatingToDeletedState
            = (oldPulledCard, cardViewAndBehaviorSetPair)
        
        
        // Animate pulled card off screen
        var deletionLocation = pulledCardRestingAnchorLocation
        deletionLocation.x = self.bounds.width * 1.6
        oldAttachmentBehavior.anchorPoint = deletionLocation
        oldAttachmentBehavior.frequency = 2.5
        oldAttachmentBehavior.action = {
            if oldPulledCardViewWrapper.frame.origin.x > self.bounds.width {
                self.teardownPulledCardDeletionDynamicAnimation(animated: true)
            }
        }
    }
    
    
    //
    // MARK: - Shuffle view states, behaviors, and properties
    
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
        guard   let delegate = delegate,
                let oldPulledCard = pulledCard,
                let oldPulledCardViewWrapper = pulledCardViewWrapper,
                let oldAttachmentBehavior = pulledCardAttachmentBehavior,
                let oldDynamicItemBehavior = pulledCardDynamicItemBehavior,
                let oldCollisionBehavior = boundaryCollisionBehavior
                else { return }
        
        delegate.collapsedCardStackViewWillShuffle?(self)
        
        let nextPulledCard = delegate.pulledCard()
        guard nextPulledCard != pulledCard else
        {
            // if the delegate gave us back the same card for some reason,
            // completely disregard the shuffling workflow and return to
            // resting state
            
            returnPulledCardPresentationToRestingState()
            updatePresentationOfCardsInStack(animated: true)
            delegate.collapsedCardStackViewDidFailToShuffle?(self)
            return
        }
        
        pullCard(nextPulledCard, animated: true)
        
        
        // Animate the old pulled card either into the collapsed stack
        // or to an offscreen position
        
        // Note: have to remove the old collision behavior here instead
        // of in the later call to updatePresentationOfCardsInStack()
        // because if you leave it active, the shuffling behavior will 
        // periodically hang/freeze; I think that's because the previous
        // pulled card and next pulled card collide and 
        // block each other's movement
        
        animator.removeBehavior(oldCollisionBehavior)
        
        pulledCardsDynamicallyAnimatingToCollapsedState[oldPulledCard]
            = (cardViewWrapper: oldPulledCardViewWrapper, behaviors: [oldAttachmentBehavior, oldDynamicItemBehavior])
        
        var restingPosition = firstCollapsedCardPlaceholderView.center
        restingPosition.y += topConstantForCard(oldPulledCard)
        
        oldAttachmentBehavior.anchorPoint = restingPosition
        oldAttachmentBehavior.frequency = 3.0
        oldAttachmentBehavior.action = {
            if oldPulledCardViewWrapper.center.y >= restingPosition.y {
                self.teardownPulledCardCollapsingDynamicAnimation(oldPulledCard, animated: true)
            }
        }
        
        delegate.collapsedCardStackViewDidShuffle?(self)
    }
    
    
    //
    // MARK: - Edit view states, behaviors, and properties
    
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
    
    private func loadData()
    {
        guard   let dataSource = dataSource,
                let delegate = delegate
                else { return }
        
        totalNumberOfCardsInCollection = dataSource.numberOfItems()
        pullCard(delegate.pulledCard(), animated: false)
        setRangeOfCardsInCollapsedStack(delegate.rangeOfCardsInCollapsedStack(),
            animated: false)
    }
    
    func teardownAllDynamicAnimation()
    {
        teardownPulledCardDynamicAnimation()
        teardownHintingSettingsIconDynamicAnimation()
        teardownHintingDeleteIconDynamicAnimation()
        teardownHintingShuffleIconDynamicAnimation()
        teardownHintingEditIconDynamicAnimation()
        updatePresentationOfCardsInStack(animated: false)
        teardownPulledCardDeletionDynamicAnimation(animated: false)
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

class CCSVCardViewWrapper: CustomCollisionBoundsView
{
    var cardView: CardView? {
        willSet {
            if cardView != nil {
                cardView!.removeFromSuperview()
            }
        }
        didSet {
            if cardView != nil {
                addSubview(cardView!)
                cardView?.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.pinItem(cardView!, toItem: self, withAttribute: .Width).active = true
                NSLayoutConstraint.pinItem(cardView!, toItem: self, withAttribute: .Height).active = true
                NSLayoutConstraint.pinItem(cardView!, toItem: self, withAttribute: .CenterX).active = true
                NSLayoutConstraint.pinItem(cardView!, toItem: self, withAttribute: .CenterY).active = true
            }
        }
    }
    
    class func wrapperWithCardView(cardView: CardView) -> CCSVCardViewWrapper
    {
        let wrapper = CCSVCardViewWrapper()
        wrapper.cardView = cardView
        return wrapper
    }
}
