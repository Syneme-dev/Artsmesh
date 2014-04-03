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
#import "AMMesherOperationHeader.h"
#import "AMETCDApi/AMETCD.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMUserGroupNode.h"
#import "AMMesherAgent.h"

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMMesherAgent* _agent;
    NSTimer* _ttlTimer;

    BOOL _isMesher;
    BOOL _etcdIsRunning;
    BOOL _isErr;
    
    NSMutableArray* _userGroupChangeHandlers;
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
        _isMesher = NO;
        _etcdIsRunning = NO;
        _isErr = NO;
    
        self.myGroupName = @"Artsmesh";
        self.myUserName = [AMNetworkUtils getHostName];
        self.myDomain = Preference_MyDomain;
        self.myDescription = Preference_MyDescription;
        self.myStatus = Preference_MyStatus;
        self.myIp = [AMNetworkUtils getHostIpv4Addr];
        
        //Init Mesher Elector
        _elector = [[AMLeaderElecter alloc] init];
        _elector.mesherPort = Preference_ETCDServerPort;
        
        _agent = [[AMMesherAgent alloc] init];
        
        _userGroups = [[NSMutableArray alloc] init];
        _userGroupChangeHandlers = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

-(void)startLoalMesher
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"AM_UserGroupChanged_Notification" object:self];
    
    [_elector kickoffElectProcess];
    
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopLocalMesher
{
    _etcdIsRunning = NO;
    
    if(_ttlTimer)
    {
        [_ttlTimer invalidate];
    }
    
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
    AMDeleteUserOperation* removeOper = [[AMDeleteUserOperation alloc]
                                        initWithParameter:self.myIp
                                        serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                        username:self.myUserName
                                        groupname:self.myGroupName
                                        delegate:self];
    [removeOper start];
    
    AMKillETCDOperation* etcdKiller = [[AMKillETCDOperation alloc] init];
    [etcdKiller start];
    
    
    [_elector stopElect];
    [_elector removeObserver:self forKeyPath:@"state"];
    
}




-(void)startMesherLaunchProcess
{
    
    NSString* ip = self.myIp;
    NSString* clientport = [NSString stringWithFormat:@"%d",Preference_ETCDClientPort];
    NSString* serverport = [NSString stringWithFormat:@"%d",Preference_ETCDServerPort];
    NSString* heartbeat = [NSString stringWithFormat:@"%d",Preference_ETCD_HeartbeatTimeout];
    NSString* election = [NSString stringWithFormat:@"%d",Preference_ETCD_ElectionTimeout];
    
    NSMutableDictionary* userProperties = [[NSMutableDictionary alloc] init];
    [userProperties setObject:@"CCOM" forKey:@"domain"];
    [userProperties setObject:@"i'm a Mac developer" forKey:@"description"];
    [userProperties setObject:@"online" forKey:@"status"];
    [userProperties setObject:ip forKey:@"ip"];
    
    NSString* artsmeshGroup = @"Artsmesh";
    NSMutableDictionary* artsmeshGroupProperties = [[NSMutableDictionary alloc] init];
    [artsmeshGroupProperties setObject:@"CCOM" forKey:@"domain"];
    [artsmeshGroupProperties setObject:@"this is artsmesh" forKey:@"description"];
    
    NSString* performGroup = @"Perform";
    NSMutableDictionary* performGroupProperties = [[NSMutableDictionary alloc] init];
    [performGroupProperties setObject:@"CCOM" forKey:@"domain"];
    [performGroupProperties setObject:@"this is perform group" forKey:@"description"];


    AMLaunchETCDOperation* etcdLauncher = [[AMLaunchETCDOperation alloc] initWithParameter: ip
                                                                  serverPort:serverport
                                                                  clientPort:clientport
                                                                       peers:nil
                                                           heartbeatInterval:heartbeat
                                                             electionTimeout:election
                                                                    delegate:self];
    
    AMInitETCDOperation* etcdInitOper = [[AMInitETCDOperation alloc] initWithEtcdServer:ip
                                                                               port:clientport
                                                                           delegate:self];
    
    [etcdInitOper addDependency:etcdLauncher];
    
    AMAddGroupOperation* addGroupOper = [[AMAddGroupOperation alloc] initWithParameter:ip
                                                                            serverPort:clientport
                                                                             groupname:artsmeshGroup
                                                                       groupProperties:artsmeshGroupProperties
                                                                                   ttl:0
                                                                              delegate:self];
    [addGroupOper addDependency:etcdInitOper];
    
    AMAddGroupOperation* addPerformGroupOper = [[AMAddGroupOperation alloc] initWithParameter:ip
                                                                            serverPort:clientport
                                                                             groupname:performGroup
                                                                              groupProperties:performGroupProperties
                                                                                          ttl:0
                                                                                     delegate:self];
    [addPerformGroupOper addDependency:etcdInitOper];
    
    
    AMAddUserOperation* addSelfOper = [[AMAddUserOperation alloc] initWithParameter:ip
                                                                         serverPort:clientport
                                                                           username:self.myUserName
                                                                          groupname:self.myGroupName
                                                                     userProperties:userProperties
                                                                                ttl:Preference_User_TTL
                                                                           delegate:self];
    
    [addSelfOper addDependency:addGroupOper];
    [addSelfOper addDependency:addPerformGroupOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdLauncher];
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdInitOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:addGroupOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:addPerformGroupOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:addSelfOper];

}

