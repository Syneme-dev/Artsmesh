//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMMesherPreference.h"
#import "AMLeaderElecter.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMMesherOperationProtocol.h"
#import "AMETCDLauncher.h"
#import "AMETCDInitializer.h"
#import "AMAddUserOperator.h"
#import "AMUpdateUserOperator.h"
#import "AMQueryAllOperator.h"
#import "AMRemoveUserOperator.h"


NSOperationQueue* _etcdOperQueue = nil;

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    NSTimer* _heartbeatTimer;

    BOOL _isMesher;
}


+(NSOperationQueue*)sharedEtcdOperQueue;
{
    if (!_etcdOperQueue)
    {
        _etcdOperQueue = [[NSOperationQueue alloc] init];
        _etcdOperQueue.name = @"ETCD Operation Queue";
        _etcdOperQueue.maxConcurrentOperationCount = 2;
    }
    
    return _etcdOperQueue;
}


-(id)init
{
    if (self = [super init])
    {
        _isMesher = NO;
    
        self.myGroupName = @"Artsmesh";
        self.myUserName = [AMNetworkUtils getHostName];
        self.myDomain = Preference_MyDomain;
        self.myDescription = Preference_MyDescription;
        self.myStatus = Preference_MyStatus;
        self.myIp = [AMNetworkUtils getHostIpv4Addr];
        
        //Init Mesher Elector
        _elector = [[AMLeaderElecter alloc] init];
        _elector.mesherPort = Preference_ETCDServerPort;
        
        //init group information
       // groups = [[NSMutableArray alloc] init];
    
        
    }
    
    return self;
}

-(void)startLoalMesher
{
    [_elector kickoffElectProcess];
    
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

-(void)stopLocalMesher
{
    [_elector stopElect];
    [_elector removeObserver:self forKeyPath:@"state"];
}


#pragma mark -
#pragma mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
        int oldState = [[change objectForKey:@"old"] intValue];
        int newState = [[change objectForKey:@"new"] intValue];
        
        NSLog(@" old state is %d", oldState);
        NSLog(@" new state is %d", newState);
        
        if(newState == 2)//Published
        {
            _isMesher = YES;
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            
            [self performSelectorOnMainThread:@selector(startMesherLaunchProcess) withObject:nil waitUntilDone:NO];
        
        }
        else if(newState == 4)//Joined
        {
            _isMesher = NO;
            NSLog(@"Mesher is %@:%ld", _elector.mesherHost, _elector.mesherPort);
            
            [self startMesheeLaunchProcess];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


-(void)startMesherLaunchProcess
{
    AMETCDLauncher* etcdLauncher = [[AMETCDLauncher alloc] initWithParameter: self.myIp
                                                                  serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDServerPort]
                                                                  clientPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                       peers:nil
                                                           heartbeatInterval:[NSString stringWithFormat:@"%d",Preference_ETCD_HeartbeatTimeout]
                                                             electionTimeout:[NSString stringWithFormat:@"%d",Preference_ETCD_ElectionTimeout]
                                                                    delegate:nil];
    
    AMETCDInitializer* etcdInitOper = [[AMETCDInitializer alloc] initWithEtcdServer:self.myIp
                                                                               port:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                           delegate:nil];
    
    [etcdInitOper addDependency:etcdLauncher];
    
    AMAddUserOperator* addSelfOper = [[AMAddUserOperator alloc] initWithParameter:self.myIp
                                                                       serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                         username:self.myUserName
                                                                        groupname:self.myGroupName
                                                                       userdomain:self.myDomain
                                                                           userip:self.myIp
                                                                       userStatus:self.myStatus
                                                                  userDiscription:self.myDescription
                                                                         delegate:nil];
    
    [addSelfOper addDependency:etcdInitOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdLauncher];
    [[AMMesher sharedEtcdOperQueue] addOperation:etcdInitOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:addSelfOper];
}

-(void)startMesheeLaunchProcess
{
    AMETCDLauncher* etcdLauncher = [[AMETCDLauncher alloc] initWithParameter: self.myIp
                                                                  serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDServerPort]
                                                                  clientPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                       peers:nil
                                                           heartbeatInterval:[NSString stringWithFormat:@"%d",Preference_ETCD_HeartbeatTimeout]
                                                             electionTimeout:[NSString stringWithFormat:@"%d",Preference_ETCD_ElectionTimeout]
                                                                    delegate:self];

    
    AMAddUserOperator* addSelfOper = [[AMAddUserOperator alloc] initWithParameter:self.myIp
                                                                       serverPort:[NSString stringWithFormat:@"%d",Preference_ETCDClientPort]
                                                                         username:self.myUserName
                                                                        groupname:self.myGroupName
                                                                       userdomain:self.myDomain
                                                                           userip:self.myIp
                                                                       userStatus:self.myStatus
                                                                  userDiscription:self.myDescription
                                                                         delegate:self];
    
    [addSelfOper addDependency:etcdLauncher];
}




@end
