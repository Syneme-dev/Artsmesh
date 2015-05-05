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
#import "AMLogger/AMLogger.h"

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
            
            switch (newState) {
                case kMesherMeshing:
                    [self startRemoteClient];
                    break;
                case kMesherUnmeshing:
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
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    if (!config.useIpv6) {
        [self requestPublicIp];
    }
    
    [self registerGroup];
}

-(void)requestPublicIp
{
    AMLog(kAMInfoLog, @"AMMesher", @"start querying public ip...");
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    NSHost* serverHost = [NSHost hostWithName:config.stunServerAddr];
    _stunServerAddrs = [serverHost addresses];
    
    _udpSocket = [[GCDAsyncUdpSocket alloc]
                  initWithDelegate:self
                  delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![_udpSocket bindToPort:0 error:&error])
    {
        AMLog(kAMErrorLog, @"AMMesher", @"create udp socket failed in remote mesher when request public ip. Error:%@",
              error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error])
    {
        AMLog(kAMErrorLog, @"AMMesher", @"listening socket port failed in remote mesher when request public ip. Error:%@", error);
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
    AMLog(kAMInfoLog, @"AMMesher", @"will register group to global server");
    
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
            AMLog(kAMErrorLog, @"AMMesher", @"register group to global server failed! %@", error);
            return;
        }
        
        if(response == nil){
            AMLog(kAMErrorLog, @"AMMesher", @"register group to global server return nil");
            return;
        }
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"] ||
            [responseStr isEqualToString:@"group alread exist"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AMLog(kAMInfoLog, @"AMMesher", @"register group to global server finished will register self");
                [self registerSelf];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AMLog(kAMErrorLog, @"AMMesher", @"register group to global server failed will retry");
                sleep(1);
                [self registerGroup];
            });
        }
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)registerSelf
{
    AMLog(kAMInfoLog, @"AMMesher", @"start register self to global server");
    
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
            AMLog(kAMErrorLog, @"AMMesher", @"register self to global server failed.%@", error);
            return;
        }
        
        if(response == nil){
            AMLog(kAMErrorLog, @"AMMesher", @"register self to global server return nil");
            return;
        }
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([responseStr isEqualToString:@"ok"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AMLog(kAMInfoLog, @"AMMesher", @"register self to global server finished. will start heartbeat");
                [self startHeartbeat];
                [[AMMesher sharedAMMesher] setMesherState:kMesherMeshed];
                [[AMMesher sharedAMMesher] updateMySelf];
                
                [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANGED_REMOTE];
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                AMLog(kAMErrorLog, @"AMMesher", @"register self to global server failed. Can not mesh");
                mySelf.isOnline = NO;
                [[AMMesher sharedAMMesher] updateMySelf];
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
    
    AMLog(kAMInfoLog, @"AMMesher", @"Will update my self to global server");
    
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
            AMLog(kAMErrorLog, @"AMMesher", @"update myself to global server failed. %@", error);
            return;
        }
        
        if(response == nil){
            AMLog(kAMErrorLog, @"AMMesher", @"update myself to global server return failed");
        }
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            AMLog(kAMErrorLog, @"AMMesher", @"update myself to global server failed");
            return;
        }
        
        AMLog(kAMInfoLog, @"AMMesher", @"update myself to global server finished");
    };
    
    [_httpRequestQueue addOperation:req];
}

-(void)updateGroupInfo
{
    if([[AMMesher sharedAMMesher] mesherState] != kMesherMeshed){
        return;
    }
    
    AMLog(kAMInfoLog, @"AMMesher", @"Will update group info to global server");
    
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
        
        if (error != nil || response == nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"update group to global server failed.%@",error);
            return;
        }
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            AMLog(kAMErrorLog, @"AMMesher", @"update group to global server failed.%@",responseStr);
            return;
        }
        
        AMLog(kAMInfoLog, @"AMMesher", @"update group to global server finished");
    };
    
    [_httpRequestQueue addOperation:req];
}


-(void)stopRemoteClient
{
    AMLog(kAMInfoLog, @"AMMesher", @"will stop remote mesher...");
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
    
    [[AMMesher sharedAMMesher] setMesherState:kMesherUnmeshed];
    [[AMMesher sharedAMMesher] updateMySelf];
    
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
        
        if (error != nil || response ==nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"merge group failed. %@", error);
            return;
        }
        
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if (![responseStr isEqualToString:@"ok"]) {
            AMLog(kAMErrorLog, @"AMMesher", @"merge group failed. %@", responseStr);
            return;
        }
        AMLog(kAMInfoLog, @"AMMesher", @"merge group finished");
        
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
    
 //   NSString* remoteServerAddr = config.artsmeshAddr;
    NSString* remoteServerAddrFake = @"Artsmesh.io";
    NSString* remoteServerPort = config.artsmeshPort;
    BOOL useIpv6 = NO;//config.useIpv6;
    int HBTimeInterval = [config.remoteHeartbeatInterval intValue];
    int HBReceiveTimeout = [config.remoteHeartbeatRecvTimeout intValue];
    
    _heartbeatFailureCount = 0;
    
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost:remoteServerAddrFake
                                                    port:remoteServerPort
                                                    ipv6:useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = HBTimeInterval;
    _heartbeatThread.receiveTimeout = HBReceiveTimeout;
    [_heartbeatThread start];
    
}

-(void)requestUserList
{
    AMLog(kAMInfoLog, @"AMMesher", @"will request userlist from global server");
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = [self httpBaseURL];
    req.requestPath = @"/users/getall";
    req.httpMethod = @"GET";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil || response == nil) {
            AMLog(kAMErrorLog, @"AMMesher", @"query userlist from global server failed.%@", error);
            return;
        }
        
        NSError *err = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:response
                                                     options:0
                                                       error:&err];
        if(err != nil){
            AMLog(kAMErrorLog, @"AMMesher", @"query userlist JSON error %@", error);
            return;
        }
        
        NSDictionary* result = (NSDictionary*)objects;
        _userlistVersion = [[result objectForKey:@"Version"] intValue];
        NSDictionary* rootGroup = [result valueForKey:@"Data"];
        
        NSArray* groups = [rootGroup valueForKey:@"SubGroups"];
        if ([groups isEqual:[NSNull null]]) {
            AMLog(kAMErrorLog, @"AMMesher", @"group returned from global server is null");
            return;
        }
        
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
            AMLog(kAMInfoLog, @"AMMesher", @"query userlist from global server finished");
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
    _heartbeatFailureCount = 0;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error
{
    AMLog(kAMWarningLog, @"AMMesher", @"heartbeat to global server failed. %@", error);
    _heartbeatFailureCount ++;
    if (_heartbeatFailureCount > 5) {
        AMLog(kAMErrorLog, @"AMMesher", @"heartbeat to global server continue failed 5 times");
    }
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
    AMLog(kAMWarningLog, @"AMMesher", @"request public ip udp send failed will retry");
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString* fromHost = [GCDAsyncUdpSocket hostFromAddress:address];
    
    if ([_stunServerAddrs containsObject:fromHost]) {
        [self parsePublicAddr:data];
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
        
        AMLog(kAMInfoLog, @"AMMesher", @"my public ip is%@. will stop querying", mySelf.publicIp);
        
        [_publicIpReqTimer invalidate];
        _publicIpReqTimer = nil;
        
        AMMesher* mesher = [AMMesher sharedAMMesher];
        [mesher updateMySelf];
    }
}

@end
