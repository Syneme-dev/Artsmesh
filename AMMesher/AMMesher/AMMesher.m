//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMUser.h"
#import "AMGroup.h"
#import "AMLeaderElecter.h"
#import "AMTaskLauncher/AMShellTask.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMHeartBeat.h"
#import "AMSystemConfig.h"

@interface AMMesher()

@property AMUser* mySelf;
@property NSString* localLeaderName;
@property BOOL isLocalLeader;
@property BOOL isOnline;
@property NSArray* userGroups;
@property int userGroupsVersion;

@end

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMShellTask *_mesherServerTask;
    AMHeartBeat* _heartbeatThread;
    NSOperationQueue* _httpRequestQueue;
    AMSystemConfig* _systemConfig;
    BOOL _isNeedUpdateInfo;
    int _heartbeatFailureCount;
    dispatch_semaphore_t _heartbeatCancelSem;

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
        [self initUserGroups];
        [self initHttpReuestQueue];
    }
    
    return self;
}

-(void)loadUserProfile
{
    //TODO: load preference
    @synchronized(self){
        self.mySelf = [[AMUser alloc] init];
        self.mySelf.nickName = @"myNickName";
        self.mySelf.description = @"I love coffee";
        self.mySelf.privateIp = @"127.0.0.1";
        
        _isNeedUpdateInfo = YES;
    }
}

-(void)loadSystemConfig
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _systemConfig = [[AMSystemConfig alloc] init];
    //TODO: load system config from Preference
    
    _systemConfig.myServerPort = @"8080";
    _systemConfig.heartbeatInterval = @"2";
    _systemConfig.myServerUserTimeout = @"30";
    _systemConfig.maxHeartbeatFailure = @"5";
    _systemConfig.globalServerPort = @"8080";
    _systemConfig.globalServerAddr = @"localhost";
}

-(void)initUserGroups
{
    self.userGroups = [[NSMutableArray alloc] init];
    self.userGroupsVersion = 0;
}

-(void)initHttpReuestQueue{
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"Http Operation Queue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
}


-(void)startMesher
{
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
    if (_heartbeatThread)
    {
        _heartbeatCancelSem = dispatch_semaphore_create(0);
        [_heartbeatThread cancel];
        dispatch_semaphore_wait(_heartbeatCancelSem, DISPATCH_TIME_FOREVER);
    }
    
    
    if (_mesherServerTask)
    {
        [_mesherServerTask cancel];
        [self killAllAMServer];
    }
    
    if (_elector)
    {
        [_elector removeObserver:self forKeyPath:@"state"];
        [_elector stopElect];
    }
    
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
    if (_isOnline) {
        return;
    }
    
    [self stopMesher];
    
    @synchronized(self){
        _isNeedUpdateInfo = YES;
    }
    
     _isOnline = YES;
    
    [self startHearBeat:_systemConfig.globalServerAddr serverPort:_systemConfig.globalServerPort];
}

-(void)goOffline
{
    [self stopMesher];
    _isOnline = NO;
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
                         _systemConfig.myServerPort,
                         _systemConfig.myServerPort,
                         _systemConfig.myServerUserTimeout];
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

-(void)startHearBeat:(NSString*)addr serverPort:(NSString*)port
{
    if (_heartbeatThread) {
        [_heartbeatThread cancel];
    }
    
    _heartbeatFailureCount = 0;
    BOOL useIpv6 = NO;
    if (_systemConfig) {
        useIpv6 = _systemConfig.useIpv6;
    }

    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: addr port:port ipv6:useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = 2;
    _heartbeatThread.receiveTimeout = 5;
    [_heartbeatThread start];
}



#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    NSData* data ;
    @synchronized(self){
        AMUserUDPRequest* request = [[AMUserUDPRequest alloc] init];
        request.action = @"update";
        request.version = [NSString stringWithFormat:@"%d", self.userGroupsVersion];
        
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
    _heartbeatFailureCount = 0;
    
    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReceiveData:%@", jsonStr);
    
    AMUserUDPResponse* response = [AMUserUDPResponse responseFromJsonData:data];
    
    @synchronized(self){
        if ([response.contentMd5 isEqualToString:[self.mySelf md5String]]) {
            _isNeedUpdateInfo = NO;
        }
        
        if ([response.version intValue] >  self.userGroupsVersion) {
            NSLog(@"need download userlist");
        }
    }
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didSendData:(NSData *)data
{
    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didSendData:%@", jsonStr);
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error
{
    NSLog(@"didSendData:%@", error.description);
    
    _heartbeatFailureCount ++;
    if (_heartbeatFailureCount > [_systemConfig.maxHeartbeatFailure intValue]) {
        [self.delegate onMesherError:error];
    }
}

- (void)heartBeatDidCancel
{
    NSLog(@"heartbeat heartbeat thread canceled!");
    dispatch_semaphore_signal(_heartbeatCancelSem);
}

#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isEqualTo:_elector]){
        if ([keyPath isEqualToString:@"state"]){
            
            int oldState = [[change objectForKey:@"old"] intValue];
            int newState = [[change objectForKey:@"new"] intValue];
            NSLog(@" old state is %d", oldState);
            NSLog(@" new state is %d", newState);

            if(newState == 2){
                //I'm the leader
                NSLog(@"Mesher is %@:%@", _elector.serverName, _elector.serverPort);
                
                [self willChangeValueForKey:@"isLeader"];
                self.isLocalLeader = YES;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                self.localLeaderName = _elector.serverName;
                [self didChangeValueForKey:@"localLeaderName"];
                
                [self startLocalServer];
                [self startHearBeat:_elector.serverName serverPort:_elector.serverPort];
                
                self.isLocalLeader = YES;
                
            }else if(newState == 4){
                //Joined
                NSLog(@"Mesher is %@:%@", _elector.serverName, _elector.serverPort);
                
                [self willChangeValueForKey:@"isLeader"];
                self.isLocalLeader = NO;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                self.localLeaderName = _elector.serverName;
                [self didChangeValueForKey:@"localLeaderName"];
                
                [self startHearBeat:_elector.serverName serverPort:_elector.serverPort];
                
                self.isLocalLeader = NO;
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}
@end