-(void)startMesheeLaunchProcess
{
    NSString* ip = self.myIp;
    NSString* clientport = [NSString stringWithFormat:@"%d",Preference_ETCDClientPort];
    NSString* serverport = [NSString stringWithFormat:@"%d",Preference_ETCDServerPort];
    NSString* heartbeat = [NSString stringWithFormat:@"%d",Preference_ETCD_HeartbeatTimeout];
    NSString* election = [NSString stringWithFormat:@"%d",Preference_ETCD_ElectionTimeout];
    
    NSMutableDictionary* userProperties = [[NSMutableDictionary alloc] init];
    [userProperties setObject:@"CCOM" forKey:@"domain"];
    [userProperties setObject:@"i'm a Mac developer" forKey:@"description"];
    [userProperties setObject:@"online" forKey:@"status"];
    [userProperties setObject:ip forKey:@"ip"];
    
    
    AMLaunchETCDOperation* etcdLauncher = [[AMLaunchETCDOperation alloc] initWithParameter: ip
                                                                                serverPort:serverport
                                                                                clientPort:clientport
                                                                                     peers:nil
                                                                         heartbeatInterval:heartbeat
                                                                           electionTimeout:election
                                                                                  delegate:self];
    
    AMAddUserOperation* addSelfOper = [[AMAddUserOperation alloc] initWithParameter:ip
                                                                         serverPort:clientport
                                                                           username:self.myUserName
                                                                          groupname:self.myGroupName
                                                                     userProperties:userProperties
                                                                                ttl:Preference_User_TTL
                                                                           delegate:self];
    [addSelfOper addDependency:etcdLauncher];

    
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdLauncher];
    [[AMMesher sharedEtcdOperQueue] addOperation:addSelfOper];
}

-(void)setUserTTL
{
    NSString* ip = self.myIp;
    NSString* clientport = [NSString stringWithFormat:@"%d",Preference_ETCDClientPort];

    AMUserTTLOperation* userTTLOper = [[AMUserTTLOperation alloc] initWithParameter:ip
                                                                serverPort:clientport
                                                                  username:self.myUserName
                                                                 groupname:self.myGroupName
                                                                   ttltime:Preference_User_TTL
                                                                  delegate:self];
    [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
}

-(void)queryUserGroups
{
    NSString* ip = self.myIp;
    NSString* clientport = [NSString stringWithFormat:@"%d",Preference_ETCDClientPort];
    
    AMQueryGroupsOperation* queryOper = [[AMQueryGroupsOperation alloc] initWithParameter:ip
                                                                       serverPort:clientport
                                                                         delegate:self];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:queryOper];
}

