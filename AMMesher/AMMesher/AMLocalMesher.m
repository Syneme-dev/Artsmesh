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
#import "AMUserRequest.h"
#import "AMAppObjects.h"
#import "AMMesher.h"
#import "AMGroup.h"
#import "AMMesherStateMachine.h"
#import "AMSystemConfig.h"


@interface AMLocalMesher()<AMHeartBeatDelegate, AMUserRequestDelegate>
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
                    [self updateMyselfInfo];
                    break;
                case kMesherUnmeshing:
                    [self updateMyselfInfo];
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
                         //@"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@",
                         lanchPath,
                         port,
                         port,
                         userTimeout];
    system("say \"Now I'm the leader and my host name is `hostname`\"");
    
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
    [self registerSelf];
}


-(void)registerSelf
{
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSString* clusterId = [[AMAppObjects appObjects] valueForKey:AMClusterIdKey];
    NSString* clusterName = [[AMAppObjects appObjects] valueForKey:AMClusterNameKey];
    
    NSMutableDictionary* dict = [mySelf toDict];
    [dict setObject:clusterId forKey:@"groupId"];
    [dict setObject:clusterName forKey:@"groupName"];
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/users/add";
    req.httpMethod = @"POST";
    req.formData = dict;
    
    [_httpRequestQueue addOperation:req];
}


-(void)unregisterSelf{
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    AMUserRequest* req = [[AMUserRequest alloc] init];
    
    req.delegate = self;
    req.requestPath = @"/users/delete";
    req.formData = @{@"userId": mySelf.userid};
    req.httpMethod = @"POST";
    
    [_httpRequestQueue addOperation:req];
    [_httpRequestQueue waitUntilAllOperationsAreFinished];
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


-(void)changeGroupName:(NSString* ) newGroupName
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    AMMesherState mState = [machine mesherState];
    if (mState != kMesherStarted ){
        return;
    }
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/groups/update";
    req.formData = @{@"groupName": newGroupName };
    req.httpMethod = @"POST";
    
    [_httpRequestQueue addOperation:req];
}

-(void)updateMyselfInfo
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if([machine mesherState] < kMesherStarted  || [machine mesherState] >= kMesherStopping){
        return;
    }
    
    AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
    NSDictionary* dict = [mySelf toDict];
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/users/update";
    req.formData = dict;
    req.httpMethod = @"POST";
    
    [_httpRequestQueue addOperation:req];
    [_httpRequestQueue waitUntilAllOperationsAreFinished];
}


-(void)requestUserList
{
    if ([_httpRequestQueue operationCount] > 2){
        return;
    }
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate  = self;
    req.requestPath = @"/users/getall";
    req.httpMethod = @"GET";

    [_httpRequestQueue addOperation:req];
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


#pragma mark-
#pragma AMUserRequestDelegate

- (NSString *)httpBaseURL
{
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey  ];
    NSAssert(config, @"system config can not be nil!");
    NSString* localServerAddr = config.localServerAddr;
    NSString* localServerPort = config.localServertPort;
    
    return [NSString stringWithFormat:@"http://%@:%@", localServerAddr, localServerPort];
}


- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data
{
    if (data == nil) {
        return;
    }
    
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received http response:%@\n", dataStr);
    
    if([userrequest.requestPath isEqualToString:@"/users/add"]){
        
        AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
        NSAssert(machine, @"mesher state machine can not be nil!");
        
//        if ([machine mesherState] != kMesherLocalClientStarting){
//            return;
//        }
        
        [machine setMesherState:kMesherStarted];
        
        [self startHeartbeat];
        return;
    }
    
    if ([userrequest.requestPath isEqualToString:@"/users/getall"]) {
        
        NSLog(@"getall users return........................");
        
        NSError *err = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0
                                                       error:&err];
        if(err != nil){
            NSLog(@"parse Json error:%@", err.description);
            return;
        }
        
        NSDictionary* result = (NSDictionary*)objects;
        
        NSString* clusterId = [result objectForKey:@"GroupId"];
        NSString* clusterName = [result objectForKey:@"GroupName"];
        
        NSString* oldClusterId = [[AMAppObjects appObjects] objectForKey:AMClusterIdKey];
        NSString* oldClusterName = [[AMAppObjects appObjects] objectForKey:AMClusterNameKey];
        
        if (![oldClusterId isEqualToString:clusterId] || ![oldClusterName isEqualToString:clusterName]){
            [[AMAppObjects appObjects] setObject:clusterId forKey:AMClusterIdKey];
            [[AMAppObjects appObjects] setObject:clusterName forKey:AMClusterNameKey];
        }
        
        id userArr = [result objectForKey:@"UserDTOs"];
        NSMutableDictionary* newUsers = [[NSMutableDictionary alloc] init];
        if (userArr == [NSNull null]) {
            userArr = nil;
        }
        for (int i = 0; i < [userArr count]; i++)
        {
            NSDictionary* userDTO = (NSDictionary*)userArr[i];
            NSString* userId = [userDTO objectForKey:@"UserId"];
            NSString* userDataStr = [userDTO objectForKey:@"UserData"];
            NSData* userData = [userDataStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *err = nil;
            id object = [NSJSONSerialization JSONObjectWithData:userData
                                                         options:0
                                                           error:&err];
            if(err != nil){
                NSLog(@"parse Json error:%@", err.description);
                return;
            }
            
            NSDictionary* userDataDict = (NSDictionary*)object;
            NSDictionary* oldUsers = [[AMAppObjects appObjects] objectForKey:AMLocalUsersKey];
            if (oldUsers == nil) {
                oldUsers = [[NSMutableDictionary alloc] init];
                [[AMAppObjects appObjects] setObject:oldUsers forKey:AMLocalUsersKey];
            }

            AMUser* user = [[AMUser alloc] init];
            user.userid = userId;
            user.nickName = [userDataDict objectForKey:@"nickName"];
            user.domain = [userDataDict objectForKey:@"domain"];
            user.location = [userDataDict objectForKey:@"location"];
            user.localLeader = [userDataDict objectForKey:@"localLeader"];
            user.isOnline = [[userDataDict objectForKey:@"isOnline"] boolValue];
            user.privateIp = [userDataDict objectForKey:@"privateIp"];
            user.chatPort = [userDataDict objectForKey:@"chatPort"];
            [newUsers setValue:user forKeyPath:userId];
        }
        
        [[AMAppObjects appObjects] setObject:newUsers forKey:AMLocalUsersKey];
        
        _userlistVersion = [[result objectForKey:@"Version"] intValue];
        NSNotification* notification = [NSNotification notificationWithName:AM_LOCALUSERS_CHANGED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    
        return;
    }

}

- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error
{
   // NSAssert(NO, @"http request failed!");
}


@end
