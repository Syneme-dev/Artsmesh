//
//  AMRouteViewController.m
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMRouteViewController.h"
#import "AMJackTripConfigController.h"
#import "AMJackTripConfig.h"
#import "AMChannel.h"
#import "AMJackDevice.h"
#import "AMRouteView.h"
#import "AMAudio.h"


@interface AMWindow : NSWindow

@end

@implementation AMWindow

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end



@interface AMRouteViewController ()  <NSPopoverDelegate>

@property NSPopover *myPopover;

@end



@implementation AMRouteViewController
{
    NSTimer*    _deviceTimer;
    AMWindow*   _configWindow;
    
    AMJackTripConfig* _configController;
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
    
    return [[[AMAudio sharedInstance] audioJackClient] connectSrc:srcChannName toDest:destChannName];
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
    
    return [[[AMAudio sharedInstance] audioJackClient] disconnectChannel:srcChannName fromDest:destChannName];
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
    [[[AMAudio sharedInstance] audioJacktripManager] stopJacktripByName:deviceID];
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
    
    
    [self initJackTripConfig];
}

- (void) initJackTripConfig
{
    _configController = [[AMJackTripConfig alloc] initWithWindowNibName:@"AMJackTripConfig"];
    
    
    _configController.window.styleMask = NSBorderlessWindowMask;
    _configController.window.level = NSNormalWindowLevel;
    _configController.window.hasShadow = YES;
    _configController.window.backgroundColor = [NSColor colorWithCalibratedRed:38.0/255
                                                                         green:38.0/255
                                                                          blue:38.0/255
                                                                         alpha:1];
    
    _configController.window.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
}

-(void)refreshDevices
{
    //if([self.jacktripManager.jackTripInstances count] != 0){
        [self reloadAudioChannel:nil];
    //}
}

-(void)jackStarted:(NSNotification*)notification
{
    [[[AMAudio sharedInstance] audioJackClient] openJackClient];
    [self reloadAudioChannel:nil];
}

-(void)jackStopped:(NSNotification*)notification
{
    AMRouteView* routerView = (AMRouteView*)self.view;
    [routerView removeALLDevice];
    
    [[[AMAudio sharedInstance] audioJacktripManager] stopAllJacktrips];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}


-(void)reloadAudioChannel:(NSNotification*)notify
{
    if (![[[AMAudio sharedInstance] audioJackClient] isOpen]) {
        return;
    }
    
    AMRouteView* routeView = (AMRouteView*)self.view;
    
    //Read all channels from system
    NSArray* allChann = [[[AMAudio sharedInstance] audioJackClient] allChannels];
    
    //Remove device not exist any more
    NSMutableArray* toRemoveDevices = [[NSMutableArray alloc] init];
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
            
            if (![toRemoveDevices containsObject:channShow.deviceID]) {
                [toRemoveDevices addObject:channShow.deviceID];
            }
        }
    }
    
    for (NSString* devId in toRemoveDevices ) {
        [routeView removeDevice:devId];
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
        for (int i = 0; i < [[[AMAudio sharedInstance] audioJacktripManager].jackTripInstances count]; i++) {
            AMJacktripInstance* jacktrip = [[AMAudio sharedInstance] audioJacktripManager].jackTripInstances[i];
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
        NSArray* conns = [[[AMAudio sharedInstance] audioJackClient] connectionForPort:fullName];
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
    if ([[AMAudio sharedInstance] audioJackManager].jackState == JackState_Stopped) {
        
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
    
    NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
    AMJackTripConfigController* controller = [[AMJackTripConfigController alloc] initWithNibName:@"AMJackTripConfigController" bundle:myBundle];
    
    AMRouteView* routerView = (AMRouteView*)self.view;
    controller.maxChannels = (int)[[routerView allChannels] count];
    self.myPopover.contentViewController = controller;
//    controller.owner = self.myPopover;

   
    
//    _configWindow.contentView = controller.view;
        [_configController showWindow:self];
/*
    NSRect rect = [sender bounds];
//    [self.myPopover showRelativeToRect:rect ofView:sender preferredEdge:NSMaxXEdge];
 
    //NSView* configView = controller.view;
    NSRect rectClick = [sender frame];
    
    NSPoint p = [self.view convertPoint:NSMakePoint(rectClick.origin.x + 100,
                                                    rectClick.origin.y-100)
                                 toView:nil];
    
    NSRect rectTmp = NSMakeRect(p.x, p.y, 0, 0);
    rectTmp = [self.view.window convertRectToScreen:rectTmp];
    NSPoint windowOrigin = rectTmp.origin;
    
    if (_configWindow == nil) {
        _configWindow = [[AMWindow alloc] initWithContentRect:controller.view.frame
                                                    styleMask:NSBorderlessWindowMask
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
        _configWindow.contentView = controller.view;
        _configWindow.level = NSNormalWindowLevel;
        _configWindow.hasShadow = YES;
        _configWindow.backgroundColor = [NSColor colorWithCalibratedRed:38.0/255
                                                                  green:38.0/255
                                                                   blue:38.0/255
                                                                  alpha:1];
        
        _configWindow.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
        _configWindow.delegate = self;
        [_configWindow setFrameOrigin:windowOrigin];
        
        NSSize screenSize = self.view.window.screen.frame.size;
        NSRect windowFrame = controller.view.frame;
        windowFrame.origin.x = (screenSize.width - windowFrame.size.width) / 2;
        windowFrame.origin.y = screenSize.height - windowFrame.size.height - 80;
        [_configWindow.animator setFrame:windowFrame display:NO];
        
        [_configWindow makeKeyAndOrderFront:self];
        
        controller.winOwner = _configWindow;
    }else{
      //  [_configWindow ];
    }
 */
}

@end
