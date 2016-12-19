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
    NSMutableArray*         _serverNames;
    NSMutableArray*         _selectedNamesByClients;
    NSMutableDictionary*    _serverNamesChannels;
    NSMutableArray*         _clientChannels;
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
    _serverNamesChannels = [[NSMutableDictionary alloc] initWithCapacity:syphonServerCount];
    
    int interval = 5;
    _serverNames = [[NSMutableArray alloc] initWithCapacity:syphonServerCount];
    [AMSyphonUtility getSyphonDeviceList:_serverNames];
    
    AMSyphonRouterView* routeView = (AMSyphonRouterView*)self.view;
    
    //1st step: Remove deleted devices from device manager.
    [routeView removeALLDevice];
    [_serverNamesChannels removeAllObjects];
    
    
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
                            removable:NO];
        
        //???
        [_serverNamesChannels setObject:channels forKey:syphonName];
    }
    
    [self syphonClientChanged];
}


-(void) syphonClientChanged
{
    AMSyphonRouterView* routeView = (AMSyphonRouterView*)self.view;
    
    // step: add clients and add connections.
    _selectedNamesByClients = [[NSMutableArray alloc] initWithCapacity:10];
    [AMSyphonClientsManager selectedSyphonServerNames:_selectedNamesByClients];
    
    _clientChannels = [[NSMutableArray alloc] initWithCapacity:5];
    
    //SELF Area of placeholder.
    for(int i = 0; i < [_selectedNamesByClients count]; i++){
        
        AMChannel* clientChannel  = [[AMChannel alloc] init];
        clientChannel.index       = i;
        
        NSString* serverName = [_selectedNamesByClients objectAtIndex:i];
        if([serverName isEqualToString:@""]){
            clientChannel.deviceID     = @"";
            clientChannel.channelName  = @"";
        }
        else{
            clientChannel.deviceID     = serverName;
            clientChannel.channelName  = serverName;
            clientChannel.type         = AMSourceChannel;
        }
        
        [_clientChannels addObject:clientChannel];
    }
    
    [routeView associateChannels:_clientChannels
                      withDevice:@"Mixer Channel"
                            name:@"Mixer Channel"
                       removable:NO];

    [self clientsConnectServers];
}


-(void) clientsConnectServers
{
    if(_selectedNamesByClients == nil || _serverNamesChannels == nil)
        return;
    
    AMSyphonRouterView* routeView = (AMSyphonRouterView*)self.view;
    
    for (int i = 0; i < [_clientChannels count]; i++) {
        AMChannel* clientChannel = [_clientChannels objectAtIndex:i];
        
        NSString* serverName = clientChannel.deviceID;
        NSArray* serverChannels = [_serverNamesChannels objectForKey:serverName];
        if(clientChannel != nil || serverChannels != nil){
            if(i >= [serverChannels count])
                continue;
            AMChannel* serverChannel = [serverChannels objectAtIndex:i];
            if(serverChannel != nil){
                [routeView connectChannel:clientChannel toChannel:serverChannel];
            }
        }
    }
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
