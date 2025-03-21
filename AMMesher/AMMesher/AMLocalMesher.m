//
//  AMLocalMesher.m
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLocalMesher.h"
#import "AMHeartBeat.h"
#import "AMLeaderElecter.h"
#import "AMTaskLauncher/AMShellTask.h"
#import "AMMesher.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMCoreData/AMCoreData.h"
#import "AMLogger/AMLogger.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

NSString * const AMLocalHeartbeatFailNotification        = @"AMLocalHeartbeatFailNotification";
NSString * const AMLocalHeartbeatDisconnectNotification  = @"AMLocalHeartbeatDisconnectNotification";
NSString * const AMLocalHeartbeatNotification            =
@"AMLocalHeartbeatNotification";

#define MAX_RETRY_COUNT 3


@interface AMLocalMesher()<AMHeartBeatDelegate>
@end

@implementation AMLocalMesher
{
    NSOperationQueue* _httpRequestQueue;
    AMHeartBeat* _heartbeat;
    AMShellTask *_mesherServerTask;
    AMHeartBeat* _heartbeatThread;
    
    NSTask *_lsTask;
    
    int _heartbeatFailureCount;
    int _userlistVersion;
    
    int  _retryCount;
    
    NSString *_tryLocalServerAddr;
    NSString *_usedLocalServerAddr;
}

-(id)init
{
    if (self = [super init]) {
        
        [[AMMesher sharedAMMesher] addObserver:self forKeyPath:@"clusterState"
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
        
        [self initNSOperationQueue];
    }
    
    return self;
}

-(void)initNSOperationQueue {
    //init NSOperationQueue
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"LocalMesherQueue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
    _retryCount = 0;
}


#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMMesher class]]){
        
        if ([keyPath isEqualToString:@"clusterState"]){
            AMClusterState newState = [[change objectForKey:@"new"] intValue];
            
            switch (newState) {
                case kClusterServerStarting:
                    [self startLocalServer];
                    break;
                case kClusterClientRegistering:
                    [self startLocalClient];
                    break;
                case kClusterStopping:
                    [self stopLocalServer];
                    [self stopLocalClient];
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark -
#pragma   mark Functions

-(void)startLocalServer
{
    [self stopLocalServer];
    
    AMLog(kAMInfoLog, @"AMMesher", @"starting local mesher server...");
    
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSString* port = config.localServerPort;
    NSString* userTimeout = config.serverHeartbeatTimeout;
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* launchPath =[mainBundle pathForAuxiliaryExecutable:@"LocalServer"];
    launchPath = [NSString stringWithFormat:@"\"%@\"",launchPath];
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@ ipv6 > %@/AMServer.log",
                                launchPath,
                                port,
                                port,
                                userTimeout,
                                AMLogDirectory()];
    AMLog(kAMInfoLog, @"AMMesher", @"local server command is:%@", command);
    
    _lsTask = [[NSTask alloc] init];
    _lsTask.launchPath = @"/bin/bash";
    _lsTask.arguments = @[@"-c", [command copy]];
    _lsTask.terminationHandler = ^(NSTask* t){
        
    };
    
    sleep(2);
    
    [_lsTask launch];
    
    
    [[AMMesher sharedAMMesher] setClusterState:kClusterClientRegistering];
}


-(void)stopLocalServer
{
    if (_lsTask) {
        [_lsTask terminate];
        _lsTask = nil;
    }
    
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"LocalServer", nil]];
}


-(void)startLocalClient
{
    [self registerLocalGroup];
}


