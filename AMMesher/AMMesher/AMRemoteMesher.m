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
#import "AMMesher.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMCoreData/AMCoreData.h"

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
    
    GCDAsyncUdpSocket* _udpSocket;
    NSTimer* _publicIpReqTimer;
    NSArray* _stunServerAddrs;
}

-(id)init
{
    if (self = [super init]) {
        
        [[AMMesher sharedAMMesher] addObserver:self forKeyPath:@"mesherState"
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
    if ([object isKindOfClass:[AMMesher class]]){
        
        if ([keyPath isEqualToString:@"mesherState"]){
            AMMesherState newState = [[change objectForKey:@"new"] intValue];
            AMMesherState oldState = [[change objectForKey:@"old"] intValue];
            
            switch (newState) {
                case kMesherMeshing:
                    [self startRemoteClient];
                    break;
                case kMesherUnmeshing:
                    [self stopRemoteClient];
                    break;
                case kMesherStopping:
                    if (oldState == kMesherMeshed){
                        [self stopRemoteClient];
                    }
                    break;
                default:
                    break;
            }
        }
    }
}


-(void)startRemoteClient
{
    [self requestPublicIp];
    [self registerGroup];
}

-(void)requestPublicIp
{
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSHost* serverHost = [NSHost hostWithName:config.stunServerAddr];
    _stunServerAddrs = [serverHost addresses];
    
    _udpSocket = [[GCDAsyncUdpSocket alloc]
                  initWithDelegate:self
                  delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![_udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"requestPublicIp failed: Error binding: %@", error);
        return;
    }
    if (![_udpSocket beginReceiving:&error])
    {
        NSLog(@"requestPublicIp failed:: Error receiving: %@", error);
        return;
    }
    
    _publicIpReqTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                         target:self
                                                       selector:@selector(sendHeartbeat)
                                                       userInfo:nil
                                                        repeats:YES];
    return ;
}


-(void)registerGroup
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMCoreData shareInstance] broadcastChanges:AM_MYGROUP_CHANGING_REMOTE];
    });
    
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;

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
            [responseStr isEqualToString:@"group alread exist"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self registerSelf];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //sleep(2);
                [self registerGroup];
            });
        }
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)registerSelf
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGING_REMOTE];
    });
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.isOnline = YES;
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
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
                [self startHeartbeat];
                [[AMMesher sharedAMMesher] setMesherState:kMesherMeshed];
                [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGED_REMOTE];
                //[[AMCoreData shareInstance] broadcastChanges:AM_MYGROUP_CHANGED_REMOTE];
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
    if([[AMMesher sharedAMMesher] mesherState] != kMesherMeshed){
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGING_REMOTE];
    });
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
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
        
         //[[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGED_REMOTE];
    };

    [_httpRequestQueue addOperation:req];
}

-(void)updateGroupInfo
{
    if([[AMMesher sharedAMMesher] mesherState] != kMesherMeshed){
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMCoreData shareInstance] broadcastChanges:AM_MYGROUP_CHANGING_REMOTE];
    });

    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    NSDictionary* dict = [myGroup dictWithoutUsers];
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/groups/update";
    req.formData = dict;
    req.httpMethod = @"POST";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            NSLog(@"error happened when update group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            NSLog(@"update user info on remote response wrong!%@", responseStr);
        }
        
        //[[AMCoreData shareInstance] broadcastChanges:AM_MYGROUP_CHANGED_REMOTE];
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)stopRemoteClient
{
    [_publicIpReqTimer invalidate];
    _publicIpReqTimer = nil;
    
    [_udpSocket close];
    _udpSocket = nil;
    
    if (_heartbeatThread){
        [_heartbeatThread cancel];
         _heartbeatThread = nil;
    }
    
    if (_httpRequestQueue) {
        [_httpRequestQueue  cancelAllOperations];
        [self unregisterSelf];
    }
    
    [AMCoreData shareInstance].remoteLiveGroups = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMCoreData shareInstance]broadcastChanges: AM_LIVE_GROUP_CHANDED];
    });
}

