//
//  AMRouteViewController.h
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMVideoRouteView.h"

@interface AMVideoDevice : NSObject

@property NSString* deviceID;
@property NSString* deviceName;
@property NSMutableArray* channels;

-(void)sortChannels;

@end

@interface AMVideoRouteViewController : NSViewController<AMVideoRouterViewDelegate>

@end
