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
#import "AMGroup.h"

@interface AMRemoteMesher()<AMHeartBeatDelegate, AMUserRequestDelegate>
@end

@implementation AMRemoteMesher
{
    NSString* _serverIp;
    NSString* _serverPort;
    BOOL _useIpv6;
    int _userTimeout;
    
    NSOperationQueue* _httpRequestQueue;
    AMHeartBeat* _heartbeat;
    AMShellTask *_mesherServerTask;
    AMHeartBeat* _heartbeatThread;
    
    int _heartbeatFailureCount;
    int _userlistVersion;
}

-(id)initWithServer:(NSString*)ip
               port:(NSString*)port
        userTimeout:(int)seconds
               ipv6:(BOOL)useIpv6
{
    if (self = [super init]) {
        _serverIp = ip;
        _serverPort = port;
        _useIpv6 = useIpv6;
        _userTimeout = seconds;
        _heartbeatFailureCount = 0;
        _userlistVersion = 0;
    }
    
    return self;
}

-(void)startRemoteClient
{
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"RemoteMesherQueue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
    
    [self registerSelf];
}

-(void)stopRemoteClient
{
    if (_heartbeatThread)
    {
        [_heartbeatThread cancel];
    }
    
    if (_httpRequestQueue) {
        [_httpRequestQueue  cancelAllOperations];
        [self unregisterSelf];
    }
    
    _httpRequestQueue = nil;
    _heartbeatThread = nil;
    
    [[AMAppObjects appObjects]removeObjectForKey:AMRemoteGroupsKey];
    
    NSNotification* userNotification = [NSNotification notificationWithName:AM_REMOTEGROUPS_CHANGED object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:userNotification];
}

-(void)mergeGroup:(NSString*)toGroupId
{
    NSString* clusterId = [[AMAppObjects appObjects] valueForKey:AMClusterIdKey];
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/groups/merge";
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:clusterId forKey:@"groupId"];
    [dict setObject:toGroupId forKey:@"superGroupId"];
    
    req.formData = dict;
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
    
    _heartbeatFailureCount = 0;
    
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: _serverIp port:_serverPort ipv6:_useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = 2;
    _heartbeatThread.receiveTimeout = 5;
    [_heartbeatThread start];
    
}

-(void)registerSelf
{
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSString* clusterId = [[AMAppObjects appObjects] valueForKey:AMClusterIdKey];
    NSString* clusterName = [[AMAppObjects appObjects] valueForKey:AMClusterNameKey];
    
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/users/add";
    
    NSMutableDictionary* dict = [mySelf toDict];
    [dict setObject:clusterId forKey:@"groupId"];
    [dict setObject:clusterName forKey:@"groupName"];
    
    req.formData = dict;
    
    [_httpRequestQueue addOperation:req];
}

-(void)unregisterSelf{
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSString* myGroupId = [[AMAppObjects appObjects] valueForKey:AMClusterIdKey];
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/users/delete";
    req.formData = @{@"userId": mySelf.userid, @"groupId":myGroupId};
    
    [_httpRequestQueue addOperation:req];
    [_httpRequestQueue waitUntilAllOperationsAreFinished];
}

-(void)requestUserList
{
    if([_httpRequestQueue operationCount] > 2){
        return;
    }
    
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate  = self;
    req.requestPath = @"/users/getall";
    
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
    _heartbeatFailureCount = 0;
    
    NSError *error = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&error];
    //NSAssert(error == nil, @"parse json data failed!");
    
    NSDictionary* result = (NSDictionary*)objects;
    int version = [[result objectForKey:@"Version"] intValue];
    
    if (version != _userlistVersion){
        [self requestUserList];
    }
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didSendData:(NSData *)data
{
    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didSendData:%@", jsonStr);
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
    return [NSString stringWithFormat:@"http://%@:%@", _serverIp, _serverPort];
}

-(NSString*)httpMethod:(NSString *)action
{
    if ([action isEqualToString:@"/users/getall"]){
        return  @"GET";
    }else{
        return @"POST";
    }
}

- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data
{
    if (data == nil) {
        return;
    }
    
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received http response:%@\n", dataStr);
    
    if([userrequest.requestPath isEqualToString:@"/users/add"]){
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
            newGroup.users = [self getAllUserFromGroup:groups[i]];
            
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
    
}


-(NSArray*)getAllUserFromGroup:(NSDictionary*)group{
    
    NSMutableArray* allusers = [[NSMutableArray alloc] init];
    
    id myUsers = [group objectForKey:@"Users"];
    id mySubGroups = [group objectForKey:@"SubGroups"];
    
    if ([myUsers isKindOfClass:[NSArray class]]) {
        
        for (int i = 0; i < [myUsers count]; i++) {
            
            AMUser* newUser = [AMUser AMUserFromDict:myUsers[i]];
            [allusers addObject:newUser];
        }
    }
    
    if ([mySubGroups isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < [mySubGroups count]; i++) {
            NSArray* subUsers = [self getAllUserFromGroup:mySubGroups[i]];
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
