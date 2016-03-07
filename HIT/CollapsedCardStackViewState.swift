//
//  CollapsedCardStackViewState.swift
//  HIT
//
//  Created by Nathan Melehan on 2/21/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

enum CollapsedCardStackViewState: StateMachineDataSource
{
    case WaitingForData
    case ReloadData
    
    case NoData
    
    case ForceLayout
    
    case AtRest
    case TrackingPan(UIPanGestureRecognizer)
    case ReturningToRest
    
    case HintingEdit(UIPanGestureRecognizer)
    case ConfirmEdit(UIPanGestureRecognizer)
    
    case HintingDelete(UIPanGestureRecognizer)
    case ConfirmDelete(UIPanGestureRecognizer)
    
    // The view's state for the duration of the deletion animation.
    case ExecuteDelete
    
    case HintingSettings(UIPanGestureRecognizer)
    case ConfirmSettings(UIPanGestureRecognizer)
    
    // The view's state while the app's settings panel is being displayed.
    // The settings panel view is not part of this view. Instead, the view's
    // delegate is responsible for displaying it.
    case ExecuteSettings
    
    case HintingShuffle(UIPanGestureRecognizer)
    case ConfirmShuffle(UIPanGestureRecognizer)
    case ExecuteShuffle
    
    
    func shouldTransitionFrom(from: CollapsedCardStackViewState, to: CollapsedCardStackViewState) -> Should<CollapsedCardStackViewState>
    {
        switch (from, to)
        {
        case (_, .ReloadData):                  return .Redirect(.AtRest)
            
        case (.ExecuteSettings, .ForceLayout):
            // E.g. User rotates device while pulled card
            // is animating to settings location or while at rest
            // at the settings location
            return .Redirect(.ExecuteSettings)
            
        case (.ExecuteDelete, .ForceLayout):
            // E.g. User rotates device while pulled card
            // is animating off screen to deletion location.
            return .Redirect(.ExecuteDelete)
            
        case (_, .ForceLayout):                 return .Redirect(.AtRest)
            
        case (.ForceLayout, .ExecuteSettings):    return .Continue
        case (.ForceLayout, .ExecuteDelete):    return .Continue
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
        case (.HintingSettings,  .ConfirmSettings):    return .Continue
        case (.ConfirmSettings,  .ConfirmSettings):    return .Continue
        case (.ConfirmSettings,  .HintingSettings):    return .Continue
        case (.ConfirmSettings,  .ExecuteSettings):    return .Continue
        case (.ExecuteSettings, .ReturningToRest): return .Continue
            
            
        case (.TrackingPan,     .HintingDelete):    return .Continue
        case (.HintingDelete,   .HintingDelete):    return .Continue
            
        case (.HintingDelete,  .ConfirmDelete):    return .Continue
        case (.ConfirmDelete,  .ConfirmDelete):    return .Continue
        case (.ConfirmDelete,  .HintingDelete):    return .Continue
        case (.ConfirmDelete,  .ExecuteDelete):    return .Continue
            
        case (.ExecuteDelete,  .ReturningToRest):
            // Pulled card has animated off screen, and a
            // new card has been pulled from the stack which animates
            // into resting position.
            return .Continue
            
        case (.ExecuteDelete,  .AtRest):
            // Pulled card was animating off screen, but
            // a bounds change occurred during the animation.
            // As a result, a ForceLayout cycle was initiated,
            // and at the end a new card was pulled from the stack
            // without being animated into its resting position.
            return .Continue
            
        case (.ExecuteDelete,  .NoData):
            // Pulled card was removed from view,
            // and there were no other cards to pull from the stack.
            return .Continue
            
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