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
    AMETCDDataSource* _lanSource;
    AMETCDDataSource* _AMIOSource;

    
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
        self.groupsState  = 0;
        
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
    NSString* fullGroupName = [NSString stringWithFormat:@"%@@%@.%@",
                               Preference_DefaultGroupName,
                               Preference_MyDomain,
                               Preference_MyLocation];
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
    AMETCDDeleteUserOperation* delOper = [[AMETCDDeleteUserOperation alloc]
                                        initWithParameter:Preference_MyIp
                                          port:Preference_MyETCDClientPort
                                          fullUserName:fullUserName
                                          fullGroupName:fullGroupName];

    [delOper start];

    AMKillETCDOperation* etcdKiller = [[AMKillETCDOperation alloc] init];
    [etcdKiller start];
    
    self.etcdState = 0;
    
    [_elector stopElect];
    [_elector removeObserver:self forKeyPath:@"state"];
}


-(void)goOnline
{
    if(self.etcdState != 1 || self.groupsState != 0)
    {
        return;
    }
    
    
    
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
    
    [[AMMesher sharedEtcdOperQueue] addOperation:launchOper];
    

}

-(void)refreshMyTTL
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                              Preference_MyUserName,
                              Preference_MyDomain,
                              Preference_MyLocation];
    NSString* fullGroupName = [NSString stringWithFormat:@"%@@%@.%@",
                               Preference_DefaultGroupName,
                               Preference_MyDomain,
                               Preference_MyLocation];
    
    AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                           initWithParameter:Preference_MyIp
                                           port:Preference_MyETCDClientPort
                                           fullUserName:fullUserName
                                           fullGroupName:fullGroupName
                                           ttl:Preference_MyEtCDUserTTL];
    
     userTTLOper.delegate = self;
    
    [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
    
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
    if([oper isKindOfClass:[AMETCDLaunchOperation class]])
    {
        if (oper.isResultOK == NO)
        {
            [NSException raise:@"etcd start error" format:nil];
            return;
        }
        
        self.etcdState = 1;
    
        NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                  Preference_MyUserName,
                                  Preference_MyDomain,
                                  Preference_MyLocation];
        NSString* fullGroupName = [NSString stringWithFormat:@"%@@%@.%@",
                                  Preference_DefaultGroupName,
                                  Preference_MyDomain,
                                  Preference_MyLocation];
        
        AMETCDAddGroupOperation* addGroupOper = [[AMETCDAddGroupOperation alloc]
                                                 initWithParameter:Preference_MyIp
                                                 port:Preference_MyETCDClientPort
                                                 fullGroupName:fullGroupName
                                                 ttl:0];
        
        
        AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                               initWithParameter:Preference_MyIp
                                               port:Preference_MyETCDClientPort
                                               fullUserName:fullUserName
                                               fullGroupName:fullGroupName
                                               ttl:Preference_MyEtCDUserTTL];
        
        
        AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                               initWithParameter:Preference_MyIp
                                               port:Preference_MyETCDClientPort
                                               fullUserName:fullUserName
                                               fullGroupName:fullGroupName
                                               ttl:Preference_MyEtCDUserTTL];
        addGroupOper.delegate = self;
        addUserOper.delegate = self;
        userTTLOper.delegate = self;
        
        [addUserOper addDependency:addGroupOper];
        [userTTLOper addDependency:addUserOper];
        
        [[AMMesher sharedEtcdOperQueue] addOperation:addGroupOper];
        [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
        [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
        
        
    }
    else if([oper isKindOfClass:[AMETCDUserTTLOperation class]])
    {
        _userTTL = [NSTimer scheduledTimerWithTimeInterval:Preference_MyECDUserTTLInterval
                                                    target:self selector:@selector(refreshMyTTL)
                                                  userInfo:nil
                                                   repeats:NO];
    }
    else if([oper isKindOfClass:[AMETCDAddUserOperation class]])
    {
        static BOOL isSelfAdded = NO;
        
        if (isSelfAdded == NO)
        {
            _lanSource = [[AMETCDDataSource alloc] init:@"lanSource"
                                                     ip:Preference_MyIp
                                                   port:Preference_MyETCDClientPort];
            
            self.usergroupDest = [[AMETCDDataDestination alloc]
                                  init];
            
            [_lanSource addDestination:self.usergroupDest];
            [_lanSource watch];
        }
        
        isSelfAdded = YES;
        
    }
    
}

@end
