//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMETCDOperationHeader.h"
#import "AMETCDDataSourceHeader.h"
#import "AMMesher.h"
#import "AMLeaderElecter.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMETCDApi/AMETCD.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMCommunicator.h"
#import "AMPreferenceManager/AMPreferenceManager.h"


@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMETCDDataSource* _dataSource;
    AMCommunicator* _communicator;
    NSTimer* _userTTL;
    
    NSString* _nickName;
    NSString* _domain;
    NSString* _location;
    NSString* _myStatus;
    NSString* _privateIp;
    NSString* _publicIp;
    NSString* _etcdServerPort;
    NSString* _etcdClientPort;
    NSString* _etcdHeartbeatTimeout;
    NSString* _etcdElectionTimeout;
    NSString* _etcdUserTTL;
    NSString* _artsmeshIOIp;
    NSString* _artsmeshIOPort;
    NSString* _machineName;
    NSString* _maxNode;
    NSString* _controlPort;
    NSString* _chatPort;
    
    
    NSTimer* _holePunchingTimer;
    NSTimer* _chatPeerTimer;
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
        self.isOnline = NO;
        self.etcdState = 0;
        self.myGroupName = @"Artsmesh";
    }
    
    return self;
}

-(void)getUserDefaults
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    _nickName =[defaults stringForKey:Preference_Key_User_NickName];
    _domain =[defaults stringForKey:Preference_Key_User_Domain];
    _location = [defaults stringForKey:Preference_Key_User_Location];
    _myStatus = [defaults stringForKey:Preference_Key_User_Status];
    _privateIp = [defaults stringForKey:Preference_Key_General_PrivateIP];
    _publicIp = [defaults stringForKey:Preference_Key_General_PublicIP];
    _etcdServerPort = [defaults stringForKey:Preference_Key_ETCD_ServerPort];
    _etcdClientPort = [defaults stringForKey:Preference_key_ETCD_ClientPort];
    _etcdHeartbeatTimeout = [defaults stringForKey:Preference_Key_ETCD_HeartbeatTimeout];
    _etcdElectionTimeout = [defaults stringForKey:Preference_Key_ETCD_ElectionTimeout];
    _etcdUserTTL = [defaults stringForKey:Preference_Key_ETCD_UserTTLTimeout];
    _artsmeshIOIp = [defaults stringForKey:Preference_Key_ETCD_ArtsmeshIOIP];
    _artsmeshIOPort = [defaults stringForKey:Preference_Key_ETCD_ArtsmeshIOPort];
    _machineName = [defaults stringForKey:Preference_Key_General_MachineName];
    _controlPort = [defaults stringForKey:Preference_Key_General_ControlPort];
    _chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
}

-(NSArray*) myGroupUsers
{
    NSArray *users = [self.usergroupDest getGroupUsers:self.myGroupName];
    return users ? users : @[];
}

-(void)startLoalMesher
{
    [self getUserDefaults];
    
    _elector = [[AMLeaderElecter alloc] init];
    _elector.mesherPort = [_etcdServerPort intValue];
    _communicator = [[AMCommunicator alloc] initWithPort:_controlPort];
    
    [_elector kickoffElectProcess];
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopLocalMesher
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                                        _nickName,
                                                        _domain,
                                                        _location];
    
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

-(void)everyoneGoOnline
{
    @synchronized(self.usergroupDest)
    {
        for (AMGroup* group in self.usergroupDest.userGroups)
        {
            if ([group.uniqueName isEqualToString:self.myGroupName])
            {
                for (AMUser* user in group.children)
                {
                    if (user.privateIp != nil && user.privateIp != nil)
                    {
                        [_communicator goOnlineCommand:user.privateIp port:user.controlPort];
                    }
                }
            }
        }
    }
    
    [self goOnline];
}

-(void)everyoneJoinGroup:(NSString *)groupName
{
    @synchronized(self.usergroupDest)
    {
        for (AMGroup* group in self.usergroupDest.userGroups)
        {
            if ([group.uniqueName isEqualToString:self.myGroupName])
            {
                for (AMUser* user in group.children)
                {
                    if (user.privateIp != nil && user.controlPort != nil)
                    {
                        [_communicator joinGroupCommand:groupName
                                                     ip:user.privateIp
                                                   port:user.controlPort];
                    }
                }
            }
        }
    }
}

-(void)goOnline
{
    if(self.etcdState != 1 || self.isOnline == YES)
    {
        return;
    }

    [[AMMesher sharedEtcdOperQueue] cancelAllOperations];
    
    @synchronized(self)
    {
        [self.usergroupDest clearUserGroup];
        
        [_dataSource stopWatch];
        _dataSource.ip   = _artsmeshIOIp;
        _dataSource.port = _artsmeshIOPort;
        [self addSelfToDataSource];
        
        self.isOnline = YES;
    }
}

