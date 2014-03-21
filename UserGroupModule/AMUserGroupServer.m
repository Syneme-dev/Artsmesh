//
//  AMUserGroupServer.m
//  UserGroupModule
//
//  Created by 王 为 on 3/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupServer.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMNetworkUtils/JSONKit.h"
#import "AMUserGroupCtrlSrvDelegate.h"
#import "AMUserGroupDataDeletage.h"
#import "AMUserGroupModel.h"

@implementation AMUserGroupServer
{
    GCDAsyncUdpSocket *listenSocket;
    BOOL isRunning;
}

-(id)init
{
    if(self = [super init])
    {
        isRunning = NO;
        self.listenPort = 7001;
    }
    
    return self;
}

-(void)createSocket:(AMUserGroupCtrlSrvDelegate*) ctrlDel
   withDataDeletage:(AMUserGroupDataDeletage*)dataDel
{
    listenSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:ctrlDel delegateQueue:dispatch_get_main_queue()];
    
    dataSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:dataDel delegateQueue:dispatch_get_main_queue()];
}

-(BOOL)startServer
{
    if(![self startCtrlServer])
    {
        return NO;
    }
    
    if([self startDataServer])
    {
        return NO;
    }
    
    return YES;
}

-(void)stopServer
{
    [self stopCtrlServer];
    [self stopDataServer];
}

-(BOOL)startCtrlServer
{
    if(isCtrlSrvRunning)
    {
        return YES;
    }
    
    NSError *error = nil;
    
    if (![listenSocket bindToPort:self.listenPort error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return NO;
    }
    if (![listenSocket beginReceiving:&error])
    {
        [listenSocket close];
        
        NSLog(@"Error starting server (recv): %@", error);
        return NO;
    }
    
    NSLog(@"Udp Echo server started on port %hu", [listenSocket localPort]);
    isCtrlSrvRunning = YES;
    
    return YES;
}


-(void)stopCtrlServer
{
    [listenSocket close];
    
    NSLog(@"Stopped Ctrl server");
    isCtrlSrvRunning = NO;
    
    listenSocket = nil;
}


-(BOOL)startDataServer
{
    if(isCtrlSrvRunning)
    {
        return YES;
    }
    
    NSError *error = nil;
    
    if (![dataSocket bindToPort:self.listenPort error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return NO;
    }
    if (![dataSocket beginReceiving:&error])
    {
        [dataSocket close];
        
        NSLog(@"Error starting server (recv): %@", error);
        return NO;
    }
    
    NSLog(@"Udp Echo server started on port %hu", [dataSocket localPort]);
    isCtrlSrvRunning = YES;
    
    return YES;
}

-(void)stopDataServer
{
    [dataSocket close];
    
    NSLog(@"Stopped Data server");
    isDataSrvRunning = NO;
    
    dataSocket = nil;
}


-(void)sendCtrlData:(NSData*)data toAddress:address
{
    [listenSocket sendData:data toAddress:address withTimeout:-1 tag:0];
}


@end
