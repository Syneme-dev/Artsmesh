//
//  AMRouteViewController.m
//  AMAudio
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMVideoRouteViewController.h"
#import "AMVideoConfigWindow.h"
#import "AMChannel.h"
//#import "AMJackDevice.h"
#import "AMVideoRouteView.h"
//#import "AMAudio.h"


@interface AMVideoRouteViewController ()  <NSPopoverDelegate>
@property (weak) IBOutlet NSButton *plusButton;

//@property NSPopover *myPopover;

@end



@implementation AMVideoRouteViewController
{
    NSTimer*    _deviceTimer;
   
    AMVideoConfigWindow*    _configController;
    NSMutableArray*         _videoChannels;
}


- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldConnectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2
{
    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
   connectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2
{
    return YES;
    
    /*
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
     */
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldDisonnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2
{
    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2
{
    return YES;
    /*
    NSString* srcChannName;
    NSString* destChannName;
    
    if (channel1.type == AMSourceChannel) {
        srcChannName = [NSString stringWithFormat:@"%@:%@", channel1.deviceID, channel1.channelName];
        destChannName = [NSString stringWithFormat:@"%@:%@", channel2.deviceID, channel2.channelName];
    }else{
        destChannName = [NSString stringWithFormat:@"%@:%@", channel1.deviceID, channel1.channelName];
        srcChannName = [NSString stringWithFormat:@"%@:%@", channel2.deviceID, channel2.channelName];
    }
    
    return [[[AMAudio sharedInstance] audioJackClient] disconnectChannel:srcChannName fromDest:destChannName];*/
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
{
    /*
    if ([deviceID isEqualToString:@"system"]) {
        return NO;
    }*/
    
    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeDevice:(NSString *)deviceID
{
 //   [[[AMAudio sharedInstance] audioJacktripManager] stopJacktripByName:deviceID];
    return YES;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(reloadVideoChannel:)
                                        name:AMVideoDeviceNotification
                                        object:nil];
    
    _videoChannels = [[NSMutableArray alloc] init];
    /*
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
    
    
    
    _deviceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refreshDevices) userInfo:nil repeats:YES];
    
    */
    AMVideoRouteView* view = (AMVideoRouteView*)self.view;
    view.delegate = self;
    
    [self reloadVideoChannel:nil];
}

-(void)refreshDevices
{
    //if([self.jacktripManager.jackTripInstances count] != 0){
        [self reloadVideoChannel:nil];
    //}
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}

-(void) reloadVideoChannel:(NSNotification*) notif
{
    AMVideoRouteView* routeView = (AMVideoRouteView*)self.view;
    
    
}
   /*
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
    
}*/

//The commentary part is old verison of NSPopover. Somehow it doesn't work. When you select in
// the Pop-Up view, the whole NSPopover window disappear. So change it to window implentation.
- (IBAction)startJackTrip:(NSButton *)sender
{
    
    /*
    if ([[AMAudio sharedInstance] audioJackManager].jackState == JackState_Stopped) {
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Jack is not running" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"To start jacktrip you must start JACK first!"];
        [alert runModal];
        return;
    }
//    NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];

    [self initJackTripConfig];
    [_configController showWindow:self];
     */
}
- (IBAction)initVideoConfig:(id)sender {

    _configController = [[AMVideoConfigWindow alloc] initWithWindowNibName:@"AMVideoConfigWindow"];
    NSWindow* win = _configController.window;
    [win setStyleMask:NSBorderlessWindowMask];
    [win setLevel:NSFloatingWindowLevel];
    [win setHasShadow:YES];
    [win setBackgroundColor : [NSColor colorWithCalibratedRed:38.0/255
                                                        green:38.0/255
                                                         blue:38.0/255
                                                        alpha:1]];
  
    NSRect winRect   = [win frame];
    NSRect plusFrame = [_plusButton frame];
    NSPoint tmpPoint = NSMakePoint(plusFrame.origin.x + plusFrame.size.width + 20,
                                   plusFrame.origin.y - winRect.size.height + 120);
  
    winRect.origin = [self.view convertPoint:tmpPoint toView:nil];;
    [win  setFrame:winRect display:NO];
    
    AMVideoRouteView* routerView = (AMVideoRouteView*)self.view;
    _configController.maxChannels = (int)[[routerView allChannels] count];
    
    [_configController showWindow:self];
 }
@end


@implementation AMVideoDevice

-(void)sortChannels
{
    NSMutableArray* sortedChannels = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.channels count]; i++) {
        
        AMChannel* chann = self.channels[i];
        if (chann.type == AMDestinationChannel) {
            [sortedChannels addObject:chann];
        }else{
            
            BOOL bFind = NO;
            for (int j = 0; j < [sortedChannels count]; j++) {
                AMChannel* existCh = sortedChannels[j];
                if (existCh.type == AMDestinationChannel) {
                    [sortedChannels insertObject:chann atIndex:j];
                    bFind = YES;
                    break;
                }
            }
            
            if (!bFind) {
                [sortedChannels addObject:chann];
            }
        }
    }
    
    self.channels = sortedChannels;
}

@end
