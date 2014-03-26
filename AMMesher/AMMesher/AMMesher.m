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
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMETCDApi/AMETCD.h"


@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMETCD* _etcdApi;

    NSXPCInterface* _myETCDService;
    NSXPCConnection* _myETCDServiceConnection;
    
}

-(id)init
{
    if (self = [super init])
    {
        _elector = [[AMLeaderElecter alloc] init];
        _elector.mesherPort = ETCDServerPort;
        
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


-(void)startETCD:(NSDictionary*)params
{
    [_myETCDServiceConnection.remoteObjectProxy startService:params];
}

-(void)stopETCD
{
    if(_etcdApi!=nil)
    {
        [_etcdApi removePeers:[AMNetworkUtils getHostName]];
    }
    
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
            
            NSString* _peer_addr = [NSString stringWithFormat:@"%@:%d", _elector.mesherIp, _elector.mesherPort];
            NSString* _addr = [NSString stringWithFormat:@"%@:%d", _elector.mesherIp, ETCDClientPort];
    
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            
            [params setObject:_peer_addr forKey:@"-peer-addr"];
            [params setObject:_addr forKey:@"-addr"];
            
            [self startETCD:params];
            
            _etcdApi = [[AMETCD alloc]init];
            _etcdApi.serverIp = _elector.mesherIp;
            _etcdApi.clientPort = ETCDClientPort;
            _etcdApi.serverPort = _elector.mesherPort;
        }
        else if(newState == 4)//Joined
        {
            NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
            
            NSString* _peer_addr = [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], ETCDServerPort];
            NSString* _addr = [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], ETCDClientPort];
            NSString* _peers = [NSString stringWithFormat:@"%@:%d", _elector.mesherIp, _elector.mesherPort];
            
            
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            
            [params setObject:_peer_addr forKey:@"-peer-addr"];
            [params setObject:_addr forKey:@"-addr"];
            [params setObject:_peers forKey:@"-peers"];
            
            [self startETCD:params];
            
            _etcdApi = [[AMETCD alloc]init];
            _etcdApi.serverIp = [AMNetworkUtils getHostIpv4Addr];
            _etcdApi.clientPort = ETCDClientPort;
            _etcdApi.serverPort = ETCDServerPort;
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
