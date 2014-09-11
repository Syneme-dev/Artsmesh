//
//  AMRouteViewController.h
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMRouteView.h"

#define JACKTRIP_CHANGED_NOTIFICATION   @"JackTrip Changed"

@interface AMRouteViewController : NSViewController<AMRouterViewDelegate>

@end
