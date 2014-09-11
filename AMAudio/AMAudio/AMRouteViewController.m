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
}

-(void)jackStarted:(NSNotification*)notification
{
    [self.jackClient openJackClient];
    [self reloadAudioChannel:nil];
}

-(void)jackStopped:(NSNotification*)notification
{
    //[self.jackClient closeJackClient];
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
        
        AMRouteView* routerView = (AMRouteView*)self.view;
        for(AMChannel* chann in routerView.allChannels){
            chann.deviceID = @"";
            chann.channelName = @"";
            chann.peerIndexes = nil;
            chann.type = AMPlaceholderChannel;
        }
        
        [self.view setNeedsDisplay:YES];
        
        return;
    }
    
    NSArray* allChann = [self.jackClient allChannels];
    if ([allChann count] > [AMRouteView maxChannels]) {
        NSException* exp = [[NSException alloc]
                            initWithName:@"TooManyChannels"
                            reason:@""
                            userInfo:nil];
        [exp raise];
    }
    
    NSMutableDictionary* devices = [[NSMutableDictionary alloc] init];
    for (NSUInteger i = 0; i < [allChann count]; i++) {
        AMChannel* chann = allChann[i];
        chann.index = i;

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
    
    for(NSString* deviceID in devices){
        AMJackDevice* device = devices[deviceID];
        AMRouteView* routeView = (AMRouteView*)self.view;
        [routeView associateChannels:device.channels
                          withDevice:device.deviceID
                                name:device.deviceName];
    }
    
    [self.view setNeedsDisplay:YES];
}

- (IBAction)startJackTrip:(NSButton *)sender
{
    if (self.jackManager == nil) {
        return;
    }
    
    if (self.jackManager.jackState == JackState_Stopped) {
        return;
    }
    
    if (self.myPopover == nil) {
        self.myPopover = [[NSPopover alloc] init];
        
        self.myPopover.animates = YES;
        self.myPopover.behavior = NSPopoverBehaviorTransient;
        self.myPopover.appearance = NSPopoverAppearanceHUD;
        self.myPopover.delegate = self;
    }
    
    self.myPopover.contentViewController =  [[AMAudio sharedInstance] getJacktripPrefUI];
    [self.myPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}


- (void)popoverWillShow:(NSNotification *)notification
{
    
}

-(void)popoverDidClose:(NSNotification *)notification
{

}

@end
