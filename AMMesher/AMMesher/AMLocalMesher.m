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
#import "AMAppObjects.h"
#import "AMMesher.h"
#import "AMMesherStateMachine.h"
#import "AMSystemConfig.h"
#import "AMHttpAsyncRequest.h"
#import "AMHttpSyncRequest.h"


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

        //add observer to mesher state machine
        AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
        NSAssert(machine, @"mesher state machine should not be nil!");
        
        [machine addObserver:self forKeyPath:@"mesherState"
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
    if ([object isKindOfClass:[AMMesherStateMachine class]]){
        
        if ([keyPath isEqualToString:@"mesherState"]){
            
            AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
            
            //AMMesherState oldState = [[change objectForKey:@"old"] intValue];
            AMMesherState newState = [[change objectForKey:@"new"] intValue];
            
            switch (newState) {
                case kMesherLocalServerStarting:
                    [self startLocalServer];
                    //[self startLocalClient];
                    break;
                case kMesherLocalClientStarting:
                    [self startLocalClient];
                    break;
                case kMesherMeshed:
                    [self updateMyself];
                    break;
                case kMesherUnmeshing:
                    [self updateMyself];
                    [machine setMesherState:kMesherStarted];
                    break;
                case kMesherStopping:
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
    
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey ];
    NSAssert(config, @"system config can not be nil!");
    NSString* port = config.localServertPort;
    NSString* userTimeout = config.myServerUserTimeout;

    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"LocalServer"];
    NSString *command = [NSString stringWithFormat:
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@ >LocalServer.log 2>&1",
                         lanchPath,
                         port,
                         port,
                         userTimeout];
    //system("say \"Now I'm the leader and my host name is `hostname`\"");
    
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    NSLog(@"command is %@", command);
    [_mesherServerTask launch];
    
    sleep(2);
    
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine should not be nil!");
    
    [machine setMesherState:kMesherLocalClientStarting];
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
    AMUser* mySelf = [AMAppObjects appObjects][AMMyselfKey];
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
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
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                mySelf.isLeader = YES;
                [self registerSelf];
            });
            
        }else if([responseStr isEqualToString:@"group aleady register"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                mySelf.isLeader = NO;
                [self getLocalGroupInfo];
            });
            
        }else{
            NSAssert(NO, @"local http request wrong!");
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)getLocalGroupInfo
{
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/getall";
    req.httpMethod = @"GET";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            NSLog(@"error happened when get group info:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AMGroup* group = [AMGroup AMGroupFromDict:(NSDictionary*)response];
            AMGroup* localGroup =[AMAppObjects appObjects][AMLocalGroupKey];
            
            //should no need synchronized, because in main loop
            // @synchronized(localGroup){
            localGroup.groupName = group.groupName;
            localGroup.description = group.description;
            localGroup.leaderId = group.leaderId;
            //}
            
            [self registerSelf];
        });
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)registerSelf
{
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSMutableDictionary* dict = [mySelf toDict];
    [dict setObject:myGroup.groupId forKey:@"groupId"];
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/user/register";
    req.httpMethod = @"POST";
    req.formData = dict;
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
                [machine setMesherState:kMesherStarted];
                [self startHeartbeat];
            });
            
        }else{
            NSAssert(NO, @"register self on local server response wrong!");
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)unregisterSelf{
    
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    
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
    
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey ];
    NSAssert(config, @"system config can not be nil!");
    
    NSString* localServerAddr = config.localServerAddr;
    NSString* localServerPort = config.localServertPort;
    BOOL useIpv6 = config.useIpv6;
    int HBTimeInterval = [config.heartbeatInterval intValue];
    int HBReceiveTimeout = [config.heartbeatRecvTimeout intValue];
    
    _heartbeatFailureCount = 0;
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: localServerAddr port:localServerPort ipv6:useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = HBTimeInterval;
    _heartbeatThread.receiveTimeout = HBReceiveTimeout;
    [_heartbeatThread start];
}


-(void)stopLocalClient
{
    if (_heartbeatThread){
        [_heartbeatThread cancel];
    }
    
    if (_httpRequestQueue) {
        [_httpRequestQueue  cancelAllOperations];
        [self unregisterSelf];
    }
    
    _httpRequestQueue = nil;
    _heartbeatThread = nil;
    
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    [machine setMesherState:kMesherStopped];
}


