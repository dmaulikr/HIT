//
//  HIT-Bridging-Header.h
//  HIT
//
//  Created by Nathan Melehan on 12/25/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//
//  Abstract:
//  Bridging header, used to expose UIDynamicAnimator's private debug interface in Swift.


@import UIKit;

#import "TLLayoutTransitioning.h"

#if DEBUG

@interface UIDynamicAnimator (AAPLDebugInterfaceOnly)

/// Use this property for debug purposes when testing.
@property (nonatomic, getter=isDebugEnabled) BOOL debugEnabled;

@end

#endif
