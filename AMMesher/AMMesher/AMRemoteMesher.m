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
#import "AMUserRequest.h"
#import "AMAppObjects.h"
#import "AMMesher.h"
#import "AMMesherStateMachine.h"
#import "AMSystemConfig.h"

@interface AMRemoteMesher()<AMHeartBeatDelegate, AMUserRequestDelegate>
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
    [self registerSelf];
}

-(void)updateMyselfInfo
{
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine can not be nil!");
    
    if([machine mesherState] != kMesherMeshed){
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


-(void)stopRemoteClient
{
    if (_heartbeatThread)
    {
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
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSString* myGroupId = [[AMAppObjects appObjects] valueForKey:AMClusterIdKey];
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/users/delete";
    req.formData = @{@"userId": mySelf.userid, @"groupId":myGroupId};
    req.httpTimeout = 10;
    req.httpMethod = @"POST";
    
    [_httpRequestQueue addOperation:req];
}


-(void)mergeGroup:(NSString*)toGroupId
{
    NSString* clusterId = [[AMAppObjects appObjects] valueForKey:AMClusterIdKey];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:clusterId forKey:@"groupId"];
    [dict setObject:toGroupId forKey:@"superGroupId"];
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/groups/merge";
    req.formData = dict;
    req.httpMethod = @"POST";
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
    if([_httpRequestQueue operationCount] > 2){
        return;
    }
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate  = self;
    req.requestPath = @"/users/getall";
    req.httpMethod = @"POST";
    
    [_httpRequestQueue addOperation:req];
}

#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    AMUser* mySelf = [[AMAppObjects  appObjects] objectForKey:AMMyselfKey];
    NSString* groupId = [[AMAppObjects appObjects] objectForKey:AMClusterIdKey];
    NSAssert(mySelf, @"Myself is nil");
    
    NSMutableDictionary* remoteHBReq = [[NSMutableDictionary alloc] init];
    [remoteHBReq setObject:mySelf.userid forKey:@"UserId"];
    [remoteHBReq setObject:groupId forKey:@"GroupId"];
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


#pragma mark-
#pragma AMUserRequestDelegate

- (NSString *)httpBaseURL
{
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey  ];
    NSAssert(config, @"system config can not be nil!");
    NSString* localServerAddr = config.globalServerAddr;
    NSString* localServerPort = config.globalServerPort;
    
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
        
        if ([machine mesherState] != kMesherMeshing){
            return;
        }

        [machine setMesherState:kMesherMeshed];
        
        NSNotification* notification = [NSNotification notificationWithName:AM_MESHER_ONLINE_CHANGED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
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
        _userlistVersion = [[result objectForKey:@"Version"] intValue];
        NSDictionary* data = [result valueForKey:@"Data"];
        NSArray* groups = [data valueForKey:@"SubGroups"];
        
        NSMutableDictionary* groupsDict = [[NSMutableDictionary alloc] init];
        for (int i =0; i < groups.count; i++){
            AMGroup* newGroup = [[AMGroup alloc] init];
            newGroup.groupId = [groups[i] objectForKey:@"GroupId"];
            newGroup.groupName =  [groups[i] objectForKey:@"GroupData"];
            
            BOOL isMySelfIn = NO;
            newGroup.users = [self getAllUserFromGroup:groups[i] isMySelfIn:&isMySelfIn];
            if (isMySelfIn == YES) {
                [AMAppObjects appObjects][AMMergedGroupIdKey] = newGroup.groupId;
            }
        
            [groupsDict setObject:newGroup forKey:[groups[i] objectForKey:@"GroupId"]];
        }
    
        NSNotification* groupNotification = [NSNotification notificationWithName:AM_LOCALUSERS_CHANGED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:groupNotification];
        
        [[AMAppObjects appObjects] setObject:groupsDict forKey:AMRemoteGroupsKey];
        AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
        
        if (mySelf.isOnline == NO){
            mySelf.isOnline = YES;
        }
        
        NSNotification* userNotification = [NSNotification notificationWithName:AM_REMOTEGROUPS_CHANGED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:userNotification];

        return;
    }
    
    if([userrequest.requestPath isEqualToString:@"/users/delete"]){
        
        [_httpRequestQueue  cancelAllOperations];
    }
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



- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error
{
    //NSAssert(NO, @"http request failed!");
}



@end