-(void)unregisterSelf{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    AMHttpSyncRequest* req = [[AMHttpSyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/delete";
    req.formData = @{@"userId": mySelf.userid, @"groupId":myGroup.groupId};
    req.httpTimeout = 10;
    req.httpMethod = @"POST";
    [req sendRequest];
    
    mySelf.isOnline = NO;
}


-(void)mergeGroup:(NSString*)toGroupId
{
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
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
            NSLog(@"update user info on remote response wrong!%@", responseStr);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AMCoreData shareInstance] broadcastChanges:AM_MERGED_GROUPID_CHANGED];
        });
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
    
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSAssert(config, @"system config can not be nil!");
    
    NSString* remoteServerAddr = config.artsmeshAddr;
    NSString* remoteServerPort = config.artsmeshPort;
    BOOL useIpv6 = [config.useIpv6 boolValue];
    int HBTimeInterval = [config.remoteHeartbeatInterval intValue];
    int HBReceiveTimeout = [config.remoteHeartbeatRecvTimeout intValue];
    
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
        NSDictionary* rootGroup = [result valueForKey:@"Data"];
        
        NSArray* groups = [rootGroup valueForKey:@"SubGroups"];
        NSMutableArray* groupList = [[NSMutableArray alloc] init];
        for (int i =0; i < groups.count; i++){
            if (![groups[i]isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSDictionary* groupData = (NSDictionary*)groups[i];
            AMLiveGroup* newGroup = [self parseGroup:groupData];
            [groupList addObject:newGroup];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [AMCoreData shareInstance].remoteLiveGroups = groupList;
            [[AMCoreData shareInstance] broadcastChanges:AM_LIVE_GROUP_CHANDED];
        });
    };
    
    [_httpRequestQueue addOperation:req];
}

-(AMLiveGroup*)parseGroup:(NSDictionary*)groupData
{
    //part group meta
    NSDictionary* groupDict = groupData[@"GroupData"];
    AMLiveGroup* newGroup = [AMLiveGroup AMGroupFromDict:groupDict];
    
    //parse native users
    NSMutableArray* users = [[NSMutableArray alloc] init];
    NSArray* userDicts = groupData[@"Users"];
    if ([userDicts isKindOfClass:[NSArray class]]) {
        for(NSDictionary* userDict in userDicts){
            AMLiveUser* newUser = [AMLiveUser AMUserFromDict:userDict];
            [users addObject:newUser];
        }
    }
    newGroup.users = users;

    //parse subgroups
    NSMutableArray* subgroups = [[NSMutableArray alloc] init];
    NSArray* subGroupsData = groupData[@"SubGroups"];
    if ([subGroupsData isKindOfClass:[NSArray class]]) {
        for(NSDictionary* subGroupData in subGroupsData){
            AMLiveGroup* sub = [self parseGroup:subGroupData];
            [subgroups addObject:sub];
        }
    }
    
    newGroup.subGroups = subgroups;
    return newGroup;
}


-(NSArray*)getAllUserFromGroup:(NSDictionary*)group isMySelfIn:(BOOL*)mySelfIn{
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSAssert(mySelf, @"myself can not be nil");
    
    NSMutableArray* allusers = [[NSMutableArray alloc] init];
    
    id myUsers = [group objectForKey:@"Users"];
    id mySubGroups = [group objectForKey:@"SubGroups"];
    
    if ([myUsers isKindOfClass:[NSArray class]]) {
        
        for (int i = 0; i < [myUsers count]; i++) {
            AMLiveUser* newUser = [AMLiveUser AMUserFromDict:myUsers[i]];
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
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSAssert(config, @"system config can not be nil!");
    NSString* localServerAddr = config.artsmeshAddr;
    NSString* localServerPort = config.artsmeshPort;
    
    return [NSString stringWithFormat:@"http://%@:%@", localServerAddr, localServerPort];
}


#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    NSMutableDictionary* remoteHBReq = [[NSMutableDictionary alloc] init];
    [remoteHBReq setObject:mySelf.userid forKey:@"UserId"];
    [remoteHBReq setObject:myGroup.groupId forKey:@"GroupId"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:remoteHBReq options:0 error:nil];
    return data;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didReceiveData:(NSData *)data
{
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
    
    BOOL hasMessage = [[result objectForKey:@"HasMessage"] boolValue];
    if (hasMessage) {
        //Send quest message request
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
#pragma RequestPublicIP

-(void)sendHeartbeat{
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    
    NSData *data = [@"HB" dataUsingEncoding:NSUTF8StringEncoding];
    [_udpSocket sendData:data
                  toHost:config.stunServerAddr
                    port: [config.stunServerPort intValue]
             withTimeout:-1
                     tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    ;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    ;
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    //NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString* fromHost = [GCDAsyncUdpSocket hostFromAddress:address];
    
    if ([_stunServerAddrs containsObject:fromHost]) {
        [self parsePublicAddr:data];
        
        [_publicIpReqTimer invalidate];
        _publicIpReqTimer = nil;
        
        return;
    }
}

-(void)parsePublicAddr:(NSData*)data
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* ipAndPort = [msg componentsSeparatedByString:@":"];
    if ([ipAndPort count] < 2){
        return;
    }
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(![mySelf.publicIp isEqualToString:[ipAndPort objectAtIndex:0]]){
        mySelf.publicIp = [ipAndPort objectAtIndex:0];
        
        [_publicIpReqTimer invalidate];
        _publicIpReqTimer = nil;
        
        AMMesher* mesher = [AMMesher sharedAMMesher];
        [mesher updateMySelf];
    }
}

@end
