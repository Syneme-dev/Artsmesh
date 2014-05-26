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
    NSTimer* _heartbeatTimer;
    NSString* _amserverIp;
    NSString* _amserverRestPort;
    NSString* _amserverUdpPort;
    NSString* _amserverURL;
    NSString* _amuserTimeout;
    
    int uselistVsersion;
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
        uselistVsersion = 0;
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
    NSMutableString *content = [[NSMutableString alloc] init];
    
    //Log Message, later will be remove or redirect to file
    inputStream.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        [content appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        NSLog(content);
    };

}

-(void)killAllAMServer{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"amserver", nil]];
   // usleep(1000*500);
}

-(void)registerSelf{
    uselistVsersion = 0;
    
    AMUpdateUserOperation* updateOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
    updateOper.action = @"register";
    [[AMMesher sharedEtcdOperQueue] addOperation:updateOper];
}

-(void)heartbeat{
    AMUpdateUserOperation* heartbeatOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
    heartbeatOper.action = @"heartbeat";
    [[AMMesher sharedEtcdOperQueue] addOperation:heartbeatOper];
}

-(void)joinGroup:(NSString*)groupName{
    if ([self.mySelf.groupName isEqualToString:groupName]) {
        return;
    }
    
    @synchronized(self){
        self.mySelf.groupName = groupName;
    }
    
    AMUpdateUserOperation* updateOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
    updateOper.action = @"update";
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
                
                [self startMesherServer];
                
            }else if(newState == 4){
                //Joined
                NSLog(@"Mesher is %@:%d", _elector.mesherHost, _elector.mesherPort);
                
                [self willChangeValueForKey:@"isLeader"];
                self.isLeader = NO;
                [self didChangeValueForKey:@"isLeader"];
                
                [self willChangeValueForKey:@"localLeaderName"];
                self.localLeaderName = _elector.mesherHost;
                [self didChangeValueForKey:@"localLeaderName"];
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

#pragma mark -
#pragma mark AMMesherOperationDelegate
-(void)MesherOperDidFinished:(AMMesherOperation*)oper{
    
    if ([oper.action isEqualToString:@"register"]) {
        if (oper.isSucceeded) {
            _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:NO];
            
            AMRequestUserOperation* requestOper = [[AMRequestUserOperation alloc] initWithMesherServerUrl: _amserverURL];
            requestOper.action = @"request";
            [[AMMesher sharedEtcdOperQueue] addOperation:requestOper];
            
        }else{
            //TODO: tell the user register self error
        }
        
    }else if([oper.action isEqualToString:@"heartbeat"]){
        if (oper.isSucceeded) {
            //TODO:compare the version if the version is out date, send a request oper
            _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:NO];
        }else{
            //TODO: tell the user heartbeat self error
        }
        
    }else if([oper.action isEqualToString:@"update"]){
        if (oper.isSucceeded) {
            //TODO:update the userlist version.
        }else{
            //TODO: tell the user update self error
        }
    
    }
}

@end
