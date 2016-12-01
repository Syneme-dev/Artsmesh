
//
//  AMRouteView.m
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//


#import "AMSyphonRouterViewController.h"
#import "AMChannel.h"
#import "AMSyphonRouterView.h"
#import "NSBezierPath+QuartzUtilities.h"
#import "AMVideoRouteView.h"




@implementation AMSyphonRouterView

#pragma mark - Overridden Methods

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
