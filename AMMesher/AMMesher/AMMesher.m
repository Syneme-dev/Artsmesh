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
    AMETCDDataDestination* _usergroupDest;
    NSTimer* _userTTL;
    
    NSString* _etcdServerPort;
    NSString* _etcdClientPort;
    NSString* _etcdHeartbeatTimeout;
    NSString* _etcdElectionTimeout;
    NSString* _etcdUserTTL;
    NSString* _artsmeshIOIp;
    NSString* _artsmeshIOPort;
    NSString* _machineName;
    NSString* _maxNode;
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
        self.mySelf = [[AMUser alloc] init];
    }
    
    return self;
}


-(void)getUserDefaults
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    _etcdServerPort = [defaults stringForKey:Preference_Key_ETCD_ServerPort];
    _etcdClientPort = [defaults stringForKey:Preference_key_ETCD_ClientPort];
    _etcdHeartbeatTimeout = [defaults stringForKey:Preference_Key_ETCD_HeartbeatTimeout];
    _etcdElectionTimeout = [defaults stringForKey:Preference_Key_ETCD_ElectionTimeout];
    _etcdUserTTL = [defaults stringForKey:Preference_Key_ETCD_UserTTLTimeout];
    _artsmeshIOIp = [defaults stringForKey:Preference_Key_ETCD_ArtsmeshIOIP];
    _artsmeshIOPort = [defaults stringForKey:Preference_Key_ETCD_ArtsmeshIOPort];
    _machineName = [defaults stringForKey:Preference_Key_General_MachineName];
    
    self.mySelf.groupName = @"Artsmesh";
    self.mySelf.domain =[defaults stringForKey:Preference_Key_User_Domain];
    self.mySelf.location = [defaults stringForKey:Preference_Key_User_Location];
    self.mySelf.uniqueName = [NSString stringWithFormat:@"%@@%@.%@",
                              [defaults stringForKey:Preference_Key_User_NickName],
                              self.mySelf.domain,
                              self.mySelf.location];
    self.mySelf.description = [defaults stringForKey:Preference_Key_User_Description];
    self.mySelf.privateIp = [defaults stringForKey:Preference_Key_General_PrivateIP];
    self.mySelf.controlPort = [defaults stringForKey:Preference_Key_General_ControlPort];
    self.mySelf.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];

}

-(NSArray*) myGroupUsers
{
    NSArray *users = [_usergroupDest getGroupUsers:self.mySelf.groupName];
    return users ? users : @[];
}

-(NSArray*)allGroupUsers
{
    return _usergroupDest.userGroups;
}

