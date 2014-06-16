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
#import "AMUser.h"
#import "AMAppObjects.h"
#import "AMMesher.h"
#import "AMGroup.h"

@interface AMLocalMesher()<AMHeartBeatDelegate, AMUserRequestDelegate>
@end

@implementation AMLocalMesher
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

-(void)startLocalServer
{
    if (_mesherServerTask)
        [_mesherServerTask cancel];
    
    [self stopLocalServer];
    
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"LocalServer"];
    NSString *command = [NSString stringWithFormat:
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %d >LocalServer.log 2>&1",
                         lanchPath,
                         _serverIp,
                         _serverPort,
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
    
    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: _serverIp port:_serverPort ipv6:_useIpv6];
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
        [_httpRequestQueue waitUntilAllOperationsAreFinished];
    }
    
    _heartbeatThread = nil;
}

-(void)changeGroupName
{
    
}

-(void)registerSelf
{
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate = self;
    req.action = @"/users/add";
    
    [_httpRequestQueue addOperation:req];
}

-(void)requestUserList
{
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate  = self;
    req.action = @"/users/getall";
    
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

-(NSDictionary*)httpBodyForm:(NSString *)action
{
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSDictionary* dict = [mySelf toLocalHttpBodyDict];
    return dict;
}

- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data
{
    if (data == nil) {
        return;
    }
    
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received http response:%@\n", dataStr);
    
    if([userrequest.action isEqualToString:@"/users/add"]){
        [self startHeartbeat];
        return;
    }
    
    if ([userrequest.action isEqualToString:@"/users/getall"]) {
        
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
        for (int i = 0; i < userArr.count; i++)
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
            
            AMUser* oldUser = [oldUsers objectForKey:userId];
            if(oldUser != nil){
                oldUser.nickName = [userDataDict objectForKey:@"nickName"];
                oldUser.domain = [userDataDict objectForKey:@"domain"];
                oldUser.location = [userDataDict objectForKey:@"location"];
                oldUser.localLeader = [userDataDict objectForKey:@"localLeader"];
                oldUser.isOnline = [[userDataDict objectForKey:@"isOnline"] boolValue];
                oldUser.privateIp = [userDataDict objectForKey:@"privateIp"];
                oldUser.chatPort = [userDataDict objectForKey:@"chatPort"];
            }else{
                AMUser* user = [[AMUser alloc] init];
                user.userid = userId;
                user.nickName = [userDataDict objectForKey:@"nickName"];
                user.domain = [userDataDict objectForKey:@"domain"];
                user.location = [userDataDict objectForKey:@"location"];
                user.localLeader = [userDataDict objectForKey:@"localLeader"];
                user.isOnline = [[userDataDict objectForKey:@"isOnline"] boolValue];
                user.privateIp = [userDataDict objectForKey:@"privateIp"];
                user.chatPort = [userDataDict objectForKey:@"chatPort"];
                [oldUsers setValue:user forKeyPath:userId];
            }
        }
        
        _userlistVersion = [[result objectForKey:@"Version"] intValue];
        NSNotification* notification = [NSNotification notificationWithName:AM_LOCALUSERS_CHANGED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    
        return;
    }

}

- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error
{
    NSAssert(NO, @"http request failed!");
}


@end
