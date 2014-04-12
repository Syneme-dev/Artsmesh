//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMMesherPreference.h"
#import "AMLeaderElecter.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMETCDApi/AMETCD.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMETCDOperationHeader.h"
#import "AMETCDDataSourceHeader.h"

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMETCDDataSource* _dataSource;
    NSTimer* _userTTL;
}

+(id)sharedAMMesher
{
    static AMMesher* sharedMesher = nil;
    
    @synchronized(self)
    {
        if (sharedMesher == nil)
        {
            sharedMesher = [[self alloc] init];
        }
    }
    
    return sharedMesher;
}

+(NSOperationQueue*)sharedEtcdOperQueue
{
    static NSOperationQueue* etcdOperQueue = nil;
    
    @synchronized(self)
    {
        if (!etcdOperQueue)
        {
            etcdOperQueue = [[NSOperationQueue alloc] init];
            etcdOperQueue.name = @"ETCD Operation Queue";
            //etcdOperQueue.maxConcurrentOperationCount = 1;
        }
    }
    
    return etcdOperQueue;
}

-(id)init
{
    if (self = [super init])
    {
        self.isLeader = NO;
        self.etcdState = 0;
        self.myGroupName = Preference_DefaultGroupName;
        
        _elector = [[AMLeaderElecter alloc] init];
        _elector.mesherPort = [Preference_MyETCDServerPort intValue];
        
        
        _userGroups = [[NSMutableArray alloc] init];
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
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                              Preference_MyUserName,
                              Preference_MyDomain,
                              Preference_MyLocation];
    
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
    
    @synchronized(self)
    {
        AMETCDDeleteUserOperation* delOper = [[AMETCDDeleteUserOperation alloc]
                                              initWithParameter:_dataSource.ip
                                              port:_dataSource.port
                                              fullUserName:fullUserName];
        
        [delOper start];

    }
   
    
    AMKillETCDOperation* etcdKiller = [[AMKillETCDOperation alloc] init];
    [etcdKiller start];
    
    self.etcdState = 0;
    
    [_elector stopElect];
    [_elector removeObserver:self forKeyPath:@"state"];
}

-(void)goOnline
{
    if(self.etcdState != 1)
    {
        return;
    }
    
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations];
    
    @synchronized(self)
    {
        [self.usergroupDest clearUserGroup];
        
        [_dataSource stopWatch];
        _dataSource.ip   = Preference_ArtsmeshIO_IP;
        _dataSource.port = Preference_ArtsmeshIO_Port;
        [self addSelfToDataSource];
    }
}

-(void)goOffline
{
    if(self.etcdState != 1)
    {
        return;
    }
    
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations];
    
    @synchronized(self)
    {
        NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                  Preference_MyUserName,
                                  Preference_MyDomain,
                                  Preference_MyLocation];
        
        AMETCDDeleteUserOperation* delOper = [[AMETCDDeleteUserOperation alloc]
                                              initWithParameter:_dataSource.ip
                                              port:_dataSource.port
                                              fullUserName:fullUserName];
        
        [delOper start];

        [self.usergroupDest clearUserGroup];
        
        [_dataSource stopWatch];
        _dataSource.ip   = Preference_MyIp;
        _dataSource.port = Preference_MyETCDClientPort;
        [self addSelfToDataSource];
    }

    
}


-(void)joinGroup:(NSString*)groupName
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                              Preference_MyUserName,
                              Preference_MyDomain,
                              Preference_MyLocation];
    
    NSString* groupNameKey = @"GroupName";
    self.myGroupName = groupName;
    NSMutableDictionary* userPropties = [[NSMutableDictionary alloc] init];
    [userPropties setObject:groupName forKey:groupNameKey];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port:_dataSource.port
                                                 fullUserName:fullUserName
                                                 userProperties:userPropties];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
}

-(void)createGroup:(NSString*)groupName
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                              Preference_MyUserName,
                              Preference_MyDomain,
                              Preference_MyLocation];
    
    NSString* groupNameKey = @"GroupName";
    self.myGroupName = groupName;
    NSMutableDictionary* userPropties = [[NSMutableDictionary alloc] init];
    [userPropties setObject:groupName forKey:groupNameKey];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port: _dataSource.port
                                                 fullUserName:fullUserName
                                                 userProperties:userPropties];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
}