-(void)registerLocalGroup
{
    AMLog(kAMInfoLog, @"AMMesher", @"registering group to local server.");
    
    // Load in user Config Options
    AMSystemConfig *config = [AMCoreData shareInstance].systemConfig;
    
    NSString *LSConfig = [[NSUserDefaults standardUserDefaults] stringForKey:Preference_Key_Cluster_LSConfig];
    _tryLocalServerAddr = LSConfig;
    
    if ([_tryLocalServerAddr isEqualToString:@"SELF"] || [_tryLocalServerAddr isEqualToString:@"DISCOVER"]) {
        
    // Find IPV4 or IPV6 Addresses for found Bonjour Service, depending on user preference
    NSArray *localServerIps = [[NSArray alloc] initWithArray:[config.localServerHost addresses]];
    NSMutableArray *localServerIpv4s = [[NSMutableArray alloc] init];
    NSMutableArray *localServerIpv6s = [[NSMutableArray alloc] init];
    for (NSString *IpAddress in localServerIps) {
        if ([AMCommonTools isValidGlobalIpv6:IpAddress]) {
            [localServerIpv6s addObject:IpAddress];
        } else if ([AMCommonTools isValidIpv4:IpAddress]) {
            [localServerIpv4s addObject:IpAddress];
        }
    }
    NSMutableArray *preferredIps = [[NSMutableArray alloc] initWithArray:localServerIpv4s];
    if (config.meshUseIpv6 && [localServerIpv6s count] > 0) {
        [preferredIps removeAllObjects];
        preferredIps = localServerIpv6s;
    }
    
    // Determine an IP Address to try for group registration
    if(_retryCount < [preferredIps count]){
        _tryLocalServerAddr = [preferredIps objectAtIndex:_retryCount];
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:AM_LOCAL_SERVER_CONNECTION_ERROR object:nil];
        return;
    }
    
    _retryCount ++;
    
    }
    
    //Start registering
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    myGroup.leaderId = mySelf.userid;
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    if (config.meshUseIpv6) {
        req.baseURL = [NSString stringWithFormat:@"http://[%@]:%@", _tryLocalServerAddr, config.localServerPort];
    } else {
        req.baseURL = [NSString stringWithFormat:@"http://%@:%@", _tryLocalServerAddr, config.localServerPort];
    }
    req.requestPath = @"/groups/register";
    req.httpMethod = @"POST";
    req.delay = 2;
    req.formData = [myGroup dictWithoutUsers];
    req.requestCallback = ^(NSData* response, NSError* error, BOOL cancel){
        if (cancel == YES) {
            return;
        }
        
        BOOL needRetry = NO;
        
        do{
            if (error != nil) {
                needRetry = YES;
                if ([self checkLSConfigIsManual]) {
                    needRetry = NO;
                } else {
                    AMLog(kAMErrorLog, @"AMMesher", @"error happened when register group:%@. will try again",  error.description);
                }
                
                break;
            }
            
            if(response == nil){
                AMLog(kAMErrorLog, @"AMMesher", @"Fatal error, register group return value is nil");
                needRetry = YES;
                break;
            }
            
            NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            if ([responseStr isEqualToString:@"ok"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _retryCount = 0;
                    _usedLocalServerAddr = _tryLocalServerAddr;
                    AMLog(kAMInfoLog, @"AMMesher", @"register group succeeded. I'm leader now!");
                    mySelf.isLeader = YES;
                    [self registerSelf];
                });
            }else if([responseStr isEqualToString:@"group already exist"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _retryCount = 0;
                    _usedLocalServerAddr = _tryLocalServerAddr;
                    AMLog(kAMInfoLog, @"AMMesher", @"group already exist, will join.");
                    mySelf.isLeader = NO;
                    [self registerSelf];
                });
            }else{
                AMLog(kAMErrorLog, @"AMMesher", @"register group return wrong value");
                needRetry = YES;
            }
            
        }while (NO);
        
        
        if(needRetry){
            sleep(1);
            dispatch_async(dispatch_get_main_queue(), ^{
                AMLog(kAMErrorLog, @"AMMesher", @"register self to local server failed! will retry");
                [self registerLocalGroup];

            });
        }
    };
    
    AMLog(kAMInfoLog, @"AMMesher", @"registering group url is:%@",req.baseURL);
    
    if (![_httpRequestQueue.name isEqualToString:@"LocalMesherQueue"]) {
        [self initNSOperationQueue];
    }
    [_httpRequestQueue addOperation:req];
    
}


-(void)registerSelf
{
    
    AMLog(kAMInfoLog, @"AMMesher", @"registering self to local group");
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSMutableDictionary* dict = [mySelf toDict];
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/register";
    req.httpMethod = @"POST";
    req.formData = dict;
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        BOOL needRetry = NO;
        
        do{
            if (error != nil) {
                AMLog(kAMErrorLog, @"AMMesher", @"error happened when register self:%@", error.description);
                
                needRetry = YES;
                break;
            }
            
            if(response == nil){
                AMLog(kAMErrorLog, @"AMMesher", @"response should not be nil without error");
                needRetry = YES;
                break;
            }
            
            NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            if ([responseStr isEqualToString:@"ok"] || [responseStr isEqualToString:@"user already exist!"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _retryCount = 0;
                    AMLog(kAMInfoLog, @"AMMesher", @"register self to local server succeeded!");
                    [[AMMesher sharedAMMesher] setClusterState:kClusterStarted];
                    [self startHeartbeat];
                });
            }else{
                needRetry = YES;
                break;
            }
            
        }while (NO);
        
        
        if(needRetry){
            sleep(1);
            dispatch_async(dispatch_get_main_queue(), ^{
                AMLog(kAMErrorLog, @"AMMesher", @"register self to local server failed! will retry");
                [self registerSelf];
            });
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)unregisterSelf{
    
    if ([_usedLocalServerAddr length] > 0) {
        AMLog(kAMInfoLog, @"AMMesher", @"unregistering self from local server");
        AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    
        AMHttpSyncRequest* unregReq = [[AMHttpSyncRequest alloc] init];
        unregReq.baseURL = [self httpBaseURL];
        unregReq.requestPath = @"/users/unregister";
        unregReq.httpMethod = @"POST";
        unregReq.formData = @{@"userId": mySelf.userid};
    
        [unregReq sendRequest];
    }
}


