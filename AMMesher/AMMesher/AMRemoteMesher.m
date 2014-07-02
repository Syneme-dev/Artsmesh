//
//  AMRemoteMesher.m
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMRemoteMesher.h"
#import "AMHeartBeat.h"
#import "AMLeaderElecter.h"
#import "AMTaskLauncher/AMShellTask.h"
#import "AMAppObjects.h"
#import "AMMesher.h"
#import "AMMesherStateMachine.h"
#import "AMSystemConfig.h"
#import "AMHttpAsyncRequest.h"
#import "AMHttpSyncRequest.h"

@interface AMRemoteMesher()<AMHeartBeatDelegate>
@end

@implementation AMRemoteMesher
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
        AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
        NSAssert(machine, @"mesher state machine should not be nil!");
        
        [machine addObserver:self forKeyPath:@"mesherState"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
        
        _httpRequestQueue = [[NSOperationQueue alloc] init];
        _httpRequestQueue.name = @"RemoteMesherQueue";
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
            
            //AMMesherState oldState = [[change objectForKey:@"old"] intValue];
            AMMesherState newState = [[change objectForKey:@"new"] intValue];
            
            switch (newState) {
                case kMesherMeshing:
                    [self startRemoteClient];
                    break;
                case kMesherUnmeshing:
                    [self stopRemoteClient];
                    break;
                case kMesherStopping:
                    [self stopRemoteClient];
                    break;
                default:
                    break;
            }
        }
    }
}


-(void)startRemoteClient
{
    [self registerGroup];
}

-(void)registerGroup
{
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];

    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/add";
    req.httpMethod = @"POST";
    req.formData = [myGroup dictWithoutUsers];
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
        if ([responseStr isEqualToString:@"ok"] ||
            [responseStr isEqualToString:@"group aleady exist"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self registerSelf];
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self registerGroup];
            });
        }
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)registerSelf
{
    AMUser* mySelf = [AMAppObjects appObjects][AMMyselfKey];
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSMutableDictionary* dict = [mySelf toDict];
    dict[@"groupId"] = myGroup.groupId;

    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL ];
    req.requestPath = @"/users/add";
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
                mySelf.isOnline = YES;
                [self startHeartbeat];
                AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
                [machine setMesherState:kMesherMeshed];
                
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                mySelf.isOnline = NO;
            });
        }
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)updateMyself
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if([machine mesherState] != kMesherMeshed){
        return;
    }
    
    AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
    NSDictionary* dict = [mySelf toDict];
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/update";
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
            NSAssert(NO, @"update user info on remote response wrong!");
        }
    };

    [_httpRequestQueue addOperation:req];
}


-(void)stopRemoteClient
{
    if (_heartbeatThread){
        [_heartbeatThread cancel];
         _heartbeatThread = nil;
    }
    
    if (_httpRequestQueue) {
        [_httpRequestQueue  cancelAllOperations];
        [self unregisterSelf];
    }
    
    [[AMAppObjects appObjects]removeObjectForKey:AMRemoteGroupsKey];
    
    NSNotification* userNotification = [NSNotification notificationWithName:AM_REMOTEGROUPS_CHANGED object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:userNotification];
}

-(void)unregisterSelf{
    AMUser* mySelf =[AMAppObjects appObjects][AMMyselfKey];
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    AMHttpSyncRequest* req = [[AMHttpSyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/delete";
    req.formData = @{@"userId": mySelf.userid, @"groupId":myGroup.groupId};
    req.httpTimeout = 10;
    req.httpMethod = @"POST";
    [req sendRequest];
}


-(void)mergeGroup:(NSString*)toGroupId
{
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:myGroup.groupId forKey:@"groupId"];
    [dict setObject:toGroupId forKey:@"superGroupId"];
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/merge";
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
            NSAssert(NO, @"merge group info on remote response wrong!");
        }
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)unmergeGroup
{
    [self mergeGroup:@""];
}