-(void)backToArtsmesh
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                              Preference_MyUserName,
                              Preference_MyDomain,
                              Preference_MyLocation];
    
    NSString* groupNameKey = @"GroupName";
    self.myGroupName = Preference_DefaultGroupName;
    
    NSMutableDictionary* userPropties = [[NSMutableDictionary alloc] init];
    [userPropties setObject:@"Artsmesh" forKey:groupNameKey];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port: _dataSource.port
                                                 fullUserName:fullUserName
                                                 userProperties:userPropties];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
}

-(void)launchETCD
{
    NSString* peers =nil;
    
    if (!self.isLeader)
    {
        peers = [NSString stringWithFormat:@"%@:%ld",  _elector.mesherIp, _elector.mesherPort];
    }

    AMETCDLaunchOperation* launchOper = [[AMETCDLaunchOperation alloc]
                                         initWithParameter:Preference_MyIp
                                         clientPort:Preference_MyETCDClientPort
                                         serverPort:Preference_MyETCDServerPort
                                         peers:peers
                                         heartbeatInterval:Preference_MyETCDHeartbeatTimeout
                                         electionTimeout:Preference_MyETCDElectionTimeout];
    launchOper.delegate = self;
    
    AMETCDInitOperation* etcdInitOper = [[AMETCDInitOperation alloc]
                                         initWithEtcdServer:Preference_MyIp
                                         port:Preference_MyETCDClientPort];
    etcdInitOper.delegate = self;
    [etcdInitOper addDependency:launchOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:launchOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdInitOper];

}

-(void)addSelfToDataSource
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                              Preference_MyUserName,
                              Preference_MyDomain,
                              Preference_MyLocation];
    
    AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                           initWithParameter: _dataSource.ip
                                           port:_dataSource.port
                                           fullUserName:fullUserName
                                           fullGroupName:self.myGroupName
                                           ttl:Preference_MyEtCDUserTTL];
    
    AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                           initWithParameter:Preference_MyIp
                                           port:Preference_MyETCDClientPort
                                           fullUserName:fullUserName
                                           ttl:Preference_MyEtCDUserTTL];
    
    addUserOper.delegate = self;
    userTTLOper.delegate = self;
    
    [userTTLOper addDependency:addUserOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
}

-(void)refreshMyTTL
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                              Preference_MyUserName,
                              Preference_MyDomain,
                              Preference_MyLocation];
    
    @synchronized(self)
    {
        AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                               initWithParameter:_dataSource.ip
                                               port:_dataSource.port
                                               fullUserName:fullUserName
                                               ttl:Preference_MyEtCDUserTTL];
        
        userTTLOper.delegate = self;
        
        [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
    }
}

#pragma mark -
#pragma   mark KVO
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
            self.isLeader = YES;
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            
            if (self.etcdState == 0)
            {
                [self performSelectorOnMainThread:@selector(launchETCD)
                                       withObject:nil waitUntilDone:NO];
            }
        }
        else if(newState == 4)//Joined
        {
            self.isLeader = NO;
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            
            if(self.etcdState == 0)
            {
                [self performSelectorOnMainThread:@selector(launchETCD) withObject:nil waitUntilDone:NO];
            }
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
#pragma mark AMETCDOperationDelegate
-(void)AMETCDOperationDidFinished:(AMETCDOperation *)oper
{
    if([oper isKindOfClass:[AMETCDInitOperation class]])
    {
        if (oper.isResultOK == NO)
        {
            [NSException raise:@"etcd start error" format:nil];
            return;
        }
        
        self.etcdState = 1;
        
        @synchronized(self)
        {
            _dataSource = [[AMETCDDataSource alloc]
                           init:@"data source"
                           ip:Preference_MyIp
                           port:Preference_MyETCDClientPort];
            self.usergroupDest = [[AMETCDDataDestination alloc] init];
            
            [_dataSource addDestination:self.usergroupDest];
            [self addSelfToDataSource];
        }
    }
    else if([oper isKindOfClass:[AMETCDUserTTLOperation class]])
    {
        _userTTL = [NSTimer scheduledTimerWithTimeInterval:Preference_MyECDUserTTLInterval
                                                    target:self
                                                  selector:@selector(refreshMyTTL)
                                                  userInfo:nil
                                                   repeats:NO];
    }
    else if([oper isKindOfClass:[AMETCDAddUserOperation class]])
    {
        [_dataSource watch];
    }
}

@end
