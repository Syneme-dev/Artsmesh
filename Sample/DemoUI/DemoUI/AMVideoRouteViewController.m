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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadVideoChannel:)
                                                 name:AMVideoDeviceNotification
                                               object:nil];

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
    
    if(_configController.videoConfig.myself == nil)
        return;
    
    //NSString* myselfIP  = _configController.videoConfig.myself.privateIp;
    NSString* peerIP    = _configController.videoConfig.peerIP;
    NSString* peerPort  = [NSString stringWithFormat:@"%d",_configController.videoConfig.peerPort];
    NSString* peerIPPort  = [NSString stringWithFormat:@"%@:%d",
                                            peerIP, _configController.videoConfig.peerPort];
    BOOL      isSender  = [_configController.videoConfig.role isEqualToString:@"SENDER"];
   
    AMChannel* myChannel    = nil;
    AMChannel* peerChannel  = nil;
    
    BOOL bFind = NO;
    for( AMChannel *channel in _videoChannels){
        if ([channel.deviceID isEqualToString:@"MYSELF"]) {
            bFind = YES;
            myChannel =channel;
            break;
        }
    }
    
    //No myself channel
    if (bFind == NO) {
        myChannel = [[AMChannel alloc] init];
        myChannel.type = isSender ? AMSourceChannel : AMDestinationChannel;
        myChannel.deviceID     = @"MYSELF";
        myChannel.channelName  = @"MYSELF";
        myChannel.index = 0;
        NSMutableArray* channels = [[NSMutableArray alloc] init];
        [channels addObject:myChannel];
        [channels addObject:myChannel];
        [channels addObject:myChannel];
        [channels addObject:myChannel];
        [channels addObject:myChannel];
        [channels addObject:myChannel];
        
        [_videoChannels addObject:myChannel];
        
        [routeView associateChannels:channels
                          withDevice:myChannel.deviceID
                                name:myChannel.channelName
                           removable:YES];
    }
    
    
    bFind = NO;
    for( AMChannel *channel in _videoChannels){
        if ([channel.deviceID isEqualToString:peerIP]) {
            bFind = YES;
            peerChannel = channel;
            break;
        }
    }
    //peer channel
    if (bFind == NO) {
        peerChannel = [[AMChannel alloc] init];
        peerChannel.type = isSender ?  AMDestinationChannel : AMSourceChannel;
        peerChannel.deviceID     = peerIP;
        peerChannel.channelName  = peerIPPort;
        peerChannel.index = 18;
        [_videoChannels addObject:peerChannel];
        
        NSMutableArray* peerChannels = [[NSMutableArray alloc] init];
        [peerChannels addObject:peerChannel];
        [peerChannels addObject:peerChannel];
        [peerChannels addObject:peerChannel];
        [peerChannels addObject:peerChannel];
        [peerChannels addObject:peerChannel];
        [peerChannels addObject:peerChannel];
        
        [routeView associateChannels:peerChannels
                          withDevice:peerChannel.deviceID
                                name:peerChannel.channelName
                           removable:YES];
    }

    
    
    [routeView connectChannel:myChannel toChannel:peerChannel];
}



//The commentary part is old verison of NSPopover. Somehow it doesn't work. When you select in
// the Pop-Up view, the whole NSPopover window disappear. So change it to window implentation.
- (IBAction)startJackTrip:(NSButton *)sender
{
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