-(void)goOffline
{
    if(self.etcdState != 1 || self.isOnline == NO)
    {
        return;
    }
    
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations];
    
    @synchronized(self)
    {
        NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                                            _nickName,
                                                            _domain,
                                                            _location];
        
        AMETCDDeleteUserOperation* delOper = [[AMETCDDeleteUserOperation alloc]
                                              initWithParameter:_dataSource.ip
                                              port:_dataSource.port
                                              fullUserName:fullUserName];
        
        [delOper start];

        [self.usergroupDest clearUserGroup];
        
        [_dataSource stopWatch];
        _dataSource.ip   = _privateIp;
        _dataSource.port = _etcdClientPort;
        [self addSelfToDataSource];
        
        self.isOnline = NO;
    }
}


-(void)joinGroup:(NSString*)groupName
{
    if([groupName isEqualToString:self.myGroupName])
    {
        return;
    }
    
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                                        _nickName,
                                                        _domain,
                                                        _location];
    
    NSString* groupNameKey = @"groupName";
    NSMutableDictionary* userPropties = [[NSMutableDictionary alloc] init];
    [userPropties setObject:groupName forKey:groupNameKey];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port:_dataSource.port
                                                 fullUserName:fullUserName
                                                 userProperties:userPropties];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
    self.myGroupName = groupName;
}

-(void)backToArtsmesh
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                                        _nickName,
                                                        _domain,
                                                        _location];
    
    NSString* groupNameKey = @"groupName";
    self.myGroupName = @"Artsmesh";
    
    NSMutableDictionary* userPropties = [[NSMutableDictionary alloc] init];
    [userPropties setObject:@"Artsmesh" forKey:groupNameKey];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port: _dataSource.port
                                                 fullUserName:fullUserName
                                                 userProperties:userPropties];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
    self.myGroupName = @"Artsmesh";
}

-(void)launchETCD
{
    NSString* peers =nil;
    if (!self.isLeader)
    {
        peers = [NSString stringWithFormat:@"%@:%d",  _elector.mesherIp, _elector.mesherPort];
    }

    AMETCDLaunchOperation* launchOper = [[AMETCDLaunchOperation alloc]
                                         initWithParameter:_privateIp
                                         clientPort:_etcdClientPort
                                         serverPort:_etcdServerPort
                                         peers:peers
                                         heartbeatInterval:_etcdHeartbeatTimeout
                                         electionTimeout:_etcdElectionTimeout];
    launchOper.delegate = self;
    
    AMETCDInitOperation* etcdInitOper = [[AMETCDInitOperation alloc]
                                         initWithEtcdServer:_privateIp
                                         port:_etcdClientPort];
    etcdInitOper.delegate = self;
    [etcdInitOper addDependency:launchOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:launchOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdInitOper];

}

-(void)addSelfToDataSource
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                                        _nickName,
                                                        _domain,
                                                        _location];
    
    AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                           initWithParameter: _dataSource.ip
                                           port:_dataSource.port
                                           fullUserName:fullUserName
                                           fullGroupName:self.myGroupName
                                           ttl:[_etcdUserTTL intValue]];
    
    NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
    [properties setObject: _privateIp forKey:@"privateIp"];
    [properties setObject: _publicIp forKey:@"publicIp"];
    [properties setObject: _controlPort forKey:@"controlPort"];
    [properties setObject: _chatPort forKey:@"chatPort"];
    [properties setObject: _myStatus forKey:@"description"];
    [properties setObject: _location forKey:@"location"];
    [properties setObject: _domain forKey:@"domain"];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port:_dataSource.port
                                                 fullUserName:fullUserName
                                                 userProperties:properties];
    
    AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                           initWithParameter:_privateIp
                                           port:_etcdClientPort
                                           fullUserName:fullUserName
                                           ttl:[_etcdUserTTL intValue]];
    
    addUserOper.delegate = self;
    updateUserOper.delegate = self;
    userTTLOper.delegate = self;
    
    [updateUserOper addDependency:addUserOper];
    [userTTLOper addDependency:updateUserOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
}

-(void)refreshMyTTL
{
    NSString* fullUserName = [NSString stringWithFormat:@"%@@%@.%@",
                                                        _nickName,
                                                        _domain,
                                                        _location];
    
    @synchronized(self)
    {
        AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                               initWithParameter:_dataSource.ip
                                               port:_dataSource.port
                                               fullUserName:fullUserName
                                               ttl:[_etcdUserTTL intValue]];
        
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
            NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
            
            if (self.etcdState == 0)
            {
                [self performSelectorOnMainThread:@selector(launchETCD)
                                       withObject:nil waitUntilDone:NO];
            }
        }
        else if(newState == 4)//Joined
        {
            self.isLeader = NO;
            NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
            
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
                           ip:_privateIp
                           port:_etcdClientPort];
            self.usergroupDest = [[AMETCDDataDestination alloc] init];
            
            [_dataSource addDestination:self.usergroupDest];
            [self addSelfToDataSource];
        }
    }
    else if([oper isKindOfClass:[AMETCDUserTTLOperation class]])
    {
        _userTTL = [NSTimer scheduledTimerWithTimeInterval:([_etcdUserTTL intValue]/3)
                                                    target:self
                                                  selector:@selector(refreshMyTTL)
                                                  userInfo:nil
                                                   repeats:NO];
    }
    else if([oper isKindOfClass:[AMETCDAddUserOperation class]])
    {
       [_dataSource watch];
    }
    else if([oper isKindOfClass:[AMETCDUpdateUserOperation class]])
    {
        
    }
}

@end
