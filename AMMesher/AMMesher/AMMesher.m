//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMUser.h"
#import "AMGroup.h"
#import "AMLeaderElecter.h"
#import "AMTaskLauncher/AMShellTask.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMSystemConfig.h"
#import "AMUserRequest.h"
#import "AMGroupsBuilder.h"
#import "AMHeartBeat.h"

 NSString* const AM_USERGROUPS_CHANGED = @"AM_USERGROUPS_CHANGED";
 NSString* const AM_MESHER_ONLINE= @"AM_MESHER_ONLINE";

@interface AMMesher()

@property AMUser* mySelf;
@property NSString* localLeaderName;
@property BOOL isLocalLeader;
@property BOOL isOnline;
@property NSArray* userGroups;
@property int userGroupsVersion;

@end

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMShellTask *_mesherServerTask;
    AMHeartBeat* _heartbeatThread;
    NSOperationQueue* _httpRequestQueue;
    AMSystemConfig* _systemConfig;
    int _heartbeatFailureCount;
    
    NSString* _action;

}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}

+(id)sharedAMMesher
{
    static AMMesher* sharedMesher = nil;
    @synchronized(self){
        if (sharedMesher == nil){
            sharedMesher = [[self alloc] initMesher];
        }
    }
    return sharedMesher;
}

-(id)initMesher
{
    if (self = [super init]){
        
        [self loadUserProfile];
        [self loadSystemConfig];
        [self initUserGroups];
        [self initHttpReuestQueue];
    }
    
    return self;
}

-(void)loadUserProfile
{
    //TODO: load preference
    @synchronized(self){
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        self.mySelf = [[AMUser alloc] init];
        self.mySelf.nickName = [defaults stringForKey:Preference_Key_User_NickName];
        self.mySelf.domain = [defaults stringForKey:Preference_Key_User_Domain];
        self.mySelf.location = [defaults stringForKey:Preference_Key_User_Location];
        self.mySelf.description = [defaults stringForKey:Preference_Key_User_Description];
        self.mySelf.privateIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
        
        AMUserPortMap* pm = [[AMUserPortMap alloc] init];
        pm.portName = @"ChatPort";
        pm.internalPort = [defaults stringForKey:Preference_Key_General_ChatPort];;
        pm.natMapPort   = pm.internalPort;
        [self.mySelf.portMaps addObject:pm];
        
        _action = @"new";
    }
}

-(void)loadSystemConfig
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _systemConfig = [[AMSystemConfig alloc] init];
    _systemConfig.myServerPort = [defaults stringForKey:Preference_Key_General_LocalServerPort];
    _systemConfig.heartbeatInterval = @"2";
    _systemConfig.myServerUserTimeout = @"30";
    _systemConfig.maxHeartbeatFailure = @"5";
    _systemConfig.globalServerPort = [defaults stringForKey:Preference_Key_General_GlobalServerPort];
    _systemConfig.globalServerAddr = [defaults stringForKey:Preference_Key_General_GlobalServerAddr];
    _systemConfig.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];
    _systemConfig.stunServerAddr = [defaults stringForKey:Preference_Key_General_StunServerAddr];
    _systemConfig.stunServerPort = [defaults stringForKey:Preference_Key_General_StunServerPort];
}

-(void)initUserGroups
{
    self.userGroups = [[NSMutableArray alloc] init];
    self.userGroupsVersion = 0;
}

-(void)initHttpReuestQueue{
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"Http Operation Queue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
}