-(void)startHeartbeat
{
    if (_heartbeatThread) {
        [_heartbeatThread cancel];
    }
    
    AMLog(kAMInfoLog, @"AMMesher", @"starting send heartbeat");
    
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSString* localServerPort = config.localServerPort;
    
    BOOL useIpv6 = config.heartbeatUseIpv6;
    int HBTimeInterval = [config.localHeartbeatInterval intValue];
    int HBReceiveTimeout = [config.localHeartbeatRecvTimeout intValue];
    _heartbeatFailureCount = 0;
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: _usedLocalServerAddr port:localServerPort ipv6:useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = HBTimeInterval;
    _heartbeatThread.receiveTimeout = HBReceiveTimeout;
    [_heartbeatThread start];
    
    //At this point, we're locally meshed, so let the rest of the Application know
    NSNotification* notification = [[NSNotification alloc]
                                    initWithName: AM_LOCAL_MESHER_MESHED_NOTIFICATION
                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)stopLocalClient
{
    AMLog(kAMInfoLog, @"AMMesher", @"will stop local server");
    
    if (_heartbeatThread){
        [_heartbeatThread cancel];
    }
    
    if (_httpRequestQueue) {
        [_httpRequestQueue  cancelAllOperations];
        
        [self unregisterSelf];
    }
    
    _httpRequestQueue = nil;
    _heartbeatThread = nil;
    
    [[AMMesher sharedAMMesher] setClusterState:kClusterStopped];
    
    NSNotification* notification = [[NSNotification alloc]
                                    initWithName: AM_MESHER_STOPPED_NOTIFICATION
                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)updateMyself
{
    AMLog(kAMInfoLog, @"AMMesher", @"updating myself infomation in local server");
    
    if([[AMMesher sharedAMMesher] clusterState] != kClusterStarted){
        return;
    }
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/update";
    req.formData = [mySelf toDict];
    req.httpMethod = @"POST";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"error happened when update self:%@", error.description);
            return;
        }
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            AMLog(kAMErrorLog, @"AMMesher", @"update self failed: %@", responseStr);
            return;
        }
        
        AMLog(kAMInfoLog, @"AMMesher", @"updating myself infomation in local server finished");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:AM_MYSELF_CHANGED_LOCAL object:nil userInfo:nil];
        });
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)updateGroupInfo
{
    AMLog(kAMInfoLog, @"AMMesher", @"updating group infomation in local server");
    
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/update";
    req.formData = [localGroup dictWithoutUsers];
    req.httpMethod = @"POST";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"error happened when update group:%@", error.description);
            return;
        }
        
        if (response == nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"update group return nil");
            return;
        }
        
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            
            AMLog(kAMErrorLog, @"AMMesher", @"update group failed: %@", responseStr);
            return;
        }
        
        AMLog(kAMInfoLog, @"AMMesher", @"updating group infomation in local server finished");
        
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)requestUserList
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/getall";
    req.formData = @{@"userId": mySelf.userid};
    req.httpMethod = @"POST";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"error happened when request userlist:%@", error.description);
            
            [[AMMesher sharedAMMesher] stopMesher];
            [[AMMesher sharedAMMesher] startMesher];
            AMLog(kAMInfoLog, @"Main", @"Loading live groups.");
            
            return;
        }
        
        if (response == nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"request userlist from local server return nil");
            return;
        }
        
        NSError *err = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:response options:0 error:&err];
        if(err != nil){
            AMLog(kAMErrorLog, @"AMMesher", @"userlist from local server Json error:%@", err.description);
            return;
        }
        
        NSDictionary* result = (NSDictionary*)objects;
        
        NSDictionary* groupData = (NSDictionary*)result[@"GroupData"];
        if([groupData isEqual:[NSNull null]]){
            AMLog(kAMErrorLog, @"AMMesher", @"group returned from local server is null");
            return;
        }
        
        AMLiveGroup* group = [AMLiveGroup AMGroupFromDict:groupData];
        
        id userArr = [result objectForKey:@"UsersData"];
        if (userArr == [NSNull null]) {
            userArr = nil;
        }
        
        NSMutableArray* users = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [userArr count]; i++)
        {
            NSDictionary* userDict = (NSDictionary*)userArr[i];
            AMLiveUser* user = [AMLiveUser AMUserFromDict:userDict];
            [users addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
            localGroup.groupId = group.groupId;
            localGroup.groupName = group.groupName;
            localGroup.description = group.description;
            localGroup.location = group.location;
            localGroup.longitude = group.longitude;
            localGroup.latitude = group.latitude;
            localGroup.fullName = group.fullName;
            localGroup.project = group.project;
            localGroup.leaderId = group.leaderId;
            localGroup.users = users;
            localGroup.projectDescription = group.projectDescription;
            localGroup.homePage = group.homePage;
            localGroup.broadcasting = group.broadcasting;
            localGroup.broadcastingURL = group.broadcastingURL;
            
            _userlistVersion = [[result objectForKey:@"Version"] intValue];
            
            [[AMCoreData shareInstance] broadcastChanges:AM_LIVE_GROUP_CHANDED];
        });
    };
    
    [_httpRequestQueue addOperation:req];
}


