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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

//    _etcdServerPort = [defaults stringForKey:Preference_Key_ETCD_ServerPort];
//    _etcdClientPort = [defaults stringForKey:Preference_key_ETCD_ClientPort];
//    _etcdHeartbeatTimeout = [defaults stringForKey:Preference_Key_ETCD_HeartbeatTimeout];
//    _etcdElectionTimeout = [defaults stringForKey:Preference_Key_ETCD_ElectionTimeout];
//    _etcdUserTTL = [defaults stringForKey:Preference_Key_ETCD_UserTTLTimeout];
//    _artsmeshIOIp = [defaults stringForKey:Preference_Key_ETCD_ArtsmeshIOIP];
//    _artsmeshIOPort = [defaults stringForKey:Preference_Key_ETCD_ArtsmeshIOPort];
//    _machineName = [defaults stringForKey:Preference_Key_General_MachineName];
//
//    self.mySelf.groupName = @"Artsmesh";
//    self.mySelf.domain =[defaults stringForKey:Preference_Key_User_Domain];
//    self.mySelf.location = [defaults stringForKey:Preference_Key_User_Location];
//    self.mySelf.uniqueName = [NSString stringWithFormat:@"%@@%@.%@",
//                              [defaults stringForKey:Preference_Key_User_NickName],
//                              self.mySelf.domain,
//                              self.mySelf.location];
//    self.mySelf.description = [defaults stringForKey:Preference_Key_User_Description];
//    self.mySelf.privateIp = [defaults stringForKey:Preference_Key_General_PrivateIP];
//    self.mySelf.controlPort = [defaults stringForKey:Preference_Key_General_ControlPort];
//    self.mySelf.chatPort = [defaults stringForKey:Preference_Key_General_ChatPort];

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

-(void)startMesherServer{
    
    if (_mesherServerTask){
        [_mesherServerTask cancel];
    }
    
    NSString *command = [NSString stringWithFormat:@"AMMesherServer -rest_port %@ -heartbeat_port %@ -user_timeout %@", @"8080", @"8082", @"30"];
    _mesherServerTask = [[AMShellTask alloc] initWithCommand:command];
    [_mesherServerTask launch];
}

-(void)registerSelf{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mesherUpdPort = [defaults stringForKey:Preference_Key_ETCD_ServerPort];
    NSString* mesherAddr = [defaults stringForKey:Preference_Key_ETCD_ArtsmeshIOIP];
    
    AMUpdateUserOperation* updateOper = [[AMUpdateUserOperation alloc] initWithServerAddr:mesherAddr withPort:mesherUpdPort];
    
    updateOper.action = @"register";
    [[AMMesher sharedEtcdOperQueue] addOperation:updateOper];
}

-(void)heartbeat{
    AMUpdateUserOperation* heartbeatOper = [[AMUpdateUserOperation alloc] initWithServerAddr:_amserverIp withPort:_amserverUdpPort];
    heartbeatOper.action = @"heartbeat";
    [[AMMesher sharedEtcdOperQueue] addOperation:heartbeatOper];
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
