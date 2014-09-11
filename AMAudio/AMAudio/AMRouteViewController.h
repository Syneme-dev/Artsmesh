//
//  AMRouteViewController.h
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMRouteView.h"
#import "AMJackClient.h"
#import "AMJackManager.h"
#import "AMJackTripManager.h"

@interface AMRouteViewController : NSViewController<AMRouterViewDelegate>

@property (weak)AMJackClient* jackClient;
@property (weak)AMJackManager* jackManager;
@property (weak)AMJackTripManager* jacktripManager;

@end
