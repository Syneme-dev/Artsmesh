//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesher.h"
#import "AMETCDServiceInterface.h"
#import "AMMesherPreference.h"
#import "AMLeaderElecter.h"
#import "AMETCDSyncInterface.h"


@implementation AMMesher
{
    AMLeaderElecter* _elector;
    
    NSXPCInterface* _myETCDService;
    NSXPCConnection* _myETCDServiceConnection;
    
    NSXPCInterface* _myETCDSyncService;
    NSXPCConnection* _myETCDSyncServiceConnection;
}

-(id)init
{
    if (self = [super init])
    {
        _elector = [[AMLeaderElecter alloc] init];
        [self initETCDConnection];
        [self initETDCSyncConnetion];
    }
    
    return self;
}

-(void)initETCDConnection
{
    _myETCDService= [NSXPCInterface interfaceWithProtocol:
                     @protocol(AMETCDServiceInterface)];
    
    _myETCDServiceConnection =    [[NSXPCConnection alloc]
                                   initWithServiceName:@"AM.AMETCDService"];
    
    _myETCDServiceConnection.interruptionHandler = ^{
        NSLog(@"XPC connection was interrupted.");
    };
    
    _myETCDServiceConnection.invalidationHandler = ^{
        NSLog(@"XPC connection was invalidated.");
    };
    
    _myETCDServiceConnection.remoteObjectInterface = _myETCDService;
    [_myETCDServiceConnection resume];

}

-(void)initETDCSyncConnetion
{
    _myETCDSyncService= [NSXPCInterface interfaceWithProtocol:
                     @protocol(AMETCDSyncInterface)];
    
    _myETCDSyncServiceConnection =    [[NSXPCConnection alloc]
                                   initWithServiceName:@"AM.AMETCDSyncService"];
    
    _myETCDSyncServiceConnection.interruptionHandler = ^{
        NSLog(@"XPC connection was interrupted.");
    };
    
    _myETCDSyncServiceConnection.invalidationHandler = ^{
        NSLog(@"XPC connection was invalidated.");
    };
    
    _myETCDSyncServiceConnection.remoteObjectInterface = _myETCDSyncService;
    [_myETCDSyncServiceConnection resume];
}


-(void)startLoalMesher
{
    [self startETCD];
    [_elector kickoffElectProcess];
    
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:CFBridgingRetain([_elector class])];
}

-(void)stopLocalMesher
{
    [self stopETCD];
    [_elector stopElect];
    
    [_elector removeObserver:self forKeyPath:@"state"];
}


-(void)startETCD
{
    [_myETCDServiceConnection.remoteObjectProxy startService:nil];
}

-(void)stopETCD
{
    if(_myETCDServiceConnection)
    {
        [_myETCDServiceConnection.remoteObjectProxy stopService];
    }
}

-(void)startSyncETCD
{
    [_myETCDSyncServiceConnection.remoteObjectProxy setTestIntVal:1 ];
    
    sleep(3);
   [ _myETCDSyncServiceConnection.remoteObjectProxy getTestIntVal:^(int a){
       NSLog(@"the etst state is %d", a);
   }];
}

-(void)stopSyncETCD
{
    
}


#pragma mark -
#pragma mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
        int oldState = [[change objectForKey:@"old"] intValue];
        int newState = [[change objectForKey:@"new"] intValue];
        
        NSLog(@" old state is %d", oldState);
        NSLog(@" new state is %d", newState);
        
        if(newState == 2)//JOINED
        {
            [self startSyncETCD];
        }
        else
        {
            [self stopSyncETCD];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


@end
