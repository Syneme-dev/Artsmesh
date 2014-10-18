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

        [[AMMesher sharedAMMesher] addObserver:self forKeyPath:@"mesherState"
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
        
        if ([keyPath isEqualToString:@"mesherState"]){
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
                    [[AMMesher sharedAMMesher] setMesherState:kMesherStarted];
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
    
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSAssert(config, @"system config can not be nil!");
    NSString* port = config.localServerPort;
    NSString* userTimeout = config.serverHeartbeatTimeout;

    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"LocalServer"];
    lanchPath = [NSString stringWithFormat:@"\"%@\"",lanchPath];
    NSString *command = [NSString stringWithFormat:
                        // @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@ >LocalServer.log 2>&1 &",
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@ >/dev/null 2>&1",
                         lanchPath,
                         port,
                         port,
                         userTimeout];
    //system("say \"Now I'm the leader and my host name is `hostname`\"");
    NSLog(@"command is %@", command);
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    [_mesherServerTask launch];
    
    sleep(2);
    
    [[AMMesher sharedAMMesher] setMesherState:kMesherLocalClientStarting];
    
//    [AMCoreData shareInstance].myLocalLiveGroup.longitude = @"116";
//    [AMCoreData shareInstance].myLocalLiveGroup.latitude = @"39";
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
            NSLog(@"error happened when register group:%@", error.description);
            NSLog(@"will try again!");
            dispatch_async(dispatch_get_main_queue(), ^{
                sleep(1);
                [self registerLocalGroup];
            });
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                mySelf.isLeader = YES;
                [self registerSelf];
            });
            
        }else if([responseStr isEqualToString:@"group already exist"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                mySelf.isLeader = NO;
                 [self registerSelf];
            });
            
        }else{
            NSAssert(NO, @"local http request wrong!");
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


//-(void)getLocalGroupInfo
//{
//    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
//    req.baseURL = [self httpBaseURL];
//    req.requestPath = @"/groups/getall";
//    req.httpMethod = @"GET";
//    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
//        if (isCancel == YES) {
//            return;
//        }
//        
//        if (error != nil) {
//            NSLog(@"error happened when get group info:%@", error.description);
//            return;
//        }
//        
//        NSAssert(response, @"response should not be nil without error");
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            AMLiveGroup* group = [AMLiveGroup AMGroupFromDict:(NSDictionary*)response];
//            AMLiveGroup* localGroup =[AMCoreData shareInstance].myLocalLiveGroup;
//            
//            //should no need synchronized, because in main loop
//            // @synchronized(localGroup){
//            localGroup.groupName = group.groupName;
//            localGroup.description = group.description;
//            localGroup.leaderId = group.leaderId;
//            //}
//            
//            [self registerSelf];
//        });
//    };
//    
//    [_httpRequestQueue addOperation:req];
//}


-(void)registerSelf
{
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
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AMMesher sharedAMMesher] setMesherState:kMesherStarted];
                [self startHeartbeat];
            });

        }else if([responseStr isEqualToString:@"user already exist!"]){
            NSLog(@"%@", responseStr);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"register self failed, retry");
                //sleep(2);
                [self registerSelf];
            });
        }
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)unregisterSelf{
    
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
    
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSAssert(config, @"system config can not be nil!");
    
    NSString* localServerAddr = config.localServerIp;
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
    if (_heartbeatThread){
        [_heartbeatThread cancel];
    }
    
    if (_httpRequestQueue) {
        [_httpRequestQueue  cancelAllOperations];
        [self unregisterSelf];
    }
    
    _httpRequestQueue = nil;
    _heartbeatThread = nil;
    
    [[AMMesher sharedAMMesher] setMesherState:kMesherStopped];
}


-(void)updateLocalGroup
{
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
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
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
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
    dispatch_async(dispatch_get_main_queue(), ^{
    [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGING_LOCAL];
    });
    
    
    if([[AMMesher sharedAMMesher] mesherState] < kMesherStarted  ||
       [[AMMesher sharedAMMesher] mesherState] >= kMesherStopping){
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
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        //NSAssert(response, @"response should not be nil without error");
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
           NSLog(@"update user info response wrong! %@", responseStr);
        }
        
        //[[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGED_LOCAL];
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)updateGroupInfo
{
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
            NSLog(@"error happened when register group:%@", error.description);
            NSAssert(NO, error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            NSLog(@"updateGroupInfo failed!");
        }
        
       // [[AMCoreData shareInstance] broadcastChanges:AM_MYGROUP_CHANGED_LOCAL];
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

        NSDictionary* groupData = (NSDictionary*)result[@"GroupData"];
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
    NSAssert(config, @"system config can not be nil!");
    NSString* localServerAddr = config.localServerIp;
    NSString* localServerPort = config.localServerPort;
    
    return [NSString stringWithFormat:@"http://%@:%@", localServerAddr, localServerPort];
}


#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSAssert(mySelf, @"Myself is nil");
    
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
