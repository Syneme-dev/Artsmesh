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
#import "AMVideoRouteView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMFFmpeg.h"
#import "AMVideoDeviceManager.h"

@interface AMVideoRouteViewController ()  <NSPopoverDelegate>
@property (weak) IBOutlet NSButton *plusButton;
@end


@implementation AMVideoRouteViewController
{
    NSTimer*    _deviceTimer;
   
    AMVideoConfigWindow*    _configController;
//    NSMutableArray*         _videoChannels;
//    NSMutableArray*         _peerDevices;
//    AMVideoDevice*          _myselfDevice;
    AMVideoDeviceManager*   _videoManager;
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
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldDisonnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2
{
    if(_configController.videoConfig.myself == nil)
        return NO;
    
    NSString* peerIPPort  = [NSString stringWithFormat:@"%@:%d",
                             _configController.videoConfig.peerIP,
                             _configController.videoConfig.peerPort];
    
    for( AMVideoDevice* device in _videoManager.peerDevices){
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
    return YES;
}

- (void)stopChannelFFmpegProcess: (NSString*) processID {
    /** Kill ffmpeg connection by process id **/
    AMFFmpeg *ffmpeg = [[AMFFmpeg alloc] init];
    [ffmpeg stopFFmpegInstance:processID];
}



- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
{
    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeDevice:(NSString *)deviceID
{
     for (AMVideoDevice* device in _videoManager.peerDevices) {
        if ([device.deviceID isEqualToString:deviceID]) {
            [self stopChannelFFmpegProcess:device.processID];
            [_videoManager.peerDevices removeObject:device];
        }
        
    }
     
    return YES;
}

-(void)awakeFromNib
{
    _videoManager = [AMVideoDeviceManager sharedInstance];
    
    NSMutableArray* channels = [[NSMutableArray alloc] init];
    
    AMChannel* myChannel = [[AMChannel alloc] init];
    myChannel.deviceID     = @"MYSELF";
    myChannel.channelName  = @"MYSELF";
    
    myChannel.index = 0;
    [_videoManager.myselfDevice.channels addObject:myChannel];
    
    myChannel.index = 1;
    [_videoManager.myselfDevice.channels addObject:myChannel];
    
    myChannel.index = 2;
    [_videoManager.myselfDevice.channels addObject:myChannel];
   
    myChannel.index = 3;
    [_videoManager.myselfDevice.channels addObject:myChannel];
    
    myChannel.index = 4;
    [_videoManager.myselfDevice.channels addObject:myChannel];
    
    myChannel.index = 5;
    [_videoManager.myselfDevice.channels addObject:myChannel];
    
    myChannel.index = 6;
    [_videoManager.myselfDevice.channels addObject:myChannel];

    myChannel.index = 7;
    [_videoManager.myselfDevice.channels addObject:myChannel];
    
    myChannel.index = 8;
    [_videoManager.myselfDevice.channels addObject:myChannel];
    
  //  _videoManager.myselfDevice.channels   = channels;
    
    AMFFmpeg *ffmpegInit = [[AMFFmpeg alloc] init];
    [ffmpegInit checkExistingPIDs];
    
    AMVideoRouteView* view = (AMVideoRouteView*)self.view;
    view.delegate = self;
    
   
    
    
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

/*
 
 
 


-(void)reloadAudioChannel:(NSNotification*)notify
{
    AMVideoRouteView* routeView = (AMVideoRouteView*)self.view;
 
    if(_configController.videoConfig.myself == nil)
        return;
 
    NSString* peerIP        = _configController.videoConfig.peerIP;
    NSString* peerIPPort    = [NSString stringWithFormat:@"%@:%d",
                                                    peerIP, _configController.videoConfig.peerPort];
    BOOL      isSender      = [_configController.videoConfig.role isEqualToString:@"SENDER"];
 
 
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
*/

-(void) reloadVideoChannel:(NSNotification*) notif
{
    AMVideoRouteView* routeView = (AMVideoRouteView*)self.view;
    
    if(_configController.videoConfig.myself == nil)
        return;
    
    
    NSString* peerIP    = _configController.videoConfig.peerIP;
    NSString* peerIPPort  = [NSString stringWithFormat:@"%@:%d",
                                            peerIP, _configController.videoConfig.peerPort];
    BOOL      isSender  = [_configController.videoConfig.role isEqualToString:@"SENDER"];
   
   
    AMVideoDevice* peerDevice  = nil;
    
    int firstIndex = [self findFirstIndex];
    
    //myself channel

    AMChannel* myChannel = [[AMChannel alloc] init];
    myChannel.type = isSender ? AMSourceChannel : AMDestinationChannel;
    myChannel.deviceID     = @"MYSELF";
    myChannel.channelName  = @"MYSELF";
    myChannel.index = (firstIndex - START_INDEX) / INDEX_INTERVAL;
    [_videoManager.myselfDevice.channels replaceObjectAtIndex:myChannel.index withObject:myChannel];
        
    [routeView associateChannels:_videoManager.myselfDevice.channels
                      withDevice:myChannel.deviceID
                            name:myChannel.channelName
                       removable:YES];
    
    peerDevice = [[AMVideoDevice alloc] init];
    peerDevice.index =firstIndex;
    peerDevice.deviceID = peerIPPort;
    
    AMChannel* peerChannel = [[AMChannel alloc] init];
    peerChannel.type = isSender ?  AMDestinationChannel : AMSourceChannel;
    peerChannel.deviceID     = peerIPPort;
    peerChannel.channelName  = peerIPPort;
    peerChannel.index = firstIndex;
  //  [_videoManager.videoChannels addObject:peerChannel];
        
    NSMutableArray* peerChannels = [[NSMutableArray alloc] init];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    [peerChannels addObject:peerChannel];
    
    peerDevice.channels = peerChannels;

    /** Set processID for channel 2 **/
    NSDictionary *currStreams = [[AMPreferenceManager standardUserDefaults]
                                    objectForKey:Preference_Key_ffmpeg_Cur_P2P];

    peerDevice.processID  = [currStreams objectForKey:peerChannel.channelName];



    [_videoManager.peerDevices addObject:peerDevice];
    
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
        for (AMVideoDevice* device in _videoManager.peerDevices) {
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
