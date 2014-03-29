//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMMesherPreference.h"
#import "AMETCDServiceInterface.h"
#import "AMLeaderElecter.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMETCDApi/AMETCD.h"
#import "AMGroup.h"
#import "AMUser.h"

@interface AMMesher ()

-(void)initMesherDataIntoETCD;
-(void)updateMySelf;
-(void)watchUserGroupData;

@end

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMETCD* _etcdApi;
    BOOL _isETCDInit;
    NSTimer* _heartbeatTimer;
    BOOL _isRunning;
    BOOL _isLeader;

    NSXPCInterface* _myETCDService;
    NSXPCConnection* _myETCDServiceConnection;
    
}

dispatch_queue_t _mesher_serial_update_queue = NULL;

+(dispatch_queue_t) get_mesher_serial_update_queue
{
    if(_mesher_serial_update_queue == NULL)
    {
        _mesher_serial_update_queue = dispatch_queue_create("_mesher_serial_update_queue", NULL);
    }
    
    return _mesher_serial_update_queue;
}

dispatch_queue_t _mesher_serial_query_queue = NULL;
+(dispatch_queue_t) get_mesher_serial_query_queue
{
    if(_mesher_serial_query_queue == NULL)
    {
        _mesher_serial_query_queue = dispatch_queue_create("_mesher_serial_query_queue", NULL);
    }
    
    return _mesher_serial_query_queue;
}

-(id)init
{
    if (self = [super init])
    {
        _isETCDInit =NO;
        _isLeader = NO;
        _isRunning = NO;
        
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
        
        //init group information
        groups = [[NSMutableArray alloc] init];
        
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
         [self initMesherDataIntoETCD];
         [self updateMySelf];
         [self getUserGroupData];
     }];
    
    _heartbeatTimer =  [NSTimer scheduledTimerWithTimeInterval:5.0
                                                        target:self
                                                      selector:@selector(updateMySelf)
                                                      userInfo:nil
                                                       repeats:YES];
   // [self watchUserGroupData];
    _isRunning = true;
}


-(void)stopETCD
{
    _isRunning = NO;
    _isETCDInit = NO;
    
    [_heartbeatTimer invalidate];
    
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
            _isLeader = YES;
            
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


#pragma mark -
#pragma mark Run Only In Mesher Queue

- (void)initMesherDataIntoETCD
{
    //add the data init process into mesher queue.
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = [AMNetworkUtils getHostIpv4Addr];
        _etcdApi.clientPort = ETCDClientPort;
        _etcdApi.serverPort = ETCDServerPort;
        
        if(!_isETCDInit && _isLeader==YES)
        {
            NSString* leader = nil;
            while (leader == nil)
            {
                leader = [_etcdApi getLeader];
            }
            
            int retryLeft = 3;
            
            //For all these public resource, we need a distribute lock, etcd api
            AMETCDResult* res = [_etcdApi setDir:@"/Groups/" ttl:0 prevExist:NO];
            if(res.errCode != 0)
            {
                while(retryLeft != 0)
                {
                    res = [_etcdApi setDir:@"/Groups/" ttl:0 prevExist:NO];
                    if(res.errCode == 0)
                    {
                        retryLeft = 3;
                        break;
                    }
                    
                    retryLeft--;
                }
            
                if(retryLeft == 0)
                {
                    [NSException raise:@"Can not init ETCD Data" format:@""];
                }
                
            }
            
            res = [_etcdApi setDir:@"/Groups/Artsmesh/" ttl:0 prevExist:NO];
            if(res.errCode != 0)
            {
                while(retryLeft != 0)
                {
                    res = [_etcdApi setDir:@"/Groups/Artsmesh/" ttl:0 prevExist:NO];
                    if(res.errCode == 0)
                    {
                        retryLeft = 3;
                        break;
                    }
                    
                    retryLeft--;
                }
                
                if(retryLeft == 0)
                {
                    [NSException raise:@"Can not init ETCD Data" format:@""];
                }

            }
            
            res = [_etcdApi setDir:@"/Groups/Artsmesh/Users/" ttl:0 prevExist:NO];
            if(res.errCode != 0)
            {
                while(retryLeft != 0)
                {
                    res = [_etcdApi setDir:@"/Groups/Artsmesh/Users/" ttl:0 prevExist:NO];
                    if(res.errCode == 0)
                    {
                        retryLeft = 3;
                        break;
                    }
                    
                    retryLeft--;
                }
                
                if(retryLeft == 0)
                {
                    [NSException raise:@"Can not init ETCD Data" format:@""];
                }

            }
            
            res = [_etcdApi setKey:@"/Groups/Artsmesh/description/" withValue:@"This is default group" ttl:0];
            if(res.errCode != 0)
            {
                while(retryLeft != 0)
                {
                    res = [_etcdApi setKey:@"/Groups/Artsmesh/description/" withValue:@"This is default group" ttl:0];
                    if(res.errCode == 0)
                    {
                        retryLeft = 3;
                        break;
                    }
                    
                    retryLeft--;
                }
                
                if(retryLeft == 0)
                {
                    [NSException raise:@"Can not init ETCD Data" format:@""];
                }

            }
            
            res = [_etcdApi setDir:@"/Mesher/" ttl:0 prevExist:NO];
            if(res.errCode != 0)
            {
                while(retryLeft != 0)
                {
                    res = [_etcdApi setDir:@"/Mesher/" ttl:0 prevExist:NO];
                    if(res.errCode == 0)
                    {
                        retryLeft = 3;
                        break;
                    }
                    
                    retryLeft--;
                }
                
                if(retryLeft == 0)
                {
                    [NSException raise:@"Can not init ETCD Data" format:@""];
                }
            }
            
            res = [_etcdApi setDir:@"/Mesher/Leader" ttl:0 prevExist:NO];
            if(res.errCode != 0)
            {
                while(retryLeft != 0)
                {
                    res = [_etcdApi setDir:@"/Mesher/Leader" ttl:0 prevExist:NO];
                    if(res.errCode == 0)
                    {
                        retryLeft = 3;
                        break;
                    }
                    
                    retryLeft--;
                }
                
                if(retryLeft == 0)
                {
                    [NSException raise:@"Can not init ETCD Data" format:@""];
                }
            }
        }
        
         _isETCDInit = YES;
    });
}

