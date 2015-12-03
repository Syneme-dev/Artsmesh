
//  AMVideoConfigWindow.h
//  RoutingPanel
//
//  Created by whiskyzed on 12/3/15.
//  Copyright (c) 2015 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMVideoConfig.h"

@interface AMVideoConfigWindow : NSWindowController
@property int maxChannels;
@property  AMVideoConfig*  videoConfig;

@end
