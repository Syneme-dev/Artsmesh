//
//  AMRouteViewController.m
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMRouteViewController.h"
#import "AMJackTripConfigController.h"
#import "AMJackClient.h"
#import "AMChannel.h"
#import "AMJackDevice.h"
#import "AMRouteView.h"
#import "AMAudio.h"

@interface AMRouteViewController ()  <NSPopoverDelegate>

@property NSPopover *myPopover;

@end

@implementation AMRouteViewController
{
    NSTimer* _deviceTimer;
}


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
    NSString* srcChannName;
    NSString* destChannName;
    
    if (channel1.type == AMSourceChannel) {
        srcChannName = [NSString stringWithFormat:@"%@:%@", channel1.deviceID, channel1.channelName];
        destChannName = [NSString stringWithFormat:@"%@:%@", channel2.deviceID, channel2.channelName];
    }else{
        destChannName = [NSString stringWithFormat:@"%@:%@", channel1.deviceID, channel1.channelName];
        srcChannName = [NSString stringWithFormat:@"%@:%@", channel2.deviceID, channel2.channelName];
    }
    
    return [self.jackClient connectSrc:srcChannName toDest:destChannName];
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
    NSString* srcChannName;
    NSString* destChannName;
    
    if (channel1.type == AMSourceChannel) {
        srcChannName = [NSString stringWithFormat:@"%@:%@", channel1.deviceID, channel1.channelName];
        destChannName = [NSString stringWithFormat:@"%@:%@", channel2.deviceID, channel2.channelName];
    }else{
        destChannName = [NSString stringWithFormat:@"%@:%@", channel1.deviceID, channel1.channelName];
        srcChannName = [NSString stringWithFormat:@"%@:%@", channel2.deviceID, channel2.channelName];
    }
    
    return [self.jackClient disconnectChannel:srcChannName fromDest:destChannName];
}

- (BOOL)routeView:(AMRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
{
    if ([deviceID isEqualToString:@"system"]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)routeView:(AMRouteView *)routeView
     removeDevice:(NSString *)deviceID
{
    [self.jacktripManager stopJacktripByName:deviceID];
    return YES;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(reloadAudioChannel:)
     name:AM_RELOAD_JACK_CHANNEL_NOTIFICATION
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(jackStarted:)
     name:AM_JACK_STARTED_NOTIFICATION
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(jackStopped:)
     name:AM_JACK_STOPPED_NOTIFICATION
     object:nil];
    
    AMRouteView* view = (AMRouteView*)self.view;
    view.delegate = self;
    
    [self reloadAudioChannel:nil];
    
    _deviceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refreshDevices) userInfo:nil repeats:YES];
}

-(void)refreshDevices
{
    //if([self.jacktripManager.jackTripInstances count] != 0){
        [self reloadAudioChannel:nil];
    //}
}

-(void)jackStarted:(NSNotification*)notification
{
    [self.jackClient openJackClient];
    [self reloadAudioChannel:nil];
}

-(void)jackStopped:(NSNotification*)notification
{
    AMRouteView* routerView = (AMRouteView*)self.view;
    [routerView removeALLDevice];
    
    [self.jacktripManager stopAllJacktrips];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}


-(void)reloadAudioChannel:(NSNotification*)notify
{
    if (![self.jackClient isOpen]) {
        return;
    }
    
    AMRouteView* routeView = (AMRouteView*)self.view;
    
    NSArray* allChann = [self.jackClient allChannels];
    NSMutableDictionary* devices = [[NSMutableDictionary alloc] init];
    for (NSUInteger i = 0; i < [allChann count]; i++) {
        AMChannel* chann = allChann[i];
        //chann.index = i;
        
        AMJackDevice* device = devices[chann.deviceID];
        if(device == nil){
            device = [[AMJackDevice alloc] init];
            device.deviceID = chann.deviceID;
            device.deviceName = chann.deviceID;
            device.channels = [[NSMutableArray alloc] init];
            
            devices[chann.deviceID] = device;
        }
        
        [device.channels addObject:chann];
    }
    
    
    int j = 0;
    for(NSString* deviceID in devices){
        AMJackDevice* device = devices[deviceID];
        [device sortChannels];
        
        for (AMChannel* chann  in device.channels) {
            chann.index = j++;
        }
        
        [routeView associateChannels:device.channels
                          withDevice:device.deviceID
                                name:device.deviceName
                           removable:YES];
    }
    
    NSArray* channelsOnView = [routeView allChannels];
    for (AMChannel* chann in channelsOnView) {
        NSString* fullName = [chann channelFullName];
        NSArray* conns = [self.jackClient connectionForPort:fullName];
        for (NSString* conn in conns ) {
            for (AMChannel* peerChann in channelsOnView) {
                NSString* peerFullName = [peerChann channelFullName];
                if ([conn isEqualTo:peerFullName]) {
                    [routeView connectChannel:chann toChannel:peerChann];
                }
            }
        }
    }
}

- (IBAction)startJackTrip:(NSButton *)sender
{
    if (self.jackManager == nil) {
        return;
    }
    
    if (self.jackManager.jackState == JackState_Stopped) {
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Jack is not running" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"To start jacktrip you must start JACK first!"];
        [alert runModal];
        return;
    }
    
    if (self.myPopover == nil) {
        self.myPopover = [[NSPopover alloc] init];
        
        self.myPopover.animates = YES;
        self.myPopover.behavior = NSPopoverBehaviorTransient;
        self.myPopover.appearance = NSPopoverAppearanceHUD;
        self.myPopover.delegate = self;
    }
    
    AMJackTripConfigController* controller = (AMJackTripConfigController*)[[AMAudio sharedInstance] getJacktripPrefUI];
    AMRouteView* routerView = (AMRouteView*)self.view;
    controller.maxChannels = (int)[[routerView allChannels] count];
    self.myPopover.contentViewController = controller;
    
    [self.myPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}


- (void)popoverWillShow:(NSNotification *)notification
{
    AMJackTripConfigController* controller = (AMJackTripConfigController*)self.myPopover.contentViewController;
    if (controller) {
        [controller initPortOffset];
        [controller initParameters];
    }
}

-(void)popoverDidClose:(NSNotification *)notification
{

}

@end
