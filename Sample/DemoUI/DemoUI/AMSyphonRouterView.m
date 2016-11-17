
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

@interface AMSyphonRouterView ()
{
    NSColor *_backgroundColor;
    NSColor *_placeholderChannelColor;
    NSColor *_deviceLableColor;
    NSColor *_deviceCircleColor;
    NSColor *_sourceChannelColor;
    NSColor *_destinationChannelColor;
    NSColor *_selectedChannelFillColor;
    NSColor *_connectionColor;
    NSColor *_selectedConnectionColor;
    NSPoint _center;
    CGFloat _radius;
    NSMutableArray *_allChannels;
    AMChannel *_selectedChannel;
    AMChannel *_targetChannel;
    NSInteger _selectedConnection[2];
    NSMenu *_contextMenu;
}

@property(nonatomic) NSMutableDictionary *devices;

@end


@implementation AMSyphonRouterView

#pragma mark - Overridden Methods

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
