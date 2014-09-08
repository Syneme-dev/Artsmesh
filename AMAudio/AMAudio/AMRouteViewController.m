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

@interface AMRouteViewController ()  <NSPopoverDelegate>

@property NSPopover *myPopover;

@end

@implementation AMRouteViewController
{
    AMJackClient* _jackClient;
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
     name:JACKTRIP_CHANGED_NOTIFICATION
     object:nil];
    
    _jackClient = [[AMJackClient alloc] init];
}

-(void)dealloc
{
    if (_jackClient) {
        [_jackClient closeJackClient];
    }
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}

-(void)reloadAudioChannel:(NSNotification*)notify
{
    if(_jackClient.isOpen == NO){
        if (![_jackClient openJackClient]) {
            NSException* exp = [[NSException alloc] initWithName:@"OpenJackClientFailed!" reason:@"" userInfo:nil];
            [exp raise];
        }
    }
    
    NSArray* srcPorts = [_jackClient sourcePorts];
    NSArray* desPorts = [_jackClient destinationPorts];
    
    NSMutableDictionary* jackDevices = [[NSMutableDictionary alloc] init];
    for (NSString* channelName in srcPorts) {
        NSArray* channelNameParts = [channelName componentsSeparatedByString:@":"];
        if ([channelNameParts count] != 2) {
            continue;
        }
        
        NSString* jackDevName = channelNameParts [0];
        AMJackDevice* jackDevice;
        jackDevice = [jackDevices objectForKey:jackDevName];
        if (jackDevice == nil) {
            jackDevice = [[AMJackDevice alloc] init];
            jackDevice.srcChans = [[NSMutableArray alloc] init];
            jackDevice.desChans = [[NSMutableArray alloc] init];
            jackDevice.deviceID = jackDevName;
            jackDevice.deviceName = jackDevName;
        }
        
        AMChannel* chann = [[AMChannel alloc] init];
        chann.type = AMSourceChannel;
        chann.channelName = channelNameParts[1];
        chann.deviceID = channelNameParts [0];
        [jackDevice.srcChans addObject:chann];
        
        jackDevices[jackDevName] = jackDevice;
    }
    
    for (NSString* channelName in desPorts) {
        NSArray* channelNameParts = [channelName componentsSeparatedByString:@":"];
        if ([channelNameParts count] != 2) {
            continue;
        }
        
        NSString* jackDevName = channelNameParts [0];
        AMJackDevice* jackDevice;
        jackDevice = [jackDevices objectForKey:jackDevName];
        if (jackDevice == nil) {
            jackDevice = [[AMJackDevice alloc] init];
            jackDevice.srcChans = [[NSMutableArray alloc] init];
            jackDevice.desChans = [[NSMutableArray alloc] init];
            jackDevice.deviceID = jackDevName;
            jackDevice.deviceName = jackDevName;
        }
        
        AMChannel* chann = [[AMChannel alloc] init];
        chann.type = AMDestinationChannel;
        chann.channelName = channelNameParts[1];
        chann.deviceID = channelNameParts [0];
        [jackDevice.desChans addObject:chann];
        
        jackDevices[jackDevName] = jackDevice;
    }
    
    for (NSString* name in jackDevices) {
        AMJackDevice* device = jackDevices[name];
        [device addDeviceToRouteView:(AMRouteView*)self.view];
    }
    
    [self.view setNeedsDisplay:YES];
}

- (IBAction)startJackTrip:(NSButton *)sender
{
    if (self.myPopover == nil) {
        self.myPopover = [[NSPopover alloc] init];
        
        self.myPopover.animates = YES;
        self.myPopover.behavior = NSPopoverBehaviorTransient;
        self.myPopover.appearance = NSPopoverAppearanceHUD;
        self.myPopover.delegate = self;
    }
    
    NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
    self.myPopover.contentViewController = [[AMJackTripConfigController alloc] initWithNibName:@"AMJackTripConfigController" bundle:myBundle];
    [self.myPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}


- (void)popoverWillShow:(NSNotification *)notification
{
    
}

-(void)popoverDidClose:(NSNotification *)notification
{

}

@end