-(void)updateLocalGroup
{
    AMGroup* localGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    NSAssert(localGroup, @"local group should not be nil");
    
    NSMutableDictionary* dict = [localGroup dictWithoutUsers];
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/update";
    req.httpMethod = @"POST";
    req.formData = dict;
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            NSAssert(NO, @"update group info response wrong!");
        }
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)changeGroupPassword:(NSString*)newPassword password:(NSString*)oldPassword
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    AMMesherState mState = [machine mesherState];
    if (mState < kMesherStarted ){
        return;
    }
    
    AMGroup* localGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"password"] = oldPassword;
    dict[@"newPasswrod"] = newPassword;
    dict[@"groupId"] = localGroup.groupId;
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/change_password";
    req.formData = dict;
    req.httpMethod = @"POST";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            NSAssert(NO, @"update group password response wrong!");
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)updateMyself
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if([machine mesherState] < kMesherStarted  || [machine mesherState] >= kMesherStopping){
        return;
    }
    
    AMUser* mySelf = [AMAppObjects appObjects][AMMyselfKey];
    
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
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            NSAssert(NO, @"update user info response wrong!");
        }
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
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        NSLog(@"getall users return........................");
        
        NSError *err = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:response options:0 error:&err];
        if(err != nil){
            NSString* errInfo = [NSString stringWithFormat:@"parse Json error:%@", err.description];
            NSAssert(NO, errInfo);
        }
        
        NSDictionary* result = (NSDictionary*)objects;
        AMGroup* group = [AMGroup AMGroupFromDict:result];
        
        id userArr = [result objectForKey:@"UserDTOs"];
        if (userArr == [NSNull null]) {
            userArr = nil;
        }
        
        NSMutableArray* users = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [userArr count]; i++)
        {
            NSDictionary* userDict = (NSDictionary*)userArr[i];
            AMUser* user = [AMUser AMUserFromDict:userDict];
            [users addObject:user];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            AMGroup* localGroup = [AMAppObjects appObjects][AMLocalGroupKey];
            if (![group.groupId isEqualToString:localGroup.groupId]) {
                NSAssert(NO, @"local group id is not the same");
            }
            
            localGroup.groupName = group.groupName;
            localGroup.description = group.description;
            localGroup.leaderId = group.leaderId;
            localGroup.users = users;
            
            _userlistVersion = [[result objectForKey:@"Version"] intValue];
            
            NSNotification* notification = [NSNotification notificationWithName:AM_LOCALUSERS_CHANGED object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
        });
    };

    [_httpRequestQueue addOperation:req];
}

- (NSString *)httpBaseURL
{
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey  ];
    NSAssert(config, @"system config can not be nil!");
    NSString* localServerAddr = config.localServerAddr;
    NSString* localServerPort = config.localServertPort;
    
    return [NSString stringWithFormat:@"http://%@:%@", localServerAddr, localServerPort];
}


#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    AMUser* mySelf = [[AMAppObjects  appObjects] objectForKey:AMMyselfKey];
    NSAssert(mySelf, @"Myself is nil");
    
    NSMutableDictionary* localHeartbeatReq = [[NSMutableDictionary alloc] init];
    [localHeartbeatReq setObject:mySelf.userid forKey:@"UserId"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:localHeartbeatReq options:0 error:nil];
    return data;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didReceiveData:(NSData *)data
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    _heartbeatFailureCount = 0;
    NSError *error = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&error];
    NSAssert(error == nil, @"parse json data failed!");
    
    NSDictionary* result = (NSDictionary*)objects;
    int version = [[result objectForKey:@"Version"] intValue];
    
    if (version != _userlistVersion){
        [self requestUserList];
    }
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didSendData:(NSData *)data
{
//    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"didSendData:%@", jsonStr);
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error
{
    NSLog(@"hearBeat error:%@", error.description);
    _heartbeatFailureCount ++;
    //NSAssert(_heartbeatFailureCount > 5, @"heartbeat failure count is bigger than max failure count!");
}


@end
