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

- (void)loadView
{
    AMRouteView *routeView = [[AMRouteView alloc] init];
    self.view = routeView;
    routeView.delegate = self;
}

@end