- (NSString *)httpBaseURL
{
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSString* localServerPort = config.localServerPort;
    NSString *httpUrl = [[NSString alloc] init];
    if (config.meshUseIpv6){
        httpUrl = [NSString stringWithFormat:@"http://[%@]:%@", _usedLocalServerAddr, localServerPort];
    } else {
        httpUrl = [NSString stringWithFormat:@"http://%@:%@", _usedLocalServerAddr, localServerPort];
    }
    AMLog(kAMInfoLog, @"AMMesher", @"now used url is:%@", httpUrl);
    
    return httpUrl;
}


-(BOOL)checkLSConfigIsManual {
    
    BOOL LSConfigIsManual = false;
    
    //AMMesher *curMesher = [AMMesher sharedAMMesher];
    NSString *LSConfig = [[NSUserDefaults standardUserDefaults] stringForKey:Preference_Key_Cluster_LSConfig];
    _tryLocalServerAddr = LSConfig;
    
    if (![LSConfig isEqualToString:@"SELF"] && ![LSConfig isEqualToString:@"DISCOVER"]) {
        LSConfigIsManual = true;
        
        AMLog(kAMErrorLog, @"AMMesher", @"Could not connect to manually selected IP. User is either not meshed or is meshed on a different port.");
        AMLog(kAMErrorLog, @"AMMesher", @"If problems persist, switch to Discover mode, and try again.");
        
        //[[NSUserDefaults standardUserDefaults] setObject:@"DISCOVER" forKey:Preference_Key_Cluster_LSConfig];
        [self stopLocalClient];
        //[curMesher stopMesher];
        //[curMesher startMesher];
    }
    
    return LSConfigIsManual;
}


#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    
    NSMutableDictionary* localHeartbeatReq = [[NSMutableDictionary alloc] init];
    [localHeartbeatReq setObject:mySelf.userid forKey:@"UserId"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:localHeartbeatReq options:0 error:nil];
    return data;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didReceiveData:(NSData *)data
{
    _heartbeatFailureCount = 0;
    NSError *error = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&error];
    if (error != nil) {
        AMLog(kAMErrorLog, @"AMMesher", @"heartbeat from local server JSON error %@", error.description);
        return;
    }
    
    NSDictionary* result = (NSDictionary*)objects;
    int version = [[result objectForKey:@"Version"] intValue];
    
    if (version != _userlistVersion){
        AMLog(kAMInfoLog, @"AMMesher", @"userlist version is old, will get a new version");
        [self requestUserList];
    }
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didSendData:(NSData *)data
{
    //_heartbeatFailureCount = 0;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:AMLocalHeartbeatNotification
     object:self];
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error
{
    AMLog(kAMWarningLog, @"AMMesher", @"heartbeat to local server failed! %@", error.description);
    _heartbeatFailureCount ++;
    
    if (_heartbeatFailureCount >= 5) {
        AMLog(kAMErrorLog, @"AMMesher", @"heartbeat to local server"
              "continue fail more than 5 times");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AMLocalHeartbeatDisconnectNotification
         object:self];
        
        if (_heartbeatFailureCount % 5 == 0) {
            [self requestUserList];
        }
    } else {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AMLocalHeartbeatFailNotification
         object:self];
    }
    
}


@end
