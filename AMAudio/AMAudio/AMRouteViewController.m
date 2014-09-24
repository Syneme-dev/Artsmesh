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
    
    //Read all channels from system
    NSArray* allChann = [self.jackClient allChannels];
    
    //Remove device not exist any more
    for (AMChannel* channShow in [routeView allChannels])
    {
        if (channShow.type == AMPlaceholderChannel) {
            continue;
        }
        
        BOOL bFind = NO;
        for (AMChannel* channAct in allChann) {
            if ([channShow.deviceID isEqualToString:channAct.deviceID]) {
                bFind = YES;
            }
        }
        if (!bFind) {
            [routeView removeDevice:channShow.deviceID];
        }
    }
    
    //Calculate new device to add
    NSMutableDictionary* devicesToAdd = [[NSMutableDictionary alloc] init];
    for( AMChannel *channAct in allChann){
        BOOL bFind = NO;
        for (AMChannel* channShow in [routeView allChannels]){
            if (channShow.type == AMPlaceholderChannel) {
                continue;
            }
            
            if ([channAct.deviceID isEqualToString:channShow.deviceID]) {
                bFind = YES;
                break;
            }
        }
        
        if (!bFind){
            AMJackDevice* device = devicesToAdd[channAct.deviceID];
            if(device == nil){
                //if device not exsit, create one
                device = [[AMJackDevice alloc] init];
                device.deviceID = channAct.deviceID;
                device.deviceName = channAct.deviceID;
                device.channels = [[NSMutableArray alloc] init];
                
                devicesToAdd[channAct.deviceID] = device;
            }
            
            [device.channels addObject:channAct];
        }
    }
    
    //Index new device channel
    int maxIndex = 0;
    for(AMChannel* channShow in [routeView allChannels]){
        if (channShow.type == AMPlaceholderChannel) {
            continue;
        }
        
        maxIndex = (maxIndex > channShow.index) ? maxIndex : channShow.index;
    }

    int j = maxIndex + 1;
    for(NSString* deviceID in devicesToAdd){
        AMJackDevice* device = devicesToAdd[deviceID];
        [device sortChannels];
        
        for (AMChannel* chann  in device.channels) {
            chann.index = j++;
        }
        
        //add new device to router view
        BOOL removable = NO;
        for (int i = 0; i < [self.jacktripManager.jackTripInstances count]; i++) {
            AMJacktripInstance* jacktrip = self.jacktripManager.jackTripInstances[i];
            if ([jacktrip.instanceName isEqualToString:deviceID]) {
                removable = YES;
                break;
            }
        }
        
        [routeView associateChannels:device.channels
                          withDevice:device.deviceID
                                name:device.deviceName
                           removable:removable];
    }
    
    //set connections
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
