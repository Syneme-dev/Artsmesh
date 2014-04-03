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
#import "AMMesherOperationProtocol.h"
#import "AMETCDLauncher.h"
#import "AMETCDInitializer.h"
#import "AMAddUserOperator.h"
#import "AMUpdateUserOperator.h"
#import "AMQueryAllOperator.h"
#import "AMRemoveUserOperator.h"
#import "AMUserTTLOperator.h"
#import "AMETCDKiller.h"
#import "AMETCDApi/AMETCD.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMUserGroupNode.h"


@implementation AMMesher
{
    AMLeaderElecter* _elector;
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

+(NSOperationQueue*)sharedEtcdOperQueue;
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
    AMRemoveUserOperator* removeOper = [[AMRemoveUserOperator alloc]
                                        initWithParameter:self.myIp
                                        serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                        username:self.myUserName
                                        groupname:self.myGroupName
                                        delegate:self];
    [removeOper start];
    
    AMETCDKiller* etcdKiller = [[AMETCDKiller alloc] init];
    [etcdKiller start];
    
    
    [_elector stopElect];
    [_elector removeObserver:self forKeyPath:@"state"];
    
}




-(void)startMesherLaunchProcess
{
    AMETCDLauncher* etcdLauncher = [[AMETCDLauncher alloc] initWithParameter: self.myIp
                                                                  serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDServerPort]
                                                                  clientPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                       peers:nil
                                                           heartbeatInterval:[NSString stringWithFormat:@"%d",Preference_ETCD_HeartbeatTimeout]
                                                             electionTimeout:[NSString stringWithFormat:@"%d",Preference_ETCD_ElectionTimeout]
                                                                    delegate:self];
    
    AMETCDInitializer* etcdInitOper = [[AMETCDInitializer alloc] initWithEtcdServer:self.myIp
                                                                               port:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                           delegate:self];
    
    [etcdInitOper addDependency:etcdLauncher];
    
    AMAddUserOperator* addSelfOper = [[AMAddUserOperator alloc] initWithParameter:self.myIp
                                                                       serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                         username:self.myUserName
                                                                        groupname:self.myGroupName
                                                                       userdomain:self.myDomain
                                                                           userip:self.myIp
                                                                       userStatus:self.myStatus
                                                                  userDiscription:self.myDescription
                                                                         delegate:self];
    
    [addSelfOper addDependency:etcdInitOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdLauncher];
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdInitOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:addSelfOper];

}

-(void)startMesheeLaunchProcess
{
    AMETCDLauncher* etcdLauncher = [[AMETCDLauncher alloc] initWithParameter: self.myIp
                                                                  serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDServerPort]
                                                                  clientPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                       peers:nil
                                                           heartbeatInterval:[NSString stringWithFormat:@"%d",Preference_ETCD_HeartbeatTimeout]
                                                             electionTimeout:[NSString stringWithFormat:@"%d",Preference_ETCD_ElectionTimeout]
                                                                    delegate:self];

    
    AMAddUserOperator* addSelfOper = [[AMAddUserOperator alloc] initWithParameter:self.myIp
                                                                       serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                         username:self.myUserName
                                                                        groupname:self.myGroupName
                                                                       userdomain:self.myDomain
                                                                           userip:self.myIp
                                                                       userStatus:self.myStatus
                                                                  userDiscription:self.myDescription
                                                                         delegate:self];
    
    [addSelfOper addDependency:etcdLauncher];
    
    
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdLauncher];
    [[AMMesher sharedEtcdOperQueue] addOperation:addSelfOper];
   
}

-(void)setUserTTL
{
    AMUserTTLOperator* userTTLOper = [[AMUserTTLOperator alloc] initWithParameter:self.myIp
                                                                serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                  username:self.myUserName
                                                                 groupname:self.myGroupName
                                                                   ttltime:Preference_User_TTL
                                                                  delegate:self];
    [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
}

-(void)queryUserGroups
{
    AMQueryAllOperator* queryOper = [[AMQueryAllOperator alloc] initWithParameter:self.myIp
                                                                       serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
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
            AMQueryAllOperator* queryOper =[[AMQueryAllOperator alloc] initWithParameter:self.myIp
                                                                              serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                                                                delegate:self];
            [[AMMesher sharedEtcdOperQueue ] addOperation:queryOper];
        }
    });
    
}


//-(void)addUserGroupObserver:(id<UserGroupChangeHandler>)handler
//{
//    [_userGroupChangeHandlers addObject:handler ];
//}
//
//-(void)removeUserGroupObserver:(id<UserGroupChangeHandler>)handler
//{
//    if (_userGroupChangeHandlers != nil)
//    {
//        [_userGroupChangeHandlers removeObject:handler];
//    }
//}
//
//-(void)notifyUserGroupChangeHandlers:(NSArray*)userGroups
//{
//    for(id<UserGroupChangeHandler> handler in _userGroupChangeHandlers)
//    {
//        [handler handleUserGroupChange:userGroups];
//    }
//}


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
- (void)ETCDLauncherDidFinish:(AMETCDLauncher *)launcher;
{
    if (launcher.isResultOK)
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


- (void)ETCDInitializerDidFinish:(AMETCDInitializer *)initializer
{
    if(!initializer.isResultOK)
    {
        [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
        
        _isErr = YES;
    }
}


- (void)AddUserOperatorDidFinish:(AMAddUserOperator *)addOper
{
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


- (void)RemoveUserOperatorDidFinish:(AMRemoveUserOperator *)removeOper
{
    
}

- (void)UpdateUserOperatorDidFinish:(AMUpdateUserOperator *)UpdataOper
{
    
}

- (void)QueryAllOperatorDidFinish:(AMQueryAllOperator *)queryOper
{
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


-(void)UserTTLOperatorDidFinish:(AMUserTTLOperator *)queryOper
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
