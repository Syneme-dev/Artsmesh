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


@interface AMLocalMesher()<AMHeartBeatDelegate>
@end

@implementation AMLocalMesher
{
    NSOperationQueue* _httpRequestQueue;
    AMHeartBeat* _heartbeat;
    AMShellTask *_mesherServerTask;
    AMHeartBeat* _heartbeatThread;
    
    int _heartbeatFailureCount;
    int _userlistVersion;
}

-(id)init
{
    if (self = [super init]) {

        [[AMMesher sharedAMMesher] addObserver:self forKeyPath:@"clusterState"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
        
        //init NSOperationQueue
        _httpRequestQueue = [[NSOperationQueue alloc] init];
        _httpRequestQueue.name = @"LocalMesherQueue";
        _httpRequestQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
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
                case kClusterClientRegisting:
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
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"LocalServer"];
    lanchPath = [NSString stringWithFormat:@"\"%@\"",lanchPath];
    NSString *command = [NSString stringWithFormat:
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@ >/dev/null 2>&1",
                         lanchPath,
                         port,
                         port,
                         userTimeout];
    AMLog(kAMInfoLog, @"AMMesher", @"local server command is:%@", command);
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    [_mesherServerTask launch];
    
    sleep(2);
    
    [[AMMesher sharedAMMesher] setClusterState:kClusterClientRegisting];
}


-(void)stopLocalServer
{
    if (_mesherServerTask != nil){
        [_mesherServerTask cancel];
        _mesherServerTask = nil;
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
    AMLog(kAMInfoLog, @"AMMesher", @"registing group");
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    myGroup.leaderId = mySelf.userid;
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/register";
    req.httpMethod = @"POST";
    req.formData = [myGroup dictWithoutUsers];
    req.requestCallback = ^(NSData* response, NSError* error, BOOL cancel){
        if (cancel == YES) {
            return;
        }
        
        if (error != nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"error happened when register group:%@. will try again",
                  error.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                sleep(1);
                [self registerLocalGroup];
            });
            return;
        }
        
        if (response == nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"Fatal error, register group return value is nil");
            return;
        }
        
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AMLog(kAMInfoLog, @"AMMesher", @"register group succeeded. I'm leader now!");
                mySelf.isLeader = YES;
                [self registerSelf];
            });
            
        }else if([responseStr isEqualToString:@"group already exist"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                AMLog(kAMInfoLog, @"AMMesher", @"group already exist, will join.");
                mySelf.isLeader = NO;
                [self registerSelf];
            });
            
        }else{
            AMLog(kAMErrorLog, @"AMMesher", @"register group return wrong value");
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)registerSelf
{
    AMLog(kAMInfoLog, @"AMMesher", @"registing self to local group");
    
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
        
        if (error != nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"error happened when register group:%@",
                  error.description);
            return;
        }
        
        if(response == nil){
            AMLog(kAMErrorLog, @"AMMesher", @"response should not be nil without error");
            return;
        }
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AMLog(kAMInfoLog, @"AMMesher", @"register self to local server succeeded!");
                [[AMMesher sharedAMMesher] setClusterState:kClusterStarted];
                [self startHeartbeat];
            });
            
        }else if([responseStr isEqualToString:@"user already exist!"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                 AMLog(kAMErrorLog, @"AMMesher", @"register self to local server failed! Info:%@", responseStr);
                [[AMMesher sharedAMMesher] setClusterState:kClusterStarted];
                [self startHeartbeat];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                AMLog(kAMErrorLog, @"AMMesher", @"register self to local server failed! will retry");
                sleep(1);
                [self registerSelf];
            });
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)unregisterSelf{
    
    AMLog(kAMInfoLog, @"AMMesher", @"unregisting self from local server");
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    
    AMHttpSyncRequest* unregReq = [[AMHttpSyncRequest alloc] init];
    unregReq.baseURL = [self httpBaseURL];
    unregReq.requestPath = @"/users/unregister";
    unregReq.httpMethod = @"POST";
    unregReq.formData = @{@"userId": mySelf.userid};

    [unregReq sendRequest];
}


-(void)startHeartbeat
{
    if (_heartbeatThread) {
        [_heartbeatThread cancel];
    }
    
    AMLog(kAMInfoLog, @"AMMesher", @"starting send heartbeat");

    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    
    NSString* localServerAddr = config.localServerHost.address;
    NSString* localServerPort = config.localServerPort;
    BOOL useIpv6 = [config.useIpv6 boolValue];
    int HBTimeInterval = [config.localHeartbeatInterval intValue];
    int HBReceiveTimeout = [config.localHeartbeatRecvTimeout intValue];
    _heartbeatFailureCount = 0;
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: localServerAddr port:localServerPort ipv6:useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = HBTimeInterval;
    _heartbeatThread.receiveTimeout = HBReceiveTimeout;
    [_heartbeatThread start];
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
}


-(void)updateMyself
{
    AMLog(kAMInfoLog, @"AMMesher", @"updating myself infomation in local server");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGING_LOCAL];
    });
    
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
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)updateGroupInfo
{
    AMLog(kAMInfoLog, @"AMMesher", @"updating group infomation in local server");
    
    [[AMCoreData shareInstance] broadcastChanges:AM_MYGROUP_CHANGING_LOCAL];
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
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/getall";
    req.httpMethod = @"GET";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"error happened when request userlist:%@", error.description);
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
            
            _userlistVersion = [[result objectForKey:@"Version"] intValue];
            
            [[AMCoreData shareInstance] broadcastChanges:AM_LIVE_GROUP_CHANDED];
        });
    };

    [_httpRequestQueue addOperation:req];
}

- (NSString *)httpBaseURL
{
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSString* localServerAddr = config.localServerHost.address;
    NSString* localServerPort = config.localServerPort;
    
    return [NSString stringWithFormat:@"http://%@:%@", localServerAddr, localServerPort];
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
    _heartbeatFailureCount = 0;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error
{
    AMLog(kAMWarningLog, @"AMMesher", @"heartbeat to local server failed! %@", error.description);
    _heartbeatFailureCount ++;
    
    if (_heartbeatFailureCount > 5) {
        AMLog(kAMErrorLog, @"AMMesher", @"heartbeat to local server continue fail more than 5 times");
    }
}


@end
