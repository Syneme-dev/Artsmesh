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
#import "AMNotificationManager/AMNotificationManager.h"
#import "AMHeartBeat.h"

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
    BOOL _isNeedUpdateInfo;
    int _heartbeatFailureCount;

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
        self.mySelf = [[AMUser alloc] init];
        self.mySelf.nickName = @"myNickName";
        self.mySelf.description = @"I love coffee";
        self.mySelf.privateIp = @"127.0.0.1";
        self.mySelf.groupName = @"333";
        
        AMUserPortMap* pm = [[AMUserPortMap alloc] init];
        pm.portName = @"port1";
        pm.internalPort = @"20005";
        pm.natMapPort   = @"12345";
        [self.mySelf.portMaps addObject:pm];
        
        _isNeedUpdateInfo = YES;
    }
}

-(void)loadSystemConfig
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _systemConfig = [[AMSystemConfig alloc] init];
    //TODO: load system config from Preference
    
    _systemConfig.myServerPort = @"8080";
    _systemConfig.heartbeatInterval = @"2";
    _systemConfig.myServerUserTimeout = @"30";
    _systemConfig.maxHeartbeatFailure = @"5";
    _systemConfig.globalServerPort = @"8080";
    _systemConfig.globalServerAddr = @"localhost";
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
    _isNeedUpdateInfo = YES;
    
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
        
        _isNeedUpdateInfo = YES;
    }
}

-(void)joinGroup:(NSString*)groupName
{
    @synchronized(self){
        [self.mySelf setValue:groupName forKey:@"groupName"];
        _isNeedUpdateInfo = YES;
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
        _isNeedUpdateInfo = YES;
    }
    
     _isOnline = YES;
    
    [self startHearBeat:_systemConfig.globalServerAddr serverPort:_systemConfig.globalServerPort];
}

-(void)goOffline
{
    [self stopMesher];
    _isOnline = NO;
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
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@",
                         lanchPath,
                         _systemConfig.myServerPort,
                         _systemConfig.myServerPort,
                         _systemConfig.myServerUserTimeout];
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    NSLog(@"command is %@", command);
    [_mesherServerTask launch];

    //Log Message, later will be remove or redirect to file
    NSFileHandle *inputStream = [_mesherServerTask fileHandlerForReading];
    inputStream.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        NSString* logStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", logStr);
    };

}

-(void)killAllAMServer
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"amserver", nil]];
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
        
        _isNeedUpdateInfo = YES;
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
        request.action = @"update";
        request.version = [NSString stringWithFormat:@"%d", self.userGroupsVersion];
        
        if (_isNeedUpdateInfo) {
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
        if ([response.contentMd5 isEqualToString:[self.mySelf md5String]]) {
            _isNeedUpdateInfo = NO;
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
    NSLog(@"didSendData:%@", error.description);
    
    _heartbeatFailureCount ++;
    if (_heartbeatFailureCount > [_systemConfig.maxHeartbeatFailure intValue]) {
        [self.delegate onMesherError:error];
    }
}

#pragma mark-
#pragma AMUserRequestDelegate

- (NSString *)httpServerURL
{
    //TODO
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
        
        AMGroup* myGroup = [self myGroup];
        if (myGroup != nil) {
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            [params setObject:myGroup forKey:@"myGroup"];
            [params setObject:self.userGroups forKey:@"allGroups"];
            [[AMNotificationManager defaultShared] postMessage:params withTypeName:AM_USERGROUPS_CHANGED source:self];
        }
    }
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
                
                [self startHearBeat:_elector.serverName serverPort:_elector.serverPort];
                
                self.isLocalLeader = NO;
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

-(NSArray*)allGroupUsers{
    
    return nil;
}

@end