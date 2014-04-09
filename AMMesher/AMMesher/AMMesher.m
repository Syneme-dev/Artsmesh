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
#import "AMUserGroupNode.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMETCDOperationHeader.h"

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMETCDDataSource* _lanSource;
    AMETCDDataDestination* _usergroupDest;
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
            etcdOperQueue.maxConcurrentOperationCount = 1;
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

-(void)launchETCD
{
    AMETCDLaunchOperation* launchOper = [[AMETCDLaunchOperation alloc]
                                         initWithParameter:Preference_MyIp
                                         clientPort:Preference_MyETCDClientPort
                                         serverPort:Preference_MyETCDServerPort
                                         peers:nil
                                         heartbeatInterval:Preference_MyETCDHeartbeatTimeout
                                         electionTimeout:Preference_MyETCDElectionTimeout];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:launchOper];
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
            
            if(!self.etcdState == 0)
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
    if(oper.isResultOK == YES && [oper.operationType isEqualToString:@"lanuch"])
    {
        _lanSource = [[AMETCDDataSource alloc] init:@"lanSource"
                                                 ip:Preference_MyIp
                                               port:Preference_MyETCDClientPort];
        
        _usergroupDest = [[AMETCDDataDestination alloc]
                          init];
        
        [_lanSource addDestination:_usergroupDest];
        [_lanSource watch];
        
        
        NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                  Preference_MyUserName,
                                  Preference_MyDomain,
                                  Preference_MyLocation];
        NSString* fullGroupName = [NSString stringWithFormat:@"%@@%@.%@",
                                  Preference_DefaultGroupName,
                                  Preference_MyDomain,
                                  Preference_MyLocation];
        
        AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                               initWithParameter:Preference_MyIp
                                               port:Preference_MyETCDClientPort
                                               fullUserName:fullUserName
                                               fullGroupName:fullGroupName
                                               ttl:Preference_MyEtCDUserTTL];
        
        [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
    }
}


#pragma mark -
#pragma mark KVO


-(NSUInteger)countOfGroups
{
    return [self.userGroups count];
}

-(AMUserGroupNode*)objectInGroupsAtIndex:(NSUInteger)index
{
    return [self.userGroups objectAtIndex:index];
}

-(void)addGroupsObject:(AMUserGroupNode *)object
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups addObject:object];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)insertObject:(AMUserGroupNode *)object inGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups insertObject:object atIndex:index];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)removeObjectFromGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups removeObjectAtIndex:index];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)removeGroupsObject:(AMUserGroupNode *)object
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups removeObject:object];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)replaceObjectInGroupsAtIndex:(NSUInteger)index withObject:(id)object
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups replaceObjectAtIndex:index withObject:object];
    [self didChangeValueForKey:@"userGroups"];
}


@end
