//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMUser.h"
#import "AMLeaderElecter.h"
#import "AMTaskLauncher/AMShellTask.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMMesherOperationDelegate.h"
#import "AMRequestUserOperation.h"
#import "AMUpdateUserOperation.h"
#import "AMHeartBeat.h"

@implementation AMMesher
{
    //Mesher Server
    AMLeaderElecter* _elector;
    AMShellTask *_mesherServerTask;
    
    AMHeartBeat* _heartbeatThread;
    NSOperationQueue* _httpRequestQueue;
    
    AMSystemConfig* _systemConfig;

    int _userlistVersion;
    BOOL _isNeedUpdateInfo;
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
        _mySelf = [[AMUser alloc] init];
        _userlistVersion = 0;
        
        _httpRequestQueue = [[NSOperationQueue alloc] init];
        _httpRequestQueue.name = @"Http Operation Queue";
        _httpRequestQueue.maxConcurrentOperationCount = 1;

        [self loadUserProfile];
        [self loadSystemConfig];
        
    }
    
    return self;
}

-(void)loadUserProfile
{
    //TODO: load preference
    @synchronized(self){
        self.mySelf.nickName = @"myNickName";
        self.mySelf.description = @"I love coffee";
        
        _isNeedUpdateInfo = YES;
    }
}

-(void)loadSystemConfig
{
    _systemConfig = [[AMSystemConfig alloc] init];
    //TODO: load system config from Preference
}

-(void)startMesher
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mesherServerPort = [defaults stringForKey:Preference_Key_ETCD_ServerPort];
    
    //TODO:
    if (_elector == nil){
        _elector = [[AMLeaderElecter alloc] init];
        _elector.mesherPort = [_systemConfig.localServerUdpPort intValue];
    }
  
    [_elector kickoffElectProcess];
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopMesher
{
    if (_heartbeatThread)
        [_heartbeatThread cancel];
    
    if (_elector)
        [_elector stopElect];

    if (_mesherServerTask)
        [_mesherServerTask cancel];
    
    _heartbeatThread = nil;
    _elector = nil;
    _mesherServerTask = nil;
}


-(void)setMySelfPropties:(NSDictionary*)props
{
    @synchronized(self){
        for (NSString* key in props) {
            id value = [props valueForKey:key];
            [self.mySelf setValue:value forKey:key];
        }
        
        _isNeedUpdateInfo = YES;
    }
}

-(void)joinGroup:(NSString*)groupName
{
    @synchronized(self){
        [self.mySelf setValue:groupName forKey:@"groupName"];
        _isNeedUpdateInfo = YES;
    }
}

-(void)backToArtsmesh
{
    [self joinGroup:@""];
}

-(void)goOnline
{
    [self stopMesher];

    const char* globalHost = [_systemConfig.globalServerAddr UTF8String];
    const char* globalport = [_systemConfig.globalServerUdpPort UTF8String];
    
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: globalHost port:globalport ipv6:_systemConfig.isIpv6];
    _heartbeatThread.delegate = self;
    [_heartbeatThread start];
    
    @synchronized(self){
        _isNeedUpdateInfo = YES;
    }
    
    _isOnline = YES;
}

-(void)goOffline
{
    [self stopMesher];
    [self startMesher];
}


-(void)startLocalServer
{
    if (_mesherServerTask)
        [_mesherServerTask cancel];
    
    [self killAllAMServer];
    
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"amserver"];
    NSString *command = [NSString stringWithFormat:
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@",
                         lanchPath,
                         _systemConfig.localServerHttpPort,
                         _systemConfig.localServerUdpPort,
                         _systemConfig.userTimeout];
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    [_mesherServerTask launch];
    
    //Log Message, later will be remove or redirect to file
    NSFileHandle *inputStream = [_mesherServerTask fileHandlerForReading];
    inputStream.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        NSString* logStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", logStr);
    };

}

-(void)killAllAMServer
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"amserver", nil]];
}


#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    NSData* data ;
    @synchronized(self){
        AMUserUDPRequest* request = [[AMUserUDPRequest alloc] init];
        request.action = @"update";
        request.version = [NSString stringWithFormat:@"%d", _userlistVersion];
        
        if (_isNeedUpdateInfo) {
            request.contentMd5 = [self.mySelf md5String];
            request.userContent = self.mySelf;
        }
        data = [request jsonData];
    }
    
    return data;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didReceiveData:(NSData *)data
{
    
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didSendData:(NSData *)data
{
    
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error
{
    
}

#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context{
    
    if ([object isEqualTo:_elector]){
        if ([keyPath isEqualToString:@"state"]){
            
            int oldState = [[change objectForKey:@"old"] intValue];
            int newState = [[change objectForKey:@"new"] intValue];
            NSLog(@" old state is %d", oldState);
            NSLog(@" new state is %d", newState);

            if(newState == 2){
                //I'm the leader
                NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
                
                [self willChangeValueForKey:@"isLeader"];
                _isLeader = YES;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                _localLeaderName = _elector.mesherHost;
                [self didChangeValueForKey:@"localLeaderName"];
                
                [self startLocalServer];
                
                //TODO:
                
            }else if(newState == 4){
                //Joined
                NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
                
                [self willChangeValueForKey:@"isLeader"];
                _isLeader = NO;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                _localLeaderName = _elector.mesherHost;
                [self didChangeValueForKey:@"localLeaderName"];
                
                 //TODO:
                
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}
@end