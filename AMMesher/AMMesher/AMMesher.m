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

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMShellTask *_mesherServerTask;
    
    AMRequestUserOperation* _requestUserListQueue; //the queue size is 1
    
    NSTimer* _heartbeatTimer;
    NSString* _amserverIp;
    NSString* _amserverRestPort;
    NSString* _amserverUdpPort;
    NSString* _amserverURL;
    NSString* _amuserTimeout;
}

+(id)sharedAMMesher{
    static AMMesher* sharedMesher = nil;
    @synchronized(self){
        if (sharedMesher == nil){
            sharedMesher = [[self alloc] init];
        }
    }
    return sharedMesher;
}

-(id)init{
    if (self = [super init]){
        self.mySelf = [[AMUser alloc] init];
        self.allUsers = [[NSMutableArray alloc] init];
        self.uselistVersion = @"0";
    }
    
    return self;
}

+(NSOperationQueue*)sharedEtcdOperQueue{
    static NSOperationQueue* mesherOperQueue = nil;
    @synchronized(self){
        if (!mesherOperQueue){
            mesherOperQueue = [[NSOperationQueue alloc] init];
            mesherOperQueue.name = @"ETCD Operation Queue";
            mesherOperQueue.maxConcurrentOperationCount = 1;
        }
    }
    
    return mesherOperQueue;
}

-(void)loadPreference{
    //TODO:
    _amserverIp = @"localhost";
    _amserverRestPort = @"8080";
    _amserverUdpPort = @"8082";
    _amuserTimeout = @"30";
}

-(void)startLoalMesher{
    [self loadPreference];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mesherServerPort = [defaults stringForKey:Preference_Key_ETCD_ServerPort];

    _elector = [[AMLeaderElecter alloc] init];
    _elector.mesherPort = [mesherServerPort intValue];

    [_elector kickoffElectProcess];
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopLocalMesher{
    
    if (self.isLeader == NO) {
        AMUpdateUserOperation* deleteOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
        deleteOper.action = @"delete";
        [deleteOper start];
    }
    
    [_elector stopElect];
    
    if (_mesherServerTask){
        [_mesherServerTask cancel];
    }
}

-(void)startMesherServer{
    
    if (_mesherServerTask){
        [_mesherServerTask cancel];
    }
    
    [self killAllAMServer];
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* lanchPath =[mainBundle pathForAuxiliaryExecutable:@"amserver"];
    NSString *command = [NSString stringWithFormat:
                         @"%@ -rest_port %@ -heartbeat_port %@ -user_timeout %@",
                         lanchPath, _amserverRestPort,
                         _amserverUdpPort, _amuserTimeout];
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    [_mesherServerTask launch];
    
    NSFileHandle *inputStream = [_mesherServerTask fileHandlerForReading];
    
    //Log Message, later will be remove or redirect to file
    inputStream.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        NSString* logStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(logStr);
    };

}

-(void)killAllAMServer{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"amserver", nil]];
   // usleep(1000*500);
}

-(void)registerSelf{
    self.uselistVersion = @"0";
    
    AMUserUDPRequest* request = [[AMUserUDPRequest alloc] init];
    @synchronized(self){
        request.userContent = [self.mySelf copy];
        request.version = self.uselistVersion;
    }
    request.contentMd5 = [request.userContent md5String];
    
    AMUpdateUserOperation* updateOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
    updateOper.action = @"register";
    updateOper.delegate = self;
    updateOper.udpRequest = request;
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateOper];
}

-(void)heartbeat{
    
    AMUserUDPRequest* request = [[AMUserUDPRequest alloc] init];
    @synchronized(self){
        request.version = self.uselistVersion;
    }
    
    AMUpdateUserOperation* heartbeatOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
    heartbeatOper.action = @"heartbeat";
    heartbeatOper.udpRequest = request;
    heartbeatOper.delegate = self;
    
    [[AMMesher sharedEtcdOperQueue] addOperation:heartbeatOper];
}

-(void)joinGroup:(NSString*)groupName{
    if ([self.mySelf.groupName isEqualToString:groupName]) {
        return;
    }
    
    AMUserUDPRequest* request = [[AMUserUDPRequest alloc] init];
    
    @synchronized(self){
        self.mySelf.groupName = groupName;
        request.userContent = [self.mySelf copy];
        request.version = self.uselistVersion;
    }
    
    [_heartbeatTimer invalidate];
    
    AMUpdateUserOperation* updateOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
    updateOper.action = @"update";
    updateOper.udpRequest = request;
    updateOper.delegate = self;
    
    [[AMMesher sharedEtcdOperQueue] addOperation:updateOper];
    
}

-(void)backToArtsmesh{
    [self joinGroup:@"Artsmesh"];
}

-(void)goOnline{
    if (self.isOnline) {
        return;
    }
    
    if (self.isLeader) {
        //stop local server is i'm the local leader
        if (_mesherServerTask){
            [_mesherServerTask cancel];
        }
    }
    
    @synchronized(self){
        self.isOnline = YES;
        //TODO: change the amserver ip and port
        [[AMMesher sharedEtcdOperQueue] cancelAllOperations];
        [self registerSelf];
    }
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
