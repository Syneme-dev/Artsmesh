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


#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    NSData* data ;
//    @synchronized(self){
//        AMUserUDPRequest* request = [[AMUserUDPRequest alloc] init];
//        
//        request.userid = self.mySelf.userid;
//        request.version = [NSString stringWithFormat:@"%d", self.userGroupsVersion];
//        
//        NSString* localMd5 = [self.mySelf md5String];
//        if (![localMd5 isEqualToString:_md5OnServer]) {
//            request.userContent = self.mySelf;
//            request.contentMd5 = localMd5;
//        }
//        data = [request jsonData];
//    }
    
    return data;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didReceiveData:(NSData *)data
{
    _heartbeatFailureCount = 0;
    
//    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"didReceiveData:%@", jsonStr);
//    
//    AMUserUDPResponse* response = [AMUserUDPResponse responseFromJsonData:data];
//    
//    @synchronized(self){
//        _md5OnServer  = response.contentMd5;
//        
//        if ([response.version intValue] !=  self.userGroupsVersion) {
//            NSLog(@"need download userlist");
//            
//            AMUserRequest* req = [[AMUserRequest alloc] init];
//            req.delegate = self;
//            
//            if(_httpRequestQueue.operationCount < 2)
//            {
//                [_httpRequestQueue  addOperation:req];
//            }
//        }
//    }
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didSendData:(NSData *)data
{
    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didSendData:%@", jsonStr);
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didFailWithError:(NSError *)error
{
    NSLog(@"hearBeat error:%@", error.description);
//    
//    _heartbeatFailureCount ++;
//    if (_heartbeatFailureCount > [_systemConfig.maxHeartbeatFailure intValue]) {
//        [self.delegate onMesherError:error];
//    }
}


#pragma mark-
#pragma AMUserRequestDelegate

- (NSString *)httpServerURL
{
    NSString* URLStr;
//    if (self.isOnline) {
//        URLStr = [NSString stringWithFormat:@"http://%@:%@/users", _systemConfig.globalServerAddr, _systemConfig.globalServerPort];
//        NSLog(@"%@", URLStr);
//        
//    }else{
//        URLStr = [NSString stringWithFormat:@"http://%@:%@/users", _elector.serverName, _elector.serverPort];
//        NSLog(@"%@", URLStr);
//    }
    
    return URLStr;
}

- (void)userRequestDidCancel
{
    
}


//- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data
//{
//    if (data == nil) {
//        return;
//    }
//    
//    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", dataStr);
//    
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
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        // do work here
//        NSNotification* notification = [NSNotification notificationWithName:AM_USERGROUPS_CHANGED object:self userInfo:nil];
//        [[NSNotificationCenter defaultCenter] postNotification:notification];
//    });
//}

//- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error
//{
//    
//}

#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMLeaderElecter class]]){
        
        AMLeaderElecter* elector = (AMLeaderElecter*)object;
        
        if ([keyPath isEqualToString:@"state"]){
            
            int oldState = [[change objectForKey:@"old"] intValue];
            int newState = [[change objectForKey:@"new"] intValue];
            NSLog(@" old state is %d", oldState);
            NSLog(@" new state is %d", newState);
            
            if(newState == 2){
                //I'm the leader
                NSLog(@"Mesher is %@:%@", elector.serverName, elector.serverPort);
                
                [self startLocalServer];
                //[self startHearBeat:_elector.serverName serverPort:_elector.serverPort];

            }else if(newState == 4){
                //Joined
                NSLog(@"Mesher is %@:%@", elector.serverName, elector.serverPort);

                // [self startHearBeat:_elector.serverName serverPort:_elector.serverPort];
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

@end
