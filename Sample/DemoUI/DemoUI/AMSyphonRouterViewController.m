//
//  AMSyphonRouterViewController.m
//
//  Created by Whisky on 11/11/16.
//  Copyright (c) 2016 AM. All rights reserved.
//

#import "AMVideoRouteViewController.h"
#import "AMVideoConfigWindow.h"
#import "AMChannel.h"
#import "AMSyphonRouterViewController.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMFFmpeg.h"
#import "AMVideoDeviceManager.h"
#import "AMSyphonUtility.h"


@interface AMSyphonRouterViewController ()  <NSPopoverDelegate>
@end


@implementation AMSyphonRouterViewController
{
    NSTimer*    _timer;
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

    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2
{
    return YES;
}

- (void)stopChannelFFmpegProcess: (NSString*) processID {
    // Kill ffmpeg connection by process id
//    [_ffmpegManager stopFFmpegInstance:processID];
}

- (void)stopAllChannelProcesses {
    /** Kill all processes by process id **/
}


- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
{
    return YES;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeAllDevice:(BOOL)check
{
    return YES;
}


- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeDevice:(NSString *)deviceID
{
    return YES;
}

-(void)awakeFromNib
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                              target:self
                                            selector:@selector(refreshSyphonDevices)
                                            userInfo:nil
                                             repeats:NO];
}


-(void) refreshSyphonDevices
{
    NSArray* devices = [AMSyphonUtility getSyphonDeviceList];
    if([devices count] <= 0)
        return;
    
    AMVideoRouteView* routeView = (AMVideoRouteView*)self.view;
    
    
    for (NSUInteger i = 0; i < [devices count]; i++) {
        
        NSString* syphonName = [devices objectAtIndex:i];
        
        int channelIndex = START_INDEX + i* INDEX_INTERVAL;
      
        NSMutableArray *channels = [NSMutableArray arrayWithCapacity:2];
        for (int j = 0; j < 2; j++) {
            AMChannel *channel = [[AMChannel alloc] initWithIndex:j+channelIndex];
                channel.type =  AMSourceChannel;
                channel.deviceID     = syphonName;
                channel.channelName  = syphonName;
                channels[i] = channel;
        }
        
        [routeView associateChannels:channels
                          withDevice:syphonName
                                name:syphonName
                            removable:YES];
        
    }


}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}


@end
