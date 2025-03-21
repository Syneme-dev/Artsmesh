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

NSString* kAMMyself = @"MYSELF";
NSString *const AMP2PVideoReceiverChanged = @"AMP2PVideoReceiverChanged";
NSString *ytAddr = @"rtmp://a.rtmp.youtube.com/live2";

@interface AMVideoRouteViewController ()  <NSPopoverDelegate>
@property (weak) IBOutlet NSButton *plusButton;
@end


@implementation AMVideoRouteViewController
{
    AMVideoConfigWindow*    _configController;
    AMVideoDeviceManager*   _videoManager;
    AMFFmpeg*               _ffmpegManager;
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
    [_ffmpegManager stopFFmpegInstance:processID];
}

- (void)stopAllChannelProcesses {
    /** Kill all processes by process id **/
    NSMutableArray* processes = [[NSMutableArray alloc] init];
    for (AMVideoDevice* device in _videoManager.peerDevices) {
        [processes addObject:device.processID];
    }
    
    [_ffmpegManager stopAllFFmpegInstances:processes];
    [_videoManager.peerDevices removeAllObjects];
}


- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
{
    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeAllDevice:(BOOL)check
{
    [self stopAllChannelProcesses];
    
    BOOL hasReceiver = NO;
    for (AMVideoDevice* device in _videoManager.peerDevices) {
        if ([device.role isEqualToString:kReceiverRole] ||
            [device.role isEqualToString:kDualRole]){
                hasReceiver = YES;
        }
       
    }
    if (hasReceiver) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AMP2PVideoReceiverChanged object:nil];
    }
    
    return YES;
}


- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeDevice:(NSString *)deviceID
{
    BOOL hasReceiver = NO;
    BOOL isYouTube = NO;
    for (AMVideoDevice* device in _videoManager.peerDevices) {
        if ([device.deviceID isEqualToString:deviceID]) {
            if ([device.processID length] != 0) {
                if ([device.role isEqualToString:kReceiverRole] ||
                    [device.role isEqualToString:kDualRole]){
                    hasReceiver = YES;
                }
                [self stopChannelFFmpegProcess:device.processID];
                [_videoManager.peerDevices removeObject:device];
            } else {
                //YouTube or (null) connection
                isYouTube = YES;
            }
            //int index = ;
        }
        
    }
    if (isYouTube) {
        [_ffmpegManager stopFFmpeg];
        [_videoManager.peerDevices removeAllObjects];
    }
    if (hasReceiver) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AMP2PVideoReceiverChanged object:nil];
    }
    return YES;
}

-(void)awakeFromNib
{
    
    _ffmpegManager = [[AMFFmpeg alloc] init];
    [_ffmpegManager checkExistingPIDs];
    
    _videoManager  = [AMVideoDeviceManager sharedInstance];
    
    
    
    AMVideoRouteView* view = (AMVideoRouteView*)self.view;
    view.delegate = self;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addVideoDevice:)
                                                 name:AMVideoDeviceNotification
                                               object:nil];
    
    [self reloadAudioChannel];
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


//1st: Rearrange _videoManager.peerDevices to represent current state of ffmpeg processes
//2nd: Find the devices which hasn't shown in UI yet.
//3rd: Show those devices.
-(void)reloadAudioChannel
{
    AMVideoRouteView* routeView = (AMVideoRouteView*)self.view;
 
    //1st step.
    
    /*
    BOOL bFind = NO;
    for(AMVideoDevice* device in _videoManager.peerDevices) {
  
        //Check whether that ffmpeg instance exists or not.
        NSString* pid = device.processID;
        [_ffmpegManager checkExistingPIDs:]
        if(){
            [_videoManager.peerDevices removeObject];
        }
        bFind = YES;
    }
    */
    
    //2nd step
    if(routeView == nil || _videoManager.peerDevices == nil || [_videoManager.peerDevices count] == 0)
        return;
   
    //Calculate new device to add
    NSMutableArray* devicesToAdd = [[NSMutableArray alloc] init];
    for(AMVideoDevice* device in _videoManager.peerDevices){
        BOOL bFind = NO;
        for (AMChannel* channShow in [routeView allChannels]){
            if (channShow.type == AMPlaceholderChannel) {
                continue;
            }
            if ([device.deviceID isEqualToString:channShow.deviceID]) {
                bFind = YES;
                break;
            }
        }
        
        if (!bFind){
            if([devicesToAdd indexOfObject:device] == NSNotFound){
                [devicesToAdd addObject:device];
            }
        }
    }
    
    //3rd step
    for (AMVideoDevice* device in devicesToAdd) {
        for (NSUInteger i = 0; i < device.validCount; i++) {
            AMChannel* peerChannel = [device.channels objectAtIndex:i];
            
            //unsigned long index = (device.index - START_INDEX) / INDEX_INTERVAL + i;
            unsigned long index = [_videoManager findFirstMyselfIndex:device];
            if (device.validCount == 2) {
                if (i == 0) {
                    index = index + 1;
                }
            }
            AMChannel* myChannel = [[AMChannel alloc] initWithIndex:index];
            myChannel.deviceID     = kAMMyself;
            myChannel.channelName  = kAMMyself;
            [_videoManager.myselfDevice.channels replaceObjectAtIndex:myChannel.index
                                                           withObject:myChannel];
            
            myChannel.type =  peerChannel.type == AMSourceChannel ?
                                                    AMDestinationChannel : AMSourceChannel;
            
            [routeView associateChannels:_videoManager.myselfDevice.channels
                              withDevice:myChannel.deviceID
                                    name:myChannel.channelName
                               removable:YES];
            
            
            [routeView associateChannels:device.channels
                              withDevice:device.deviceID
                                    name:peerChannel.channelName
                               removable:YES];
            
            
            [routeView connectChannel:myChannel toChannel:peerChannel];
        }
    }
}


