//
//  AMSyphonRouterViewController.m
//
//  Created by Whisky on 11/11/16.
//  Copyright (c) 2016 AM. All rights reserved.
//



#import "AMChannel.h"
#import "AMSyphonRouterViewController.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMVideoDeviceManager.h"
#import "AMSyphonUtility.h"
#import "AMSyphonClientsManager.h"
#import "AMSyphonCommon.h"



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
    //Check connection condition
    NSUInteger clientIndex = [_clientChannels indexOfObject:channel1];
    if(clientIndex == NSNotFound)
        return NO;
    
    NSArray* serverChannels = [_serverNamesChannels objectForKey:channel2.deviceID];
    if(serverChannels == nil)
        return NO;
    
    NSUInteger serverIndex = [serverChannels indexOfObject:channel2];
    if(serverIndex == NSNotFound)
        return NO;
    
    if(clientIndex != serverIndex)
        return NO;
    
    
    int oldServerIndex =(int)[channel1.peerIndexes firstIndex];
    
    
    //Remove existing connection, if there is any.
    if(oldServerIndex >= 0){
        AMSyphonRouterView* syphonView = (AMSyphonRouterView*)routeView;
        AMChannel* oldServerChannel = [syphonView channelAtIndex:oldServerIndex];
        [syphonView disconnectChannel:channel1 fromChannel:oldServerChannel];
    }
    
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
    if(_clientChannels == nil)
        return NO;
    
    NSUInteger index = [_clientChannels indexOfObject:channel1];
    if(index == NSNotFound)
        return NO;
    
    NSDictionary* userInfo = [[NSDictionary alloc]
                                initWithObjectsAndKeys:
                                    [NSNumber numberWithUnsignedInteger:index], @"INDEX",
                                            nil];
    NSNotification* notif = [[NSNotification alloc] initWithName:AMSyphonRouterDisconnected
                                                          object:nil
                                                        userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotification:notif];
    
    return YES;
}



- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
{
    return NO;
}

- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeAllDevice:(BOOL)check
{
    return NO;
}


- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeDevice:(NSString *)deviceID
{
    return NO;
}

-(void)awakeFromNib
{
    _syphonServers = [[AMVideoDeviceManager alloc] init];
    _clientChannels = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(syphonClientChanged)
               name:AMSyphonMixerClientChanged
             object:nil];
    
    [[SyphonServerDirectory sharedDirectory] addObserver:self
                                              forKeyPath:@"servers"
                                                 options:NSKeyValueObservingOptionNew
                                                 context:nil];
    
    AMSyphonRouterView* view = (AMSyphonRouterView*)self.view;
    view.delegate = self;
    
    // Add clients channel first
    for(int i = 0; i < 5; i++){
        
        AMChannel* clientChannel    = [[AMChannel alloc] init];
        clientChannel.index         = i;
        clientChannel.deviceID      = @"SYPHON-CLIENTS";
        clientChannel.channelName   = @"SYPHON-CLIENTS";
        clientChannel.type          = AMSourceChannel;
        
        [_clientChannels addObject:clientChannel];
    }
    [view associateChannels:_clientChannels
                      withDevice:@"AM-SYPHON"
                            name:@"AM-SYPHON"
                       removable:NO];
    
    [self refreshSyphonServers];

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
     AMSyphonRouterView* routeView = (AMSyphonRouterView*)self.view;
    int interval = 5;
    
    _serverNamesChannels = [[NSMutableDictionary alloc] initWithCapacity:syphonServerCount];
    _serverNames         = [[NSMutableArray      alloc] initWithCapacity:syphonServerCount];
    
    
    //1st step: Remove deleted devices from device manager.
    [routeView removeALLDevice];
    
    //2nd step: Add all syphon servers.
    [AMSyphonUtility getSyphonDeviceList:_serverNames];
    
    for(NSUInteger i = 0; i < [_serverNames count]; i++) {
        NSMutableArray *channels = [[NSMutableArray alloc] initWithCapacity:interval];
        
        NSString* syphonName = [_serverNames objectAtIndex:i];
        
        NSUInteger channelIndex = START_INDEX + i* interval;
        
        for(NSUInteger j = 0; j < interval; j++) {
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
    
   // _clientChannels = [[NSMutableArray alloc] initWithCapacity:5];
    
    //SELF Area of placeholder.
    for(int i = 0; i < [_selectedNamesByClients count]; i++){
        
        AMChannel* clientChannel  = [[AMChannel alloc] init];
        clientChannel.index       = i;
        
        NSString* serverName = [_selectedNamesByClients objectAtIndex:i];
        /*if([serverName isEqualToString:@""]){
            clientChannel.deviceID     = @"";
            clientChannel.channelName  = @"";
        }
        else*/
        if(![serverName isEqualToString:@""])
        {
            clientChannel.deviceID     = serverName;
            clientChannel.channelName  = serverName;
            clientChannel.type         = AMSourceChannel;
            [_clientChannels replaceObjectAtIndex:i withObject:clientChannel];
        }
        
        //[_clientChannels addObject:clientChannel];
        
    }
    
    [routeView associateChannels:_clientChannels
                      withDevice:@"AM-SYPHON"
                            name:@"AM-SYPHON"
                       removable:NO];

    [self clientsConnectServers];
}

-(void) getServerChannel:(NSString*) serverName
{
   
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