-(void) updateMySelf
{
    if(_isETCDInit == NO)
    {
        return;
    }
    
    //this operation should always be in the mehser queue.
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        int retryLeft = 3;
        
        AMETCDResult* res = nil;
        NSString* myUserDir = [NSString stringWithFormat:@"/Groups/%@/Users/%@/", self.myGroupName,self.myUserName];
        res = [_etcdApi setDir:myUserDir ttl:30 prevExist:YES];
        if(res.errCode != 0)
        {
            while(retryLeft != 0)
            {
                res = [_etcdApi setDir:myUserDir ttl:30 prevExist:YES];
                if(res.errCode == 0)
                {
                    retryLeft = 3;
                    break;
                }
                
                retryLeft--;
            }
            
            if(retryLeft == 0)
            {
                [NSException raise:@"Can not init ETCD Data" format:@""];
            }
        }
        
        NSString* ip = [NSString stringWithFormat:@"/Groups/%@/Users/%@/ip",self.myGroupName, self.myUserName];
        res = [_etcdApi setKey:ip withValue:self.myIp ttl:30];
        if(res.errCode != 0)
        {
            while(retryLeft != 0)
            {
                res = [_etcdApi setKey:ip withValue:self.myIp ttl:30];
                if(res.errCode == 0)
                {
                    retryLeft = 3;
                    break;
                }
                
                retryLeft--;
            }
            
            if(retryLeft == 0)
            {
                [NSException raise:@"Can not init ETCD Data" format:@""];
            }
        }
        
        NSString* domain = [NSString stringWithFormat:@"/Groups/%@/Users/%@/domain", self.myGroupName,self.myUserName];
        res = [_etcdApi setKey:domain withValue:self.myDomain ttl:30];
        if(res.errCode != 0)
        {
            while(retryLeft != 0)
            {
                res = [_etcdApi setKey:domain withValue:self.myDomain ttl:30];
                if(res.errCode == 0)
                {
                    retryLeft = 3;
                    break;
                }
                
                retryLeft--;
            }
            
            if(retryLeft == 0)
            {
                [NSException raise:@"Can not init ETCD Data" format:@""];
            }
        }
        
        NSString* status = [NSString stringWithFormat:@"/Groups/%@/Users/%@/status", self.myGroupName, self.myUserName];
        res = [_etcdApi setKey:status withValue:self.myStatus ttl:30];
        if(res.errCode != 0)
        {
            while(retryLeft != 0)
            {
                res = [_etcdApi setKey:status withValue:self.myStatus ttl:30];
                if(res.errCode == 0)
                {
                    retryLeft = 3;
                    break;
                }
                
                retryLeft--;
            }
            
            if(retryLeft == 0)
            {
                [NSException raise:@"Can not init ETCD Data" format:@""];
            }
        }
        
        NSString* dis = [NSString stringWithFormat:@"/Groups/%@/Users/%@/description", self.myGroupName, self.myUserName];
        res = [_etcdApi setKey:dis withValue:self.myDescription ttl:30];
        if(res.errCode != 0)
        {
            while(retryLeft != 0)
            {
                res = [_etcdApi setKey:dis withValue:self.myDescription ttl:30];
                if(res.errCode == 0)
                {
                    retryLeft = 3;
                    break;
                }
                
                retryLeft--;
            }
            
            if(retryLeft == 0)
            {
                [NSException raise:@"Can not init ETCD Data" format:@""];
            }
        }
    });
}


