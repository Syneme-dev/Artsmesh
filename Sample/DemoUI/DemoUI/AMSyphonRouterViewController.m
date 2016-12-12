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
#import "AMSyphonClientsManager.h"


@interface AMSyphonRouterViewController ()  <NSPopoverDelegate>
@end


@implementation AMSyphonRouterViewController
{
    AMVideoDeviceManager*   _syphonServers;
    NSTimer*    _timer;
    NSMutableArray*        _serverNames;
    NSMutableArray*        _selectedNamesByClients;
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
    _syphonServers = [[AMVideoDeviceManager alloc] init];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(syphonClientChanged)
               name:AMSyphonMixerClientChanged
             object:nil];
    
    [[SyphonServerDirectory sharedDirectory] addObserver:self
                                              forKeyPath:@"servers"
                                                 options:NSKeyValueObservingOptionNew
                                                 context:nil];
}


- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    [self refreshSyphonServers];
}

-(void) refreshSyphonServers
{
    int interval = 4;
    _serverNames = [[NSMutableArray alloc] initWithCapacity:10];
    [AMSyphonUtility getSyphonDeviceList:_serverNames];
    
    AMSyphonRouterView* routeView = (AMSyphonRouterView*)self.view;
    
    //1st step: Remove deleted devices from device manager.
    [routeView removeALLDevice];
    
    
    //2nd step: Add all syphon servers.
    for (NSUInteger i = 0; i < [_serverNames count]; i++) {
        NSMutableArray *channels = [[NSMutableArray alloc] initWithCapacity:interval];
        
        NSString* syphonName = [_serverNames objectAtIndex:i];
        
        int channelIndex = START_INDEX + i* interval;
        
        for (int j = 0; j < interval; j++) {
            AMChannel *channel = [[AMChannel alloc] initWithIndex:j+channelIndex];
                channel.type    =  AMDestinationChannel;
                channel.deviceID     = syphonName;
                channel.channelName  = syphonName;
                channels[j] = channel;
        }
        
        [routeView associateChannels:channels
                          withDevice:syphonName
                                name:syphonName
                            removable:YES];
    }
    
    
    //3rd step: add clients and add connections.
    _selectedNamesByClients = [[NSMutableArray alloc] initWithCapacity:10];
    [AMSyphonClientsManager selectedSyphonServerNames:_selectedNamesByClients];
    
    
    //4th step:
    
}


-(void) syphonClientChanged
{
    
 
    
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}


@end
