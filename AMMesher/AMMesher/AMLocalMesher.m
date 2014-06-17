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


@interface AMLocalMesher()<AMHeartBeatDelegate, AMUserRequestDelegate>
@end

@implementation AMLocalMesher
{
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
        self.server = ip;
        self.serverPort = port;
        _useIpv6 = useIpv6;
        _userTimeout = seconds;
        _heartbeatFailureCount = 0;
        _userlistVersion = 0;
    }
    
    return self;
}

-(void)startLocalServer
{
    if (_mesherServerTask)
        [_mesherServerTask cancel];
    
    [self stopLocalServer];
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"LocalServer"];
    NSString *command = [NSString stringWithFormat:
                         //@"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %d >LocalServer.log 2>&1",
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %d",
                         lanchPath,
                         self.serverPort,
                         self.serverPort,
                         _userTimeout];
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    NSLog(@"command is %@", command);
    [_mesherServerTask launch];
}


-(void)stopLocalServer
{
    if (_mesherServerTask != nil)
    {
        [_mesherServerTask cancel];
    }
    
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"LocalServer", nil]];
}

-(void)startLocalClient
{
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"LocalMesherQueue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
    
    [self registerSelf];
}

-(void)startHeartbeat
{
    if (_heartbeatThread) {
        [_heartbeatThread cancel];
    }
    
    _heartbeatFailureCount = 0;
    
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: self.server port:self.serverPort ipv6:_useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = 2;
    _heartbeatThread.receiveTimeout = 5;
    [_heartbeatThread start];

}

-(void)stopLocalClient
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
}

-(void)changeGroupName:(NSString* ) name
{
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/groups/update";
    req.formData = @{@"groupName": name };
    [_httpRequestQueue addOperation:req];
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
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.requestPath = @"/users/delete";
    req.formData = @{@"userId": mySelf.userid};
    
    [_httpRequestQueue addOperation:req];
    [_httpRequestQueue waitUntilAllOperationsAreFinished];
}

-(void)requestUserList
{
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
    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didSendData:%@", jsonStr);
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
    return [NSString stringWithFormat:@"http://%@:%@", self.server, self.serverPort];
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
        
        NSString* clusterId = [result objectForKey:@"GroupId"];
        NSString* clusterName = [result objectForKey:@"GroupName"];
        
        NSString* oldClusterId = [[AMAppObjects appObjects] objectForKey:AMClusterIdKey];
        NSString* oldClusterName = [[AMAppObjects appObjects] objectForKey:AMClusterNameKey];
        
        if (![oldClusterId isEqualToString:clusterId] || ![oldClusterName isEqualToString:clusterName]){
            [[AMAppObjects appObjects] setObject:clusterId forKey:AMClusterIdKey];
            [[AMAppObjects appObjects] setObject:AMClusterNameKey forKey:AMClusterNameKey];
        }
        
        NSArray* userArr = [result objectForKey:@"UserDTOs"];
        NSMutableDictionary* newUsers = [[NSMutableDictionary alloc] init];
        
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
            user.ip = [userDataDict objectForKey:@"privateIp"];
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