-(void)getUserGroupData
{
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        AMETCDResult* res = [_etcdApi listDir:@"/Groups" recursive:YES];
        if (res.errCode  == 0)
        {
            groups = [self parseETCDResultToGroups: res];
        }
    });
}

-(void)watchUserGroupData
{
    dispatch_async([AMMesher get_mesher_serial_query_queue], ^{
        
        AMETCDResult* res = [_etcdApi listDir:@"/Groups" recursive:YES];
        if (res.errCode  == 0)
        {
            [self parseETCDResultToGroups: res];
        }
        
        
        while (_isRunning)
        {
            //if no change in 5 senconds wait, impossible we update ttl in 5 seconds
            res = [_etcdApi watchDir:@"/Groups" timeout:10];
            if([res.action isEqualToString:@"update"])
            {
                continue;
            }
        }
    });
    
}


-(NSMutableArray*)parseETCDResultToGroups:(AMETCDResult*)res
{
    if(![res.node.key isEqualToString:@"/Groups"])
    {
        return nil;
    }
    
    NSMutableArray* queryGroups = [[NSMutableArray alloc] init];
    
    for (AMETCDNode* groupNode in res.node.nodes)
    {
        NSArray* pathes = [groupNode.key componentsSeparatedByString:@"/"];
        if([pathes count] < 3)
        {
            continue;
        }

        AMGroup* newGroup = [[AMGroup alloc] init];
        newGroup.users = [[NSMutableArray alloc] init];
        newGroup.name = [pathes objectAtIndex:2];
        
        for (AMETCDNode* groupPropertyNode in groupNode.nodes)
        {
            NSArray* pathes = [groupPropertyNode.key componentsSeparatedByString:@"/"];
            if([pathes count] < 4)
            {
                continue;
            }
            
            NSString* groupProperty = [pathes objectAtIndex:3];
            if([groupProperty isEqualToString:@"Users"])
            {
                //set group users
                for(AMETCDNode* userNode in groupPropertyNode.nodes)
                {
                    NSArray* pathes = [userNode.key componentsSeparatedByString:@"/"];
                    if([pathes count] < 5)
                    {
                        continue;
                    }
                    
                    AMUser* newUser = [[AMUser alloc] init];
                    newUser.name = [pathes objectAtIndex:4];
                    
                    for (AMETCDNode* userPorpertyNode in userNode.nodes)
                    {
                        NSArray* pathes = [userPorpertyNode.key componentsSeparatedByString:@"/"];
                        if([pathes count] < 6)
                        {
                            continue;
                        }
                        
                        NSString* userProperty = [pathes objectAtIndex:5];
                        [newUser setValue:userPorpertyNode.value forKey:userProperty];
                    }
                    
                    newUser.group = newGroup;
                    [newGroup.users addObject:newUser];
                }
            }
            else
            {
                //set group other properties
                [newGroup setValue:groupPropertyNode.value forKey:groupProperty];
            }
        }
        
        [queryGroups addObject:newGroup];
    }
    
    return groups;
}


-(NSString*)myGroupName
{
    @synchronized(self)
    {
        return [myGroupName copy];
    }
    
}


-(void)setMyGroupName:(NSString*)name
{
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        myGroupName = name;
        
        if(_isETCDInit)
        {
            //modify name in etcd
        }
    });
}

-(NSString*)myUserName
{
    return myUserName;
}

-(void)setMyUserName:(NSString*)name
{
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        myUserName = name;
        
        if(_isETCDInit)
        {
            //modify name in etcd
        }
    });
}

-(NSString*)myDomain
{
    return myDomain;
}

-(void)setMyDomain:(NSString*)domain
{
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        myDomain = domain;
        
        if(_isETCDInit)
        {
            //modify name in etcd
        }
    });
   
}

-(NSString*)myDescription
{
    return myDescription;
}

-(void)setMyDescription:(NSString*)description
{
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        myDescription = description;
        if(_isETCDInit)
        {
            //modify name in etcd
        }
    });
}

-(NSString*)myStatus
{
    return myStatus;
}

-(void)setMyStatus:(NSString*)status
{
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        myStatus = status;
        if(_isETCDInit)
        {
            //modify name in etcd
        }
    });
}

-(NSString*)myIp
{
    return myIp;
}

-(void)setMyIp:(NSString*)ip
{
    dispatch_async([AMMesher get_mesher_serial_update_queue], ^{
        
        myIp = ip;
        if(_isETCDInit)
        {
            //modify name in etcd
        }
    });
}

@end
