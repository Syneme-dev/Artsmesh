//
//  AMRouteViewController.m
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMRouteViewController.h"

@interface AMRouteViewController ()

@end

@implementation AMRouteViewController

- (BOOL)routeView:(AMRouteView *)routeView
shouldConnectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2
{
    return YES;
}

- (BOOL)routeView:(AMRouteView *)routeView
   connectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2
{
    return YES;
}

- (BOOL)routeView:(AMRouteView *)routeView
shouldDisonnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2
{
    return YES;
}

- (BOOL)routeView:(AMRouteView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2
{
    return YES;
}

- (BOOL)routeView:(AMRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
{
    return YES;
}

- (BOOL)routeView:(AMRouteView *)routeView
     removeDevice:(NSString *)deviceID
{
    return YES;
}

@end