-(void)startHeartbeat
{
    if (_heartbeatThread) {
        [_heartbeatThread cancel];
    }
    
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey ];
    NSAssert(config, @"system config can not be nil!");
    
    NSString* remoteServerAddr = config.globalServerAddr;
    NSString* remoteServerPort = config.globalServerPort;
    BOOL useIpv6 = config.useIpv6;
    int HBTimeInterval = [config.heartbeatInterval intValue];
    int HBReceiveTimeout = [config.heartbeatRecvTimeout intValue];
    
    _heartbeatFailureCount = 0;
    
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: remoteServerAddr port:remoteServerPort ipv6:useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = HBTimeInterval;
    _heartbeatThread.receiveTimeout = HBReceiveTimeout;
    [_heartbeatThread start];
    
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
        id objects = [NSJSONSerialization JSONObjectWithData:response
                                                     options:0
                                                       error:&err];
        if(err != nil){
            NSLog(@"parse Json error:%@", err.description);
            return;
        }
        
        NSDictionary* result = (NSDictionary*)objects;
        _userlistVersion = [[result objectForKey:@"Version"] intValue];
        NSDictionary* data = [result valueForKey:@"Data"];
        NSArray* groups = [data valueForKey:@"SubGroups"];
        
        NSMutableDictionary* groupsDict = [[NSMutableDictionary alloc] init];
        for (int i =0; i < groups.count; i++){
            if (![groups[i]isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSDictionary* dtoGroup = (NSDictionary*)groups[i];
            NSDictionary* groupData = dtoGroup[@"GroupData"];
            if (![groupData isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            AMGroup* newGroup = [AMGroup AMGroupFromDict:groupData];
            
            BOOL isMySelfIn = NO;
            newGroup.users = [self getAllUserFromGroup:groups[i] isMySelfIn:&isMySelfIn];
            if (isMySelfIn == YES) {
                [AMAppObjects appObjects][AMMergedGroupIdKey] = newGroup.groupId;
            }
            
            [groupsDict setObject:newGroup forKey:newGroup.groupId];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AMAppObjects appObjects] setObject:groupsDict forKey:AMRemoteGroupsKey];
            
            NSNotification* groupNotification = [NSNotification notificationWithName:AM_LOCALUSERS_CHANGED object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:groupNotification];
            
            NSNotification* userNotification = [NSNotification notificationWithName:AM_REMOTEGROUPS_CHANGED object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:userNotification];
        });
    };
    
    [_httpRequestQueue addOperation:req];
}

-(NSArray*)getAllUserFromGroup:(NSDictionary*)group isMySelfIn:(BOOL*)mySelfIn{
    
    AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
    NSAssert(mySelf, @"myself can not be nil");
    
    NSMutableArray* allusers = [[NSMutableArray alloc] init];
    
    id myUsers = [group objectForKey:@"Users"];
    id mySubGroups = [group objectForKey:@"SubGroups"];
    
    if ([myUsers isKindOfClass:[NSArray class]]) {
        
        for (int i = 0; i < [myUsers count]; i++) {
            AMUser* newUser = [AMUser AMUserFromDict:myUsers[i]];
            if ([newUser.userid isEqualToString:mySelf.userid]) {
                *mySelfIn = YES;
            }
            
            [allusers addObject:newUser];
        }
    }
    
    if ([mySubGroups isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < [mySubGroups count]; i++) {
            NSArray* subUsers = [self getAllUserFromGroup:mySubGroups[i] isMySelfIn:mySelfIn];
            for (int j = 0; j < [subUsers count]; j++) {
                [allusers addObject:subUsers[j]];
            }
        }
    }
    return allusers;
}

- (NSString *)httpBaseURL
{
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey  ];
    NSAssert(config, @"system config can not be nil!");
    NSString* localServerAddr = config.globalServerAddr;
    NSString* localServerPort = config.globalServerPort;
    
    return [NSString stringWithFormat:@"http://%@:%@", localServerAddr, localServerPort];
}


#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    AMUser* mySelf = [AMAppObjects  appObjects][AMMyselfKey];
    AMGroup* myGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    
    NSMutableDictionary* remoteHBReq = [[NSMutableDictionary alloc] init];
    [remoteHBReq setObject:mySelf.userid forKey:@"UserId"];
    [remoteHBReq setObject:myGroup.groupId forKey:@"GroupId"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:remoteHBReq options:0 error:nil];
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
    // NSAssert(_heartbeatFailureCount > 5, @"heartbeat failure count is bigger than max failure count!");
}

@end
