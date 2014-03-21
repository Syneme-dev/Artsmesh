//
//  AMUserGroupServer.m
//  UserGroupModule
//
//  Created by 王 为 on 3/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupServer.h"
#import "AMUser.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMUserGroupCtrlSrvDelegate.h"
#import "AMUserGroupDataDeletage.h"

@implementation AMUserGroupServer
{
    GCDAsyncUdpSocket *ctrlSocket;
    GCDAsyncUdpSocket *dataSocket;
    
    BOOL isCtrlSrvRunning;
    BOOL isDataSrvRunning;
    AMUserGroupCtrlSrvDelegate* ctrlDelegate;
    AMUserGroupDataDeletage* dataDelegate;
    
}

-(id)init
{
    if(self = [super init])
    {
        isCtrlSrvRunning = NO;
        isDataSrvRunning = NO;
        self.myself = [[NSMutableDictionary alloc] init];
        self.groups = [[NSMutableDictionary alloc] init];
        self.users = [[NSMutableDictionary alloc] init];
        self.ctrlPort = 7001;
        self.dataPort = 4001;
        ctrlDelegate = [[AMUserGroupCtrlSrvDelegate alloc] initWithDataSource:self];
        dataDelegate = [[AMUserGroupDataDeletage alloc] initWithDataSource:self];
        ctrlSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:ctrlDelegate delegateQueue:dispatch_get_main_queue()];
        dataSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:dataDelegate delegateQueue:dispatch_get_main_queue()];
    }
    
    return self;
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
    
    [self.users removeAllObjects];
    [self.groups removeAllObjects];
}

-(BOOL)startCtrlServer
{
    if(isCtrlSrvRunning)
    {
        return YES;
    }
    
    NSError *error = nil;
    
    if (![ctrlSocket bindToPort:self.ctrlPort error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return NO;
    }
    if (![ctrlSocket beginReceiving:&error])
    {
        [ctrlSocket close];
        
        NSLog(@"Error starting server (recv): %@", error);
        return NO;
    }
    
    NSLog(@"Udp Echo server started on port %hu", [ctrlSocket localPort]);
    isCtrlSrvRunning = YES;
    
    return YES;
}


-(void)stopCtrlServer
{
    [ctrlSocket close];
    
    NSLog(@"Stopped Ctrl server");
    isCtrlSrvRunning = NO;
    
    ctrlSocket = nil;
}


-(BOOL)startDataServer
{
    if(isCtrlSrvRunning)
    {
        return YES;
    }
    
    NSError *error = nil;
    
    if (![dataSocket bindToPort:self.ctrlPort error:&error])
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
    [ctrlSocket sendData:data toAddress:address withTimeout:-1 tag:0];
}


@end