-(void)startLoalMesher
{
    [self getUserDefaults];
    
    _elector = [[AMLeaderElecter alloc] init];
    _elector.mesherPort = [_etcdServerPort intValue];
    _communicator = [[AMCommunicator alloc] initWithPort:self.mySelf.controlPort];
    
    [_elector kickoffElectProcess];
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopLocalMesher
{
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations ];
    
    @synchronized(self)
    {
        AMETCDDeleteUserOperation* delOper = [[AMETCDDeleteUserOperation alloc]
                                              initWithParameter:_dataSource.ip
                                              port:_dataSource.port
                                              fullUserName:self.mySelf.uniqueName];
        
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
    @synchronized(_usergroupDest)
    {
        for (AMGroup* group in _usergroupDest.userGroups)
        {
            if ([group.uniqueName isEqualToString:self.mySelf.groupName])
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
    @synchronized(_usergroupDest)
    {
        for (AMGroup* group in _usergroupDest.userGroups)
        {
            if ([group.uniqueName isEqualToString:self.mySelf.groupName])
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
        [_usergroupDest clearUserGroup];
        
        [_dataSource stopWatch];
        _dataSource.ip   = _artsmeshIOIp;
        _dataSource.port = _artsmeshIOPort;
        [self addSelfToDataSource];
        
        [self willChangeValueForKey:@"isOnline"];
        self.isOnline = YES;
        [self didChangeValueForKey:@"isOnline"];
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
        AMETCDDeleteUserOperation* delOper = [[AMETCDDeleteUserOperation alloc]
                                              initWithParameter:_dataSource.ip
                                              port:_dataSource.port
                                              fullUserName:self.mySelf.uniqueName];
        
        [delOper start];

        [_usergroupDest clearUserGroup];
        
        [_dataSource stopWatch];
        _dataSource.ip   = self.mySelf.privateIp;
        _dataSource.port = _etcdClientPort;
        [self addSelfToDataSource];
        
        self.isOnline = NO;
    }
}


-(void)joinGroup:(NSString*)groupName
{
    if([groupName isEqualToString:self.mySelf.groupName])
    {
        return;
    }
    
    NSString* groupNameKey = @"groupName";
    NSMutableDictionary* userPropties = [[NSMutableDictionary alloc] init];
    [userPropties setObject:groupName forKey:groupNameKey];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port:_dataSource.port
                                                 fullUserName:self.mySelf.uniqueName
                                                 userProperties:userPropties];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
    self.mySelf.groupName = groupName;
}

-(void)backToArtsmesh
{
    NSString* groupNameKey = @"groupName";
    NSMutableDictionary* userPropties = [[NSMutableDictionary alloc] init];
    [userPropties setObject:@"Artsmesh" forKey:groupNameKey];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port: _dataSource.port
                                                 fullUserName:self.mySelf.uniqueName
                                                 userProperties:userPropties];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
    self.mySelf.groupName= @"Artsmesh";

}

-(void)updateMySelfProperties:(NSDictionary*) properties
{
    if (self.etcdState != 1)
    {
        return;
    }

    for(NSString* key in properties)
    {
        id value = [properties valueForKey:key];
        [self.mySelf setValue:value forKey:key];
    }
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port: _dataSource.port
                                                 fullUserName:self.mySelf.uniqueName
                                                 userProperties:properties];
    
     [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
}

-(void)launchETCD
{
    NSString* peers =nil;
    if (!self.isLeader)
    {
        peers = [NSString stringWithFormat:@"%@:%d",  _elector.mesherIp, _elector.mesherPort];
    }

    AMETCDLaunchOperation* launchOper = [[AMETCDLaunchOperation alloc]
                                         initWithParameter:self.mySelf.privateIp
                                         clientPort:_etcdClientPort
                                         serverPort:_etcdServerPort
                                         peers:peers
                                         heartbeatInterval:_etcdHeartbeatTimeout
                                         electionTimeout:_etcdElectionTimeout];
    launchOper.delegate = self;
    
    AMETCDInitOperation* etcdInitOper = [[AMETCDInitOperation alloc]
                                         initWithEtcdServer:self.mySelf.privateIp
                                         port:_etcdClientPort];
    etcdInitOper.delegate = self;
    [etcdInitOper addDependency:launchOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:launchOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdInitOper];

}

-(void)addSelfToDataSource
{
    AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                           initWithParameter: _dataSource.ip
                                           port:_dataSource.port
                                           fullUserName:self.mySelf.uniqueName
                                           fullGroupName:self.mySelf.groupName
                                           ttl:[_etcdUserTTL intValue]];
    
    NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
    [properties setObject: self.mySelf.privateIp forKey:@"privateIp"];
    [properties setObject: self.mySelf.controlPort forKey:@"controlPort"];
    [properties setObject: self.mySelf.chatPort forKey:@"chatPort"];
    [properties setObject: self.mySelf.description forKey:@"description"];
    [properties setObject: self.mySelf.location forKey:@"location"];
    [properties setObject: self.mySelf.domain forKey:@"domain"];
    
    AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                 initWithParameter:_dataSource.ip
                                                 port:_dataSource.port
                                                 fullUserName:self.mySelf.uniqueName
                                                 userProperties:properties];
    
    AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                           initWithParameter:self.mySelf.privateIp
                                           port:_etcdClientPort
                                           fullUserName:self.mySelf.uniqueName
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
    @synchronized(self)
    {
        AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                               initWithParameter:_dataSource.ip
                                               port:_dataSource.port
                                               fullUserName:self.mySelf.uniqueName
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
    if ([object isEqualTo:_elector])
    {
        if ([keyPath isEqualToString:@"state"])
        {
            int oldState = [[change objectForKey:@"old"] intValue];
            int newState = [[change objectForKey:@"new"] intValue];
            
            NSLog(@" old state is %d", oldState);
            NSLog(@" new state is %d", newState);
            
            if(newState == 2)//Published
            {
                [self willChangeValueForKey:@"isLeader"];
                self.isLeader = YES;
                [self didChangeValueForKey:@"isLeader"];
                
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
    else if([object isEqualTo: _usergroupDest])
    {
         if ([keyPath isEqualToString:@"userGroups"])
         {
             //forward the KVO message
             [self willChangeValueForKey:@"myGroupUsers"];
             [self didChangeValueForKey:@"myGroupUsers"];
             [self willChangeValueForKey:@"allGroupUsers"];
             [self didChangeValueForKey:@"allGroupUsers"];
         }
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
        
        [self willChangeValueForKey:@"etcdState"];
        self.etcdState = 1;
        [self didChangeValueForKey:@"etcdState"];
        
        @synchronized(self)
        {
            _dataSource = [[AMETCDDataSource alloc]
                           init:@"data source"
                           ip:self.mySelf.privateIp
                           port:_etcdClientPort];
            
            if (_usergroupDest != nil)
            {
                [_usergroupDest removeObserver:self forKeyPath:@"userGroups"];
            }
            
            _usergroupDest = [[AMETCDDataDestination alloc] init];
            [_usergroupDest addObserver:self
                             forKeyPath:@"userGroups"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
            
            [_dataSource addDestination:_usergroupDest];
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