-(void) addVideoDevice:(NSNotification*) notif
{
    AMVideoRouteView* routeView = (AMVideoRouteView*)self.view;
    
    if(routeView == nil || _configController.videoConfig.myself == nil)
        return;
    
    
    NSString* peerIP    = _configController.videoConfig.peerIP;
    NSString* peerIPPort  = [NSString stringWithFormat:@"%@:%d",
                                            peerIP, _configController.videoConfig.peerPort];
    NSString *peerName = [NSString stringWithFormat:@"%@", _configController.videoConfig.peerName];

    
    AMVideoDevice* peerDevice = [[AMVideoDevice alloc] init];
    
    if ([_configController.videoConfig.role isEqualToString:kDualRole]) {
        peerDevice.validCount = 2;
    }else{
        peerDevice.validCount = 1;
    }
    
    int firstIndex = [self findFirstGlobalIndex:peerDevice.validCount];
    peerDevice.index = firstIndex;
    
    peerDevice.deviceID = peerIPPort;
    peerDevice.role     = _configController.videoConfig.role;
    
    AMChannel* peerChannel = nil;
    NSMutableArray* peerChannels = [[NSMutableArray alloc] init];
    
    //In DUAL mode,peerDevice.validCount is 2, then add two channel in one device.
    for (int i = 0; i < peerDevice.validCount; i++) {
        peerChannel = [[AMChannel alloc] init];

        //Set channel type
        if ([_configController.videoConfig.role isEqualToString:kSenderRole]) {
            peerChannel.type = AMSourceChannel;
        }else if([_configController.videoConfig.role isEqualToString:kReceiverRole]){
            peerChannel.type = AMDestinationChannel;
        }else if ([_configController.videoConfig.role isEqualToString:kDualRole]){
            //In peer device, first sender, then receiver.
            if (i == 0) {
                peerChannel.type = AMSourceChannel;
            }else{
                 peerChannel.type = AMDestinationChannel;
            }
        }
        
        peerChannel.deviceID     = peerIPPort;
        //peerChannel.channelName  = peerIPPort;
        peerChannel.channelName = peerName;
        peerChannel.index = firstIndex + i;
        [peerChannels addObject:peerChannel];
        
        
    }
    
    //add pseudo channels to make enough room for displaying.
    for (NSUInteger i = peerDevice.validCount; i < INDEX_INTERVAL; i++) {
        [peerChannels addObject:peerChannel];
    }
    
    peerDevice.channels = peerChannels;

    
    [_videoManager.peerDevices addObject:peerDevice];
    if(peerDevice.validCount == 2){
        [_videoManager.peerDevices addObject:peerDevice];
    }
    
    /** Set processID for channel 2 **/
    NSDictionary *currStreams = [[AMPreferenceManager standardUserDefaults]
                                    objectForKey:Preference_Key_ffmpeg_Cur_P2P];

    peerDevice.processID  = [currStreams objectForKey:peerChannel.channelName];



    
    
    [self reloadAudioChannel];
    
    //Send notification for video mixer
    if ([peerDevice.role isEqualToString:kDualRole] ||
        [peerDevice.role isEqualToString:kReceiverRole]){
        [[NSNotificationCenter defaultCenter] postNotificationName:AMP2PVideoReceiverChanged object:nil];
    }
        
}

//Notice:Index from START_INDEX to LAST_INDEX.
-(int) findFirstGlobalIndex : (NSInteger) count
{
    BOOL find;
    
    for (int index = START_INDEX; index <= LAST_INDEX; index += INDEX_INTERVAL) {
        find = NO;
        for (AMVideoDevice* device in _videoManager.peerDevices) {
            if (count == 1 && device.index == index) {
                find = YES;
                break;
            }else if(count == 2 && (device.index == index || device.index == index+INDEX_INTERVAL)){
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