-(void)startMesher
{
    _heartbeatFailureCount = 0;
    _action = @"new";
    
    if(_elector == nil){
        if (_systemConfig) {
            _elector = [[AMLeaderElecter alloc] initWithPort:_systemConfig.myServerPort];
        }
    }
    
    [_elector kickoffElectProcess];
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopMesher
{
    if (_httpRequestQueue) {
        [_httpRequestQueue  cancelAllOperations];
        [_httpRequestQueue waitUntilAllOperationsAreFinished];
    }
    
    if (_heartbeatThread)
    {
        [_heartbeatThread cancel];
    }
    
    if (_mesherServerTask)
    {
        [_mesherServerTask cancel];
        [self killAllAMServer];
    }
    
    if (_elector)
    {
        [_elector removeObserver:self forKeyPath:@"state"];
        [_elector stopElect];
    }
    
    _heartbeatThread = nil;
    _elector = nil;
    _mesherServerTask = nil;
}

-(void)setMySelfPropties:(NSDictionary*)props
{
    @synchronized(self){
        for (NSString* key in props) {
            id value = [props valueForKey:key];
            [self.mySelf setValue:value forKey:key];
        }
        
        _action = @"update";
    }
}

-(void)joinGroup:(NSString*)groupName
{
    @synchronized(self){
        [self.mySelf setValue:groupName forKey:@"groupName"];
        _action = @"update";
    }
}

-(AMGroup*)myGroup
{
    AMGroup* myGroup;
    NSString* myGroupName = self.mySelf.groupName;
    NSArray* groups = self.userGroups;

    for(AMGroup* g in groups){
        if ([g.groupName isEqualToString:myGroupName]) {
            myGroup = g;
            break;
        }
    }
    
    return myGroup;
}

-(void)backToArtsmesh
{
    [self joinGroup:@""];
}


-(void)goOnline
{
    if (_isOnline) {
        return;
    }
    
    [self stopMesher];
    
    @synchronized(self){
        _action = @"new";
    }
    
     _isOnline = YES;
    
    [self startHearBeat:_systemConfig.globalServerAddr serverPort:_systemConfig.globalServerPort];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        
        NSDictionary* params = @{@"IsOnline":@"YES"};
        NSNotification* notification = [NSNotification notificationWithName:AM_MESHER_ONLINE object:self userInfo:params];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });
}

-(void)goOffline
{
    [self stopMesher];
    _isOnline = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        
        NSDictionary* params = @{@"IsOnline":@"NO"};
        NSNotification* notification = [NSNotification notificationWithName:AM_MESHER_ONLINE object:self userInfo:params];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });
    [self startMesher];
}


-(void)startLocalServer
{
    if (_mesherServerTask)
        [_mesherServerTask cancel];
    
    [self killAllAMServer];
    
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"amserver"];
    NSString *command = [NSString stringWithFormat:
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@ >amserver.log 2>&1",
                         lanchPath,
                         _systemConfig.myServerPort,
                         _systemConfig.myServerPort,
                         _systemConfig.myServerUserTimeout];
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    NSLog(@"command is %@", command);
    [_mesherServerTask launch];

}

-(void)killAllAMServer
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"amserver", nil]];
    
    //sleep(1);
}

-(void)startHearBeat:(NSString*)addr serverPort:(NSString*)port
{
    if (_heartbeatThread) {
        [_heartbeatThread cancel];
    }
    
    _heartbeatFailureCount = 0;
    BOOL useIpv6 = NO;
    if (_systemConfig) {
        useIpv6 = _systemConfig.useIpv6;
    }

    _heartbeatThread = [[AMHeartBeat alloc] initWithHost: addr port:port ipv6:useIpv6];
    _heartbeatThread.delegate = self;
    _heartbeatThread.timeInterval = 2;
    _heartbeatThread.receiveTimeout = 5;
    [_heartbeatThread start];
}

-(void)setPortMaps:(AMUserPortMap*)portMap
{
    @synchronized(self){
        BOOL bFind = NO;
        for (AMUserPortMap* pm in self.mySelf.portMaps) {
            if([pm.portName isEqualToString:portMap.portName]){
                pm.internalPort = portMap.internalPort;
                pm.natMapPort = portMap.natMapPort;
                bFind = YES;
                break;
            }
        }
        if (!bFind) {
            [self.mySelf.portMaps addObject:portMap];
        }
        
        _action = @"update";
    }
}

-(AMUserPortMap*)portMapByName:(NSString*)portMapName{
    @synchronized(self){
        for (AMUserPortMap* pm in self.mySelf.portMaps) {
            if([pm.portName isEqualToString:portMapName]){
                return pm;
            }
        }
        return nil;
    }
}

#pragma mark-
#pragma AMHeartBeatDelegate

