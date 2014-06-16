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
#import "AMGroup.h"
#import "AMLeaderElecter.h"


NSString* const AM_LOCALUSERS_CHANGED = @"AM_LOCALUSERS_CHANGED";
NSString* const AM_REMOTEGROUPS_CHANGED = @"AM_REMOTEGROUPS_CHANGED";
NSString* const AM_MESHER_ONLINE= @"AM_MESHER_ONLINE";

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMSystemConfig* _systemConfig;
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
    mySelf.ip = [defaults stringForKey:Preference_Key_User_PrivateIp];
    mySelf.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    [AMAppObjects appObjects][AMMyselfKey] = mySelf;
    [AMAppObjects appObjects][AMClusterNameKey] = @"LocalGroup";
    [AMAppObjects appObjects][AMClusterIdKey] = [AMAppObjects creatUUID];
}

-(void)loadSystemConfig
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _systemConfig = [[AMSystemConfig alloc] init];
    _systemConfig.myServerPort = [defaults stringForKey:Preference_Key_General_LocalServerPort];
    _systemConfig.heartbeatInterval = @"2";
    _systemConfig.myServerUserTimeout = @"30";
    _systemConfig.maxHeartbeatFailure = @"5";
    _systemConfig.globalServerPort = [defaults stringForKey:Preference_Key_General_GlobalServerPort];
    _systemConfig.globalServerAddr = [defaults stringForKey:Preference_Key_General_GlobalServerAddr];
    _systemConfig.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    _systemConfig.stunServerAddr = [defaults stringForKey:Preference_Key_General_StunServerAddr];
    _systemConfig.stunServerPort = [defaults stringForKey:Preference_Key_General_StunServerPort];
    _systemConfig.useIpv6 = [[defaults stringForKey:Preference_Key_General_UseIpv6] boolValue];
}


-(void)startMesher
{
    if(_localMesher == nil){
        _localMesher = [[AMLocalMesher alloc] initWithServer:@"localhost" port:_systemConfig.myServerPort userTimeout:30 ipv6:_systemConfig.useIpv6];
    }
    
    if (_remoteMesher == nil) {
        //build remote mesher
    }
    
    if(_elector == nil){
        if (_systemConfig) {
            _elector = [[AMLeaderElecter alloc] initWithPort:_systemConfig.myServerPort];
        }
    }
    
    [_elector kickoffElectProcess];
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopMesher
{
    if (_elector)
    {
        [_elector removeObserver:self forKeyPath:@"state"];
        [_elector stopElect];
    }
    
    [_localMesher stopLocalClient];
    //[_localMesher stopLocalServer];
    
    //destroy remote mesher
    
    _elector = nil;
}


-(void)goOnline
{
    AMUser* mySelf = [[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSAssert(mySelf, @"my self is nil");
    
    if(mySelf.isOnline){
        return;
    }
    
    //start remote mesher
}

-(void)goOffline
{
    AMUser* mySelf = [[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSAssert(mySelf, @"my self is nil");
    if(!mySelf.isOnline){
        return;
    }
    
    //stop the remote mesher
}

-(void)mergeGroup:(NSString*)groupName
{
    //call remote mesher merge group
}


-(void)unmergeGroup
{
    //call remote mesher merge group
}

#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMLeaderElecter class]]){
        
        AMLeaderElecter* elector = (AMLeaderElecter*)object;
        
        if ([keyPath isEqualToString:@"state"]){
            
            int oldState = [[change objectForKey:@"old"] intValue];
            int newState = [[change objectForKey:@"new"] intValue];
            NSLog(@" old state is %d", oldState);
            NSLog(@" new state is %d", newState);
            
            if(newState == 2){
                //I'm the leader
                NSLog(@"Mesher is %@:%@", elector.serverName, elector.serverPort);
                
                [_localMesher startLocalServer];
                    sleep(1);
                [_localMesher startLocalClient];
                
            }else if(newState == 4){
                //Joined
                NSLog(@"Mesher is %@:%@", elector.serverName, elector.serverPort);
                [_localMesher startLocalClient];
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}





@end