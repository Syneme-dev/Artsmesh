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
    NSMutableArray*         _videoDevices;
    AMVideoDevice*          _myselfDevice;
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
    if(_configController.videoConfig.myself == nil)
        return NO;
    
    //NSString* myselfIP  = _configController.videoConfig.myself.privateIp;
    
    NSString* peerIPPort  = [NSString stringWithFormat:@"%@:%d",
                             _configController.videoConfig.peerIP,
                             _configController.videoConfig.peerPort];
    
    for( AMVideoDevice* device in _videoDevices){
        if ([device.deviceID isEqualToString:peerIPPort]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Already have the ip:port" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please with different port"];
            [alert runModal];
        
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2
{
    AMChannel* peerChannel = [channel1.deviceID isEqualToString:@"MYSELF"] ? channel2 : channel1;
    
//   [_videoChannels removeObject:peerChannel];

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
    _videoChannels = [[NSMutableArray alloc] init];
    _videoDevices  = [[NSMutableArray alloc] init];
    _myselfDevice  = [[AMVideoDevice  alloc] init];
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
    
   // [self reloadVideoChannel:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadVideoChannel:)
                                                 name:AMVideoDeviceNotification
                                               object:nil];
}

-(void)refreshDevices
{
    //if([self.jacktripManager.jackTripInstances count] != 0){
   //     [self reloadVideoChannel:nil];
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
   
   
    AMVideoDevice* peerDevice  = nil;
    
    int firstIndex = [self findFirstIndex];
    
    //No myself channel
    
    AMChannel* myChannel = [[AMChannel alloc] init];
    myChannel.type = isSender ? AMSourceChannel : AMDestinationChannel;
    myChannel.deviceID     = @"MYSELF";
    myChannel.channelName  = @"MYSELF";
    myChannel.index = (firstIndex - START_INDEX) / INDEX_INTERVAL;
        
    NSMutableArray* channels = [[NSMutableArray alloc] init];
    [channels addObject:myChannel];
    [channels addObject:myChannel];
    [channels addObject:myChannel];
    [channels addObject:myChannel];
    [channels addObject:myChannel];
    [channels addObject:myChannel];
        
    
        
        [routeView associateChannels:channels
                          withDevice:myChannel.deviceID
                                name:myChannel.channelName
                           removable:YES];
    
    
    

    
    peerDevice = [[AMVideoDevice alloc] init];
    peerDevice.index =firstIndex;
    peerDevice.deviceID = peerIPPort;
    
    AMChannel* peerChannel = [[AMChannel alloc] init];
    peerChannel.type = isSender ?  AMDestinationChannel : AMSourceChannel;
    peerChannel.deviceID     = peerIP;
    peerChannel.channelName  = peerIPPort;
    peerChannel.index = firstIndex;
    [_videoChannels addObject:peerChannel];
        
    NSMutableArray* peerChannels = [[NSMutableArray alloc] init];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    
    peerDevice.channels = peerChannels;
    
    [_videoDevices addObject:peerDevice];
    
    [routeView associateChannels:peerChannels
                      withDevice:peerChannel.deviceID
                            name:peerChannel.channelName
                       removable:YES];
    

    [routeView connectChannel:myChannel toChannel:peerChannel];
}


-(int) findFirstIndex
{
    BOOL find;
    
    for (int index = START_INDEX; index <= LAST_INDEX; index += INDEX_INTERVAL) {
        find = NO;
        for (AMVideoDevice* device in _videoDevices) {
            if (device.index == index) {
                find = YES;
                break;
            }
        }
        if (find == NO) {
            return index;
        }
    }
    
    return -1;
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