- (NSData *)heartBeatData
{
    NSData* data ;
    @synchronized(self){
        AMUserUDPRequest* request = [[AMUserUDPRequest alloc] init];
        request.action = _action;
        request.userid = self.mySelf.userid;
        request.version = [NSString stringWithFormat:@"%d", self.userGroupsVersion];
        
        if ([_action isEqualToString:@"new"] || [_action isEqualToString:@"update"]) {
            request.contentMd5 = [self.mySelf md5String];
            request.userContent = self.mySelf;
        }
        
        data = [request jsonData];
    }
    
    return data;
}

- (void)heartBeat:(AMHeartBeat *)heartBeat didReceiveData:(NSData *)data
{
    _heartbeatFailureCount = 0;
    
    NSString* jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReceiveData:%@", jsonStr);
    
    AMUserUDPResponse* response = [AMUserUDPResponse responseFromJsonData:data];
    
    @synchronized(self){
        if (response.isSucceeded == NO) {
            _action = @"update";
        }
        
        if ([response.contentMd5 isEqualToString:[self.mySelf md5String]]) {
            _action = @"heartbeat";
        }
        
        if ([response.version intValue] >  self.userGroupsVersion) {
            NSLog(@"need download userlist");
            
            AMUserRequest* req = [[AMUserRequest alloc] init];
            req.delegate = self;
            [_httpRequestQueue  addOperation:req];
        }
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
    if (_heartbeatFailureCount > [_systemConfig.maxHeartbeatFailure intValue]) {
        [self.delegate onMesherError:error];
    }
}

#pragma mark-
#pragma AMUserRequestDelegate

- (NSString *)httpServerURL
{
    if (_elector) {
        NSString* URLStr = [NSString stringWithFormat:@"http://%@:%@/users", _elector.serverName, _elector.serverPort];
        NSLog(@"%@", URLStr);
        return URLStr;
    }
    return @"http://localhost:8080/users";
}

- (void)userRequestDidCancel
{
    
}


- (void)userrequest:(AMUserRequest *)userrequest didReceiveData:(NSData *)data
{
    if (data == nil) {
        return;
    }
    
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataStr);
    
    AMUserRESTResponse* response = [AMUserRESTResponse responseFromJsonData:data];
    if (response == nil) {
        return;
    }
    
    @synchronized(self)
    {
        self.userGroupsVersion = [response.version intValue];
        AMGroupsBuilder* builder = [[AMGroupsBuilder alloc] init];
        
        for (AMUser* user in response.userlist ) {
            [builder addUser:user];
        }
        
        [self willChangeValueForKey:@"userGroups"];
        self.userGroups = builder.groups;
        [self didChangeValueForKey:@"userGroups"];
    
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        NSNotification* notification = [NSNotification notificationWithName:AM_USERGROUPS_CHANGED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });


}

- (void)userrequest:(AMUserRequest *)userrequest didFailWithError:(NSError *)error
{
    
}

#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isEqualTo:_elector]){
        if ([keyPath isEqualToString:@"state"]){
            
            int oldState = [[change objectForKey:@"old"] intValue];
            int newState = [[change objectForKey:@"new"] intValue];
            NSLog(@" old state is %d", oldState);
            NSLog(@" new state is %d", newState);

            if(newState == 2){
                //I'm the leader
                NSLog(@"Mesher is %@:%@", _elector.serverName, _elector.serverPort);
                
                [self willChangeValueForKey:@"isLeader"];
                self.isLocalLeader = YES;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                self.localLeaderName = _elector.serverName;
                [self didChangeValueForKey:@"localLeaderName"];
                
                @synchronized(self){
                    self.mySelf.localLeader = self.localLeaderName;
                    _action = @"new";
                }
                
                [self startLocalServer];
                [self startHearBeat:_elector.serverName serverPort:_elector.serverPort];
                
                self.isLocalLeader = YES;
                
            }else if(newState == 4){
                //Joined
                NSLog(@"Mesher is %@:%@", _elector.serverName, _elector.serverPort);
                
                [self willChangeValueForKey:@"isLeader"];
                self.isLocalLeader = NO;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                self.localLeaderName = _elector.serverName;
                [self didChangeValueForKey:@"localLeaderName"];
                
                @synchronized(self){
                    self.mySelf.localLeader = self.localLeaderName;
                    _action = @"new";
                }
                
                [self startHearBeat:_elector.serverName serverPort:_elector.serverPort];
                self.isLocalLeader = NO;
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

@end