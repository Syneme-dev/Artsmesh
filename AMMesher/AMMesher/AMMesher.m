//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMSystemConfig.h"
#import "AMRemoteMesher.h"
#import "AMLocalMesher.h"
#import "AMAppObjects.h"
#import "AMLeaderElecter.h"
#import "AMMesherStateMachine.h"


NSString* const AM_LOCALUSERS_CHANGED = @"AM_LOCALUSERS_CHANGED";
NSString* const AM_REMOTEGROUPS_CHANGED = @"AM_REMOTEGROUPS_CHANGED";
NSString* const AM_MESHER_ONLINE_CHANGED= @"AM_MESHER_ONLINE_CHANGED";

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMLocalMesher* _localMesher;
    AMRemoteMesher* _remoteMesher;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}

+(id)sharedAMMesher
{
    static AMMesher* sharedMesher = nil;
    @synchronized(self){
        if (sharedMesher == nil){
            sharedMesher = [[self alloc] initMesher];
        }
    }
    return sharedMesher;
}


-(id)initMesher
{
    if (self = [super init]){
        [self loadUserProfile];
        [self loadSystemConfig];
        [self initCluster];
        [self initMesherStateMachine];
        [self initComponents];
    }
    
    return self;
}

-(void)loadUserProfile
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    AMUser* mySelf = [[AMUser alloc] init];
    mySelf.nickName = [defaults stringForKey:Preference_Key_User_NickName];
    mySelf.domain = [defaults stringForKey:Preference_Key_User_Domain];
    mySelf.location = [defaults stringForKey:Preference_Key_User_Location];
    mySelf.description = [defaults stringForKey:Preference_Key_User_Description];
    mySelf.privateIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
    mySelf.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    [AMAppObjects appObjects][AMMyselfKey] = mySelf;
}

-(void)loadSystemConfig
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    AMSystemConfig* config = [[AMSystemConfig alloc] init];
    config.globalServerPort = [defaults stringForKey:Preference_Key_General_GlobalServerPort];
    config.globalServerAddr = [defaults stringForKey:Preference_Key_General_GlobalServerAddr];
    config.stunServerAddr = [defaults stringForKey:Preference_Key_General_StunServerAddr];
    config.stunServerPort = [defaults stringForKey:Preference_Key_General_StunServerPort];
    config.myServerPort = [defaults stringForKey:Preference_Key_General_LocalServerPort];
    config.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    config.heartbeatInterval = @"2";
    config.heartbeatRecvTimeout = @"5";
    config.myServerUserTimeout = @"30";
    config.maxHeartbeatFailure = @"5";
    config.useIpv6 = [[defaults stringForKey:Preference_Key_General_UseIpv6] boolValue];
    [[AMAppObjects appObjects] setObject:config forKey:AMSystemConfigKey];
}

-(void)initCluster{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [AMAppObjects appObjects][AMClusterNameKey] = [defaults stringForKey:Preference_Key_Cluster_Name];
    [AMAppObjects appObjects][AMClusterIdKey] = [AMAppObjects creatUUID];
    [AMAppObjects appObjects][AMMergedGroupIdKey] = [AMAppObjects appObjects][AMClusterIdKey];
}

-(void)initMesherStateMachine
{
    AMMesherStateMachine* machine = [[AMMesherStateMachine alloc] init];
    machine.mesherState = kMesherInitialized;
    [machine addObserver:self forKeyPath:@"mesherState"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(computerWillSleep:) name:NSWorkspaceWillSleepNotification object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(computerDidWakeup:) name:NSWorkspaceDidWakeNotification object:nil];
    
    [[AMAppObjects appObjects] setObject:machine forKey:AMMesherStateMachineKey];

}

-(void) initComponents{
    
    if(_localMesher == nil){
        _localMesher = [[AMLocalMesher alloc] init];
    }
    
    if (_remoteMesher == nil) {
        _remoteMesher = [[AMRemoteMesher alloc] init];
    }
    
    if(_elector == nil){
        _elector = [[AMLeaderElecter alloc] init];
    }
}

-(void)computerWillSleep:(NSNotification*)notification
{
    [self stopMesher];
}

-(void)computerDidWakeup:(NSNotification*)notification
{
    [self startMesher];
}


-(void)startMesher
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if ([machine mesherState] != kMesherInitialized) {
        return;
    }
    
    AMMesherStateMachine* stateMachine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    [stateMachine setMesherState:kMesherStarting];
}

-(void)stopMesher
{
    AMMesherStateMachine* stateMachine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    [stateMachine setMesherState:kMesherStopping];
    
    [stateMachine removeObserver:self forKeyPath:@"mesherState"];
}


-(void)goOnline
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if ([machine mesherState] != kMesherStarted) {
        return;
    }
    
    AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
    mySelf.isOnline = YES;
    
    [machine setMesherState:kMesherMeshing];
}

-(void)goOffline
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if ([machine mesherState] < kMesherMeshed || [machine mesherState] >= kMesherStopping){
        return;
    }
    
    AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
    mySelf.isOnline = NO;
    
    [machine setMesherState:kMesherUnmeshing];
}


-(void)mergeGroup:(NSString*)superGroupId
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if ([machine mesherState] != kMesherMeshed){
        return;
    }
    
    [_remoteMesher mergeGroup:superGroupId];
}


-(void)unmergeGroup
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if ([machine mesherState] != kMesherMeshed){
        return;
    }
    
    [_remoteMesher unmergeGroup];
}

-(void)changeLocalGroupName:(NSString*)newGroupName
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if ([machine mesherState] != kMesherStarted){
        return;
    }
    
    [_localMesher changeGroupName:newGroupName];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newGroupName forKey:Preference_Key_Cluster_Name];
    [[AMAppObjects appObjects] setObject:newGroupName forKey:AMClusterNameKey ];
}

-(void)updateMySelf
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if ([machine mesherState] == kMesherStarted)
    {
        [_localMesher updateMyselfInfo];
        
    }else if([machine mesherState] == kMesherMeshed){
        
        [_localMesher updateMyselfInfo];
        [_remoteMesher updateMyselfInfo];
    }
    
}


#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMMesherStateMachine class]]){
    
        if ([keyPath isEqualToString:@"mesherState"]){
        
//            AMMesherState oldState = [[change objectForKey:@"old"] intValue];
//            AMMesherState newState = [[change objectForKey:@"new"] intValue];
            
        }
    }
}





@end