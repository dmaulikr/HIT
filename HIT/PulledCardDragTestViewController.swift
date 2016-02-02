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
    
    
    // Data controller
    
    let dataSource: MantraDataSource = UserMantraDataManager.sharedManager
    let mantrasInRetractedStack = [Mantra]()
    
    // Pulled Card View
    var pulledCardView: CardView?
    
    
    // Guides for the collision boundaries which constrain card movement
    @IBOutlet weak var tlBoundary: StatePlaceholderView!
    @IBOutlet weak var blBoundary: StatePlaceholderView!
    @IBOutlet weak var brBoundary: StatePlaceholderView!
    @IBOutlet weak var trBoundary: StatePlaceholderView!
    
    
    // Pulled Card Placeholder
    @IBOutlet weak var pulledCardPlaceholderView: CustomBoundsPlaceholderView!
    @IBOutlet weak var pulledCardPlaceholderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pulledCardPlaceholderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pulledCardPlaceholderCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var pulledCardPlaceholderCenterYConstraint: NSLayoutConstraint!
    
    var pulledCardRestingAnchorLocation: CGPoint!
    var pulledCardAttachmentBehavior: UIAttachmentBehavior!
    var pulledCardDynamicItemBehavior: UIDynamicItemBehavior!
    
    
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
            x: pulledCardRestingAnchorLocation.x + (attachmentAxis == .Horizontal ? translation.x : 0),
            y: pulledCardRestingAnchorLocation.y + (attachmentAxis == .Vertical ? translation.y : 0))
        pulledCardAttachmentBehavior?.anchorPoint = newAnchor
        pulledCardAttachmentBehavior?.damping = 1.0
        pulledCardAttachmentBehavior?.frequency = 14.0
    }
    
    func returnCardAttachmentBehaviorToRestingLocation()
    {
        pulledCardAttachmentBehavior?.anchorPoint = pulledCardRestingAnchorLocation
        pulledCardAttachmentBehavior?.damping = 1.0
        pulledCardAttachmentBehavior?.frequency = 7.0
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
    
    func updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self.view)
        
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
    
    func returnHintingShuffleIconToRestingLocation()
    {
        hintingShuffleIconView.dialProgress = 0
        if hintingShuffleIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingShuffleIconTrackingAttachmentBehavior!)
            hintingShuffleIconTrackingAttachmentBehavior = nil
        }
    }
    
    func updateHintingEditIconPresentationWithPanGestureRecognizer(panGR: UIPanGestureRecognizer)
    {
        let translation = panGR.translationInView(self.view)
        
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
    
    func returnHintingEditIconToRestingLocation()
    {
        hintingEditIconView.dialProgress = 0
        if hintingEditIconTrackingAttachmentBehavior != nil
        {
            animator.removeBehavior(hintingEditIconTrackingAttachmentBehavior!)
            hintingEditIconTrackingAttachmentBehavior = nil
        }
    }
    
    func displayHintingIconViewForState(state: CardState)
    {
        switch state
        {
        case .HintingSettings:
            hintingSettingsIconView.hidden = false
            hintingDeleteIconView.hidden = true
            hintingShuffleIconView.hidden = true
            hintingEditIconView.hidden = true
            
        case .HintingDelete:
            hintingSettingsIconView.hidden = true
            hintingDeleteIconView.hidden = false
            hintingShuffleIconView.hidden = true
            hintingEditIconView.hidden = true
            
        case .HintingShuffle:
            hintingSettingsIconView.hidden = true
            hintingDeleteIconView.hidden = true
            hintingShuffleIconView.hidden = false
            hintingEditIconView.hidden = true
            
        case .HintingEdit:
            hintingSettingsIconView.hidden = true
            hintingDeleteIconView.hidden = true
            hintingShuffleIconView.hidden = true
            hintingEditIconView.hidden = false
            
        default:
            break
        }
    }
    
    func didTransitionFrom(fromState: StateType, toState: StateType)
    {
        
        switch (fromState, toState)
        {
            
        case (.TrackingPan, .TrackingPan(let panGR)):
            print(".TrackingPan -> .TrackingPan")
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.TrackingPan, .ReturningToRest):
            print(".TrackingPan -> .ReturningToRest")
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.ReturningToRest, .TrackingPan(let panGR)):
            print(".ReturningToRest -> .TrackingPan")
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
            
        // .HintingSettings cases
            
        case (.TrackingPan, .HintingSettings(let panGR)):
            print(".TrackingPan -> .HintingSettings")
            displayHintingIconViewForState(toState)
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingSettings, .HintingSettings(let panGR)):
            print(".HintingSettings -> .HintingSettings")
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingSettings, .ReturningToRest):
            print(".HintingSettings -> .ReturningToRest")
            returnHintingSettingsIconToRestingLocation()
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.HintingSettings, .HintingDelete(let panGR)):
            print(".HintingSettings -> .HintingDelete")
            returnHintingSettingsIconToRestingLocation()
            displayHintingIconViewForState(toState)
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
            
        // .HintingDelete cases
            
        case (.TrackingPan, .HintingDelete(let panGR)):
            print(".TrackingPan -> .HintingDelete")
            displayHintingIconViewForState(toState)
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete, .HintingDelete(let panGR)):
            print(".HintingDelete -> .HintingDelete")
            updateHintingDeleteIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingDelete, .ReturningToRest):
            print(".HintingDelete -> .ReturningToRest")
            returnHintingDeleteIconToRestingLocation()
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.HintingDelete, .HintingSettings(let panGR)):
            print(".HintingSettings -> .HintingDelete")
            returnHintingDeleteIconToRestingLocation()
            displayHintingIconViewForState(toState)
            updateHintingSettingsIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
            
        // .HintingShuffle cases
            
        case (.TrackingPan, .HintingShuffle(let panGR)):
            print(".TrackingPan -> .HintingShuffle")
            displayHintingIconViewForState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingShuffle, .HintingShuffle(let panGR)):
            print(".HintingShuffle -> .HintingShuffle")
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingShuffle, .ReturningToRest):
            print(".HintingShuffle -> .ReturningToRest")
            returnHintingShuffleIconToRestingLocation()
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.HintingShuffle, .HintingEdit(let panGR)):
            print(".HintingSettings -> .HintingShuffle")
            returnHintingShuffleIconToRestingLocation()
            displayHintingIconViewForState(toState)
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
            
        // .HintingEdit cases
            
        case (.TrackingPan, .HintingEdit(let panGR)):
            print(".TrackingPan -> .HintingEdit")
            displayHintingIconViewForState(toState)
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .HintingEdit(let panGR)):
            print(".HintingEdit -> .HintingEdit")
            updateHintingEditIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
        case (.HintingEdit, .ReturningToRest):
            print(".HintingEdit -> .ReturningToRest")
            returnHintingEditIconToRestingLocation()
            returnCardAttachmentBehaviorToRestingLocation()
            
        case (.HintingEdit, .HintingShuffle(let panGR)):
            print(".HintingSettings -> .HintingShuffle")
            returnHintingEditIconToRestingLocation()
            displayHintingIconViewForState(toState)
            updateHintingShuffleIconPresentationWithPanGestureRecognizer(panGR)
            updateCardAttachmentBehaviorWithPanGestureRecognizer(panGR)
            
            
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
            else if attachmentAxis == .Vertical {
                if sender.translationInView(view).y >= 0 {
                    machine.state = .HintingShuffle(sender)
                }
                else if sender.translationInView(view).y < 0 {
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
    
    
    
    //
    // MARK: - UIViewController
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pulledCardView = CardView()
        pulledCardView?.annotation = dataSource.currentMantra
        view.addSubview(pulledCardView!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        pulledCardPlaceholderView.layer.cornerRadius = 3
        pulledCardPlaceholderView.clipsToBounds = true
    }
    
    func setupPulledCardBehaviors()
    {
//        NSLayoutConstraint.deactivateConstraints(
//            [pulledCardPlaceholderHeightConstraint, pulledCardPlaceholderWidthConstraint,
//                pulledCardPlaceholderCenterXConstraint, pulledCardPlaceholderCenterYConstraint])
//        pulledCardView.translatesAutoresizingMaskIntoConstraints = true
        
        guard let pulledCardView = pulledCardView else { return }
        
        pulledCardView.frame = pulledCardPlaceholderView.frame
        print(pulledCardView.frame)
        
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
        
//        let boundaryShapeLayer = CAShapeLayer()
//        boundaryShapeLayer.path = customBoundaryPath.CGPath
//        boundaryShapeLayer.fillColor = UIColor.blueColor().CGColor
//        boundaryShapeLayer.strokeColor = UIColor.orangeColor().CGColor
//        boundaryShapeLayer.frame = CGRect(
//            origin: CGPoint(
//                x: pulledCardView.bounds.width/2,
//                y: pulledCardView.bounds.height/2),
//            size: rectContainingBoundaryPath.size)
//        pulledCardView.layer.addSublayer(boundaryShapeLayer)
        
        let laneCornerRadius: CGFloat = 5
        let boundaryCollisionBehavior = UICollisionBehavior(items: [pulledCardView])
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
        
        pulledCardDynamicItemBehavior = UIDynamicItemBehavior(items: [pulledCardView])
        pulledCardDynamicItemBehavior.allowsRotation = false
        pulledCardDynamicItemBehavior.friction = 0
        pulledCardDynamicItemBehavior.resistance = 10.0
        pulledCardDynamicItemBehavior.elasticity = 0
        animator.addBehavior(pulledCardDynamicItemBehavior)
        
        pulledCardRestingAnchorLocation = pulledCardView.center
        
        pulledCardAttachmentBehavior = UIAttachmentBehavior(
            item: pulledCardView,
            attachedToAnchor: pulledCardRestingAnchorLocation)
        pulledCardAttachmentBehavior?.length = 0
        animator.addBehavior(pulledCardAttachmentBehavior!)
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
    
    func setupHintingShuffleIconBehaviors()
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
    
    func setupHintingEditIconBehaviors()
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
    
    override func viewDidLayoutSubviews()
    {
        if animator.behaviors.count == 0
        {
            setupPulledCardBehaviors()
            setupHintingSettingsIconBehaviors()
            setupHintingDeleteIconBehaviors()
            setupHintingShuffleIconBehaviors()
            setupHintingEditIconBehaviors()
        }
    }
}
