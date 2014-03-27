//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesher.h""
#import "AMMesherPreference.h"
#import "AMETCDServiceInterface.h"
#import "AMLeaderElecter.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMETCDApi/AMETCD.h"


@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMETCD* _etcdApi;
    BOOL _isETCDInit;
    NSTimer* _heartbeatTimer;

    NSXPCInterface* _myETCDService;
    NSXPCConnection* _myETCDServiceConnection;
    
}

dispatch_queue_t _mesher_serial_queue = NULL;

+(dispatch_queue_t) mesher_serial_queue
{
    if(_mesher_serial_queue == NULL)
    {
        _mesher_serial_queue = dispatch_queue_create("mesher_queue", NULL);
    }
    
    return _mesher_serial_queue;
}

-(id)init
{
    if (self = [super init])
    {
        _isETCDInit =NO;
        
        //Init Mesher Elector
        _elector = [[AMLeaderElecter alloc] init];
        _elector.mesherPort = ETCDServerPort;
        
        //init self information
        self.myGroupName = @"Artsmesh";
        self.myUserName = [AMNetworkUtils getHostName];
        self.myIp = [AMNetworkUtils getHostIpv4Addr];
        self.myStatus = @"Online";
        self.myDomain = @"CCOM";
        self.myDescription = @"I'm a Developer";
        
        //Init ETCDService
        _myETCDService= [NSXPCInterface interfaceWithProtocol: @protocol(AMETCDServiceInterface)];
        _myETCDServiceConnection = [[NSXPCConnection alloc] initWithServiceName:@"AM.AMETCDService"];
        
        _myETCDServiceConnection.interruptionHandler = ^{
            NSLog(@"XPC connection was interrupted.");
        };
        
        _myETCDServiceConnection.invalidationHandler = ^{
            NSLog(@"XPC connection was invalidated.");
        };
        
        _myETCDServiceConnection.remoteObjectInterface = _myETCDService;
        [_myETCDServiceConnection resume];
    }
    
    return self;
}


-(void)startLoalMesher
{
    [_elector kickoffElectProcess];
    
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopLocalMesher
{
    //Should firstly clear all the operation in GCD, by there is way
    //to cancel the operation. So will change to NSOperations later.
    [self stopETCD];
    [_elector stopElect];
    
    [_elector removeObserver:self forKeyPath:@"state"];
}


-(void)startETCD:(NSDictionary*)params
{
    [_myETCDServiceConnection.remoteObjectProxy
     startService:params
     reply:^(id object){
         
         //add the data init process into mesher queue.
         dispatch_async([AMMesher mesher_serial_queue], ^{
             if(!_isETCDInit)
             {
                 _etcdApi = [[AMETCD alloc]init];
                 _etcdApi.serverIp = [AMNetworkUtils getHostIpv4Addr];
                 _etcdApi.clientPort = ETCDClientPort;
                 _etcdApi.serverPort = ETCDServerPort;
                 
                 NSString* leader = nil;
                 while (leader == nil)
                 {
                     leader = [_etcdApi getLeader];
                 }
                 
                 AMETCDResult* res = [_etcdApi createDir:@"/Groups/" ttl:0];
                 if(res.errCode != 0)
                 {
                     [NSException raise:@"Can not init ETCD Data" format:@""];
                 }
                 
                 res = [_etcdApi createDir:@"/Groups/Artsmesh/" ttl:0];
                 if(res.errCode != 0)
                 {
                     [NSException raise:@"Can not init ETCD Data" format:@""];
                 }
                 
                 res = [_etcdApi createDir:@"/Groups/Artsmesh/Users/" ttl:0];
                 if(res.errCode != 0)
                 {
                     [NSException raise:@"Can not init ETCD Data" format:@""];
                 }
                 
                 res = [_etcdApi createDir:@"/Mesher/" ttl:0];
                 if(res.errCode != 0)
                 {
                     [NSException raise:@"Can not init ETCD Data" format:@""];
                 }
                 
                 res = [_etcdApi createDir:@"/Mesher/Leader" ttl:0];
                 if(res.errCode != 0)
                 {
                     [NSException raise:@"Can not init ETCD Data" format:@""];
                 }
                 
                 _isETCDInit = YES;
                 [self updateMySelf];
             }
         });
     }];
    
    _heartbeatTimer =  [NSTimer scheduledTimerWithTimeInterval:5.0
                                                        target:self
                                                      selector:@selector(updateMySelf)
                                                      userInfo:nil
                                                       repeats:YES];
    
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


-(void) updateMySelf
{
    if(_isETCDInit == NO)
    {
        return;
    }
    
    //this operation should always be in the mehser queue.
    dispatch_async([AMMesher mesher_serial_queue], ^{
        
        AMETCDResult* res = nil;
        NSString* myUserDir = [NSString stringWithFormat:@"/Groups/Artsmesh/Users/%@/", self.myUserName];
        res = [_etcdApi createDir:myUserDir ttl:10];
        if(res.errCode != 0)
        {
            [NSException raise:@"Can not init ETCD Data" format:@""];
        }
        
        NSString* myUserIp = [NSString stringWithFormat:@"/Groups/Artsmesh/Users/%@/IP", self.myUserName];
        res = [_etcdApi setKey:myUserIp withValue:self.myIp ttl:10];
        if(res.errCode != 0)
        {
            [NSException raise:@"Can not init ETCD Data" format:@""];
        }
        
        NSString* myDomain = [NSString stringWithFormat:@"/Groups/Artsmesh/Users/%@/Domain", self.myUserName];
        res = [_etcdApi setKey:myDomain withValue:self.myDomain ttl:10];
        if(res.errCode != 0)
        {
            [NSException raise:@"Can not init ETCD Data" format:@""];
        }
        
        NSString* myStatus = [NSString stringWithFormat:@"/Groups/Artsmesh/Users/%@/Status", self.myUserName];
        res = [_etcdApi setKey:myStatus withValue:self.myStatus ttl:10];
        if(res.errCode != 0)
        {
            [NSException raise:@"Can not init ETCD Data" format:@""];
        }
        
        NSString* myDiscription = [NSString stringWithFormat:@"/Groups/Artsmesh/Users/%@/Discription", self.myUserName];
        res = [_etcdApi setKey:myDiscription withValue:self.myDescription ttl:10];
        if(res.errCode != 0)
        {
            [NSException raise:@"Can not init ETCD Data" format:@""];
        }
    });
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
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            //I'm the mesher start control service:
            
            NSString* _peer_addr = [NSString stringWithFormat:@"%@:%ld", _elector.mesherIp, _elector.mesherPort];
            NSString* _addr = [NSString stringWithFormat:@"%@:%d", _elector.mesherIp, ETCDClientPort];
    
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            
            [params setObject:_peer_addr forKey:@"-peer-addr"];
            [params setObject:_addr forKey:@"-addr"];
            
            [self startETCD:params];
        }
        else if(newState == 4)//Joined
        {
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            
            NSString* _peer_addr = [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], ETCDServerPort];
            NSString* _addr = [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], ETCDClientPort];
            NSString* _peers = [NSString stringWithFormat:@"%@:%ld", _elector.mesherIp, _elector.mesherPort];
            
            
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            
            [params setObject:_peer_addr forKey:@"-peer-addr"];
            [params setObject:_addr forKey:@"-addr"];
            [params setObject:_peers forKey:@"-peers"];
            
            [self startETCD:params];
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
