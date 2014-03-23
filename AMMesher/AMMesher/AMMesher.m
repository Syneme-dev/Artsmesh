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


@implementation AMMesher
{
    AMLeaderElecter* _elector;
    
    NSXPCInterface* _myETCDService;
    NSXPCConnection* _myETCDServiceConnection;
    
}

-(id)init
{
    if (self = [super init])
    {
        _elector = [[AMLeaderElecter alloc] init];
        [self initETCDConnection];
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
        
        if(newState == 2)//Published
        {
            NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
            //I'm the mesher start control service:
            //start etcd
            //
        }
        else if(newState == 4)//Joined
        {
            NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
            
            //look up how many users are there
            //if 2 start manual watch
            //if 3 tell the leader
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
