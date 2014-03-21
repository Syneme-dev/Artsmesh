//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesher.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#include <sys/socket.h>
#include <netinet/in.h>
#import "AMLocalMesherInterface.h"


@implementation AMMesher
{
    NSXPCInterface* _myLocalMesherInterface;
    NSXPCConnection* _myLocalMehserConnection;
}

-(id)init
{
    if(self = [super init])
    {
    }
    
    return self;
}


-(void)startLocalMesherService
{
    _myLocalMesherInterface= [NSXPCInterface interfaceWithProtocol:
                              @protocol(AMLocalMesherInterface)];
    
    _myLocalMehserConnection =    [[NSXPCConnection alloc]
                                   initWithServiceName:@"AM.AMLocalMesherService"];
    
    _myLocalMehserConnection.interruptionHandler = ^{
        NSLog(@"XPC connection was interrupted.");
    };
    
    _myLocalMehserConnection.invalidationHandler = ^{
        NSLog(@"XPC connection was invalidated.");
    };
    
    _myLocalMehserConnection.remoteObjectInterface = _myLocalMesherInterface;
    [_myLocalMehserConnection resume];
    
    
    [_myLocalMehserConnection.remoteObjectProxy startSvc:nil reply:^(NSString *string) {
        NSLog(@"Did receive from XPC Service: %@", string);
    }];
}



-(void)stopLocalMesherService
{
    if(_myLocalMehserConnection)
    {
        [_myLocalMehserConnection.remoteObjectProxy stopSvc];
    }
}

@end