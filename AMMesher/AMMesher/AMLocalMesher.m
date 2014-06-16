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
    int _serverUserlistVersion;
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
        _serverUserlistVersion = 0;
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
    if (_mesherServerTask) {
        return;
    }
    
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"LocalMesherQueue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
    
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

-(void)goOnline
{
    
}

-(void)goOffline
{
    
}

-(void)requestUserList
{
    AMUserRequest* req = [[AMUserRequest alloc] init];
    req.delegate  = self;
    req.action = @"users-get";
    
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
    
    if (version != _serverUserlistVersion){
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
    NSAssert(_heartbeatFailureCount > 5, @"heartbeat failure count is bigger than max failure count!");
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

-(NSDictionary*)httpBody:(NSString *)action
{
    AMUser* mySelf =[[AMAppObjects appObjects] valueForKey:AMMyselfKey];
    NSDictionary* dict = [mySelf jsonDict];
    
    return dict;
}

- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data
{
    if (data == nil) {
        return;
    }
    
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataStr);
    
//    AMUserRESTResponse* response = [AMUserRESTResponse responseFromJsonData:data];
//    if (response == nil) {
//        return;
//    }
//    
//    @synchronized(self)
//    {
//        self.userGroupsVersion = [response.version intValue];
//        AMGroupsBuilder* builder = [[AMGroupsBuilder alloc] init];
//        
//        for (AMUser* user in response.userlist ) {
//            [builder addUser:user];
//        }
//        
//        [self willChangeValueForKey:@"userGroups"];
//        self.userGroups = builder.groups;
//        [self didChangeValueForKey:@"userGroups"];
//        
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        NSNotification* notification = [NSNotification notificationWithName:AM_USERGROUPS_CHANGED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });
}

- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error
{
    NSAssert(NO, @"http request failed!");
}


@end
