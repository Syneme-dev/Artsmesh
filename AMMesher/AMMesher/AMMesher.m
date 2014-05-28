//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMUser.h"
#import "AMLeaderElecter.h"
#import "AMTaskLauncher/AMShellTask.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMMesherOperationDelegate.h"
#import "AMRequestUserOperation.h"
#import "AMUpdateUserOperation.h"
#import "AMHeartBeat.h"

@implementation AMMesher
{
    //Mesher Server
    AMLeaderElecter* _elector;
    AMShellTask *_mesherServerTask;
    
    NSString* _mesherServerAddr;
    NSString* _mesherServerUpdPort;
    NSString* _mesherServerHttpPort;
    NSString* _mesherUserTimeout;
    NSString* _globalMesherAddr;
    NSString* _globalMesherHttpPort;
    NSString* _globalMesherUdpPort;
  
    //Heatbeat
    AMHeartBeat* _heartbeatThread;
    
    BOOL _isNeedUpdateInfo;
    
    //HttpRequest
    NSOperationQueue* _httpRequestQueue;

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
        
        self.mySelf = [[AMUser alloc] init];
        self.allUsers = [[NSMutableArray alloc] init];
        self.uselistVersion = @"0";

        [self loadUserProfile];
        [self loadSystemConfig];
        
        [self initializeMembers];
    }
    
    return self;
}

-(void)initializeMembers
{
    
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"Http Operation Queue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
}


-(void)loadUserProfile
{
    //TODO: load preference
    @synchronized(self){
        self.mySelf.nickName = @"myNickName";
        self.mySelf.description = @"I love coffee";
        
        _isNeedUpdateInfo = YES;
    }
}

-(void)loadSystemConfig
{
    //TODO:
    _mesherServerAddr = @"localhost";
    _mesherServerUpdPort = @"8082";
    _mesherServerHttpPort = @"8080";
    _mesherUserTimeout = @"30";
    
}

-(void)startElector
{

    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mesherServerPort = [defaults stringForKey:Preference_Key_ETCD_ServerPort];

    _elector = [[AMLeaderElecter alloc] init];
    _elector.mesherPort = [mesherServerPort intValue];

    [_elector kickoffElectProcess];
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopLocalMesher
{
    if (_heartbeatThread)
        [_heartbeatThread cancel];
    
    if (_elector)
        [_elector stopElect];

    if (_mesherServerTask)
        [_mesherServerTask cancel];
}

-(void)startMesherServer
{
    if (_mesherServerTask)
        [_mesherServerTask cancel];
    
    [self killAllAMServer];
    
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"amserver"];
    NSString *command = [NSString stringWithFormat:
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@",
                         lanchPath,
                         _mesherServerHttpPort,
                         _mesherServerUpdPort,
                         _mesherUserTimeout];
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
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


-(void)joinGroup:(NSString*)groupName
{
    if ([self.mySelf.groupName isEqualToString:groupName]) {
        return;
    }
    
    self.mySelf.groupName = groupName;
    @synchronized(self){
        _isNeedUpdateInfo = YES;
    }
}

-(void)backToArtsmesh
{
    [self joinGroup:@"Artsmesh"];
}

-(void)goOnline
{
    if (self.isOnline) {
        return;
    }
    
    if (self.isLeader) {
        //stop local server if i'm the local leader
        if (_mesherServerTask){
            [_mesherServerTask cancel];
        }
    }
    
    [_heartbeatThread cancel];
    
    _heartbeatThread = [AMHeartBeat alloc] initWithHost: port:<#(char *)#> ipv6:<#(BOOL)#>
    
    
    
    
}

-(void)requestUserListInQueue{

    @synchronized(_requestUserListQueue){
        if (_requestUserListQueue == nil) {
            _requestUserListQueue  = [[AMRequestUserOperation alloc] initWithMesherServerUrl:_amserverURL];
            _requestUserListQueue.action = @"request";
            _requestUserListQueue.delegate = self;
        }
    }
}

-(void)requestUserListPop{
    
    @synchronized(_requestUserListQueue){
        if (_requestUserListQueue != nil){
            [[AMMesher sharedEtcdOperQueue] addOperation:_requestUserListQueue];
            _requestUserListQueue = nil;
        }
    }
}

#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context{
    
    if ([object isEqualTo:_elector]){
        if ([keyPath isEqualToString:@"state"]){
            
            int oldState = [[change objectForKey:@"old"] intValue];
            int newState = [[change objectForKey:@"new"] intValue];
            NSLog(@" old state is %d", oldState);
            NSLog(@" new state is %d", newState);

            if(newState == 2){
                //I'm the leader
                NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
                
                [self willChangeValueForKey:@"isLeader"];
                self.isLeader = YES;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                self.localLeaderName = _elector.mesherHost;
                [self didChangeValueForKey:@"localLeaderName"];
                
               // [self startMesherServer];
                [self registerSelf];
                
            }else if(newState == 4){
                //Joined
                NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
                
                [self willChangeValueForKey:@"isLeader"];
                self.isLeader = NO;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                self.localLeaderName = _elector.mesherHost;
                [self didChangeValueForKey:@"localLeaderName"];
                
                [self registerSelf];
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

#pragma mark -
#pragma mark AMMesherOperationDelegate
-(void)MesherOperDidFinished:(AMMesherOperation*)oper{
    
    if (oper.isSucceeded == NO) {
        NSString* errDomain = [NSString stringWithFormat:@"AMMesher-%@", oper.action];
        NSDictionary* dict = @{@"erroInfo": oper.errorDescription};
        NSError* err = [NSError errorWithDomain:errDomain code:-1 userInfo:dict];
        [self.delegate onMesherError:err];
        
        return;
    }
    
    //succeeded!
    if ([oper.action isEqualToString:@"register"]) {
        
        NSLog(@"regiser succeede, start heartbeat schedule and request userlist");
        _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:NO];
        
        [self requestUserListInQueue];
        [self requestUserListPop];
            
    }else if([oper.action isEqualToString:@"heartbeat"]){
        AMUpdateUserOperation* updateOper = (AMUpdateUserOperation* )oper;
        
        int curVer;
        @synchronized(self){
            curVer = [self.uselistVersion intValue];
        }
        
        int resVer = [updateOper.udpResponse.version intValue];
        if (resVer > curVer) {
            [self requestUserListInQueue];
            [self requestUserListPop];
        }
        
        _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:NO];
            
    }else if([oper.action isEqualToString:@"update"]){
        
        _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:NO];
            
    }else if([oper.action isEqualToString:@"request"]){
        AMRequestUserOperation* requestOper = (AMRequestUserOperation* )oper;
        
       // requestOper.restResponse
    }
}

@end