-(void)startWatchingUserGroups
{
    static dispatch_queue_t _groupWatchQueue = nil;
    if (_groupWatchQueue ==nil)
    {
        _groupWatchQueue = dispatch_queue_create("_groupWatchQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    
    dispatch_async(_groupWatchQueue, ^{
        
        AMETCD* etcdApi = [[AMETCD alloc] init];
        etcdApi.serverIp = self.myIp;
        etcdApi.clientPort = Preference_ETCDClientPort;
        
        int index = 2;
        int actIndex = 0;
        while (_etcdIsRunning)
        {
            AMETCDResult* res = [etcdApi watchDir:@"/Groups" fromIndex:index
                                     acturalIndex:&actIndex timeout:5];
            if(res.errCode != 0)
            {
                continue;
            }
            
            index = actIndex + 1;
            
            if([res.action isEqualTo:@"update"])
            {
                NSLog(@"ttl info no change");
                continue;
            }
            
            NSArray* keypathes = [res.node.key componentsSeparatedByString:@"/"];
            if([keypathes count] < 3)
            {
                continue;
            }
            
            //have changed
            [self queryUserGroups];
        }
    });
    
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
            _isMesher = YES;
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            
            if(!_etcdIsRunning)
            {
                [self performSelectorOnMainThread:@selector(startMesherLaunchProcess) withObject:nil waitUntilDone:NO];
            }
        }
        else if(newState == 4)//Joined
        {
            _isMesher = NO;
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            
            if(!_etcdIsRunning)
            {
                [self performSelectorOnMainThread:@selector(startMesheeLaunchProcess) withObject:nil waitUntilDone:NO];
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
#pragma mark AMMesherOperationProtocol
- (void)LanchETCDOperationDidFinish:(NSOperation *)oper
{
    if (![oper isKindOfClass:[AMLaunchETCDOperation class]])
    {
        return;
    }
    
    AMLaunchETCDOperation* lancher = (AMLaunchETCDOperation*)oper;
    if (lancher.isResultOK)
    {
        _etcdIsRunning = YES;
    }
    else
    {
        [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
        
        _isErr = YES;
        _etcdIsRunning = NO;
    }
}

- (void)InitETCDOperationDidFinish:(NSOperation *)oper
{
    if (![oper isKindOfClass:[AMInitETCDOperation class]])
    {
        return;
    }
    
    AMInitETCDOperation* initializer = (AMInitETCDOperation*)oper;
    if(!initializer.isResultOK)
    {
        [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
        
        _isErr = YES;
    }
}

- (void)AddUserOperationDidFinish:(NSOperation *)oper
{
    if (![oper isKindOfClass:[AMAddUserOperation class]])
    {
        return;
    }
    
    AMAddGroupOperation* addOper = (AMAddGroupOperation*)oper;
    if (addOper.isResultOK)
    {
        if(_ttlTimer != nil)
        {
            [_ttlTimer invalidate];
        }
        
        [self queryUserGroups];
        [self startWatchingUserGroups];
        
        _ttlTimer  = [NSTimer scheduledTimerWithTimeInterval:Preference_User_TTL_Interval
                                                      target:self selector:@selector(setUserTTL)
                                                    userInfo:nil repeats:YES];
    }
    else
    {
        [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
        
        _isErr = YES;
    }
}

- (void)DeleteUserOperationDidFinish:(NSOperation *)oper
{
    
}

- (void)UpdateUserOperationDidFinish:(NSOperation *)oper
{
    
}

- (void)QueryGroupsOperationDidFinish:(NSOperation *)oper
{
    if (![oper isKindOfClass:[AMQueryGroupsOperation class]])
    {
        return;
    }
    
    AMQueryGroupsOperation* queryOper = (AMQueryGroupsOperation*)oper;
    
    if(queryOper.isResultOK)
    {
        @synchronized(self)
        {
            [self willChangeValueForKey:@"userGroups"];
            self.userGroups = queryOper.usergroups;
            [self didChangeValueForKey:@"userGroups"];
        }
        
        //[self notifyUserGroupChangeHandlers:queryOper.usergroups];
    }
    else
    {
        [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
        _isErr = YES;
    }
}

-(void)AddGroupOperationDidFinish:(NSOperation *)oper
{
    
}

-(void)UpdateGroupOperationDidFinish:(NSOperation *)oper
{
    
}

-(void)DeleteGroupOperationDidFinish:(NSOperation *)oper
{
    
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

-(void)
:(NSUInteger)index withObject:(id)object
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups replaceObjectAtIndex:index withObject:object ];
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
