//
//  AMRouteViewController.h
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMVideoRouteView.h"
#import "AMChannel.h"

NSString* kAMMyself;
NSString *const AMP2PVideoReceiverChanged;

@interface AMVideoRouteViewController : NSViewController<AMRouterViewDelegate>

@end
