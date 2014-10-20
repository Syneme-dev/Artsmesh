//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMMesher.h"
#import "AMRemoteMesher.h"
#import "AMLocalMesher.h"
#import "AMLeaderElecter.h"
#import "AMCoreData/AMCoreData.h"

@implementation AMMesher
{
    AMLeaderElecter* _elector;
    AMLocalMesher* _localMesher;
    AMRemoteMesher* _remoteMesher;
}

+(id)sharedAMMesher
{
    static AMMesher* sharedMesher = nil;
    @synchronized(self){
        if (sharedMesher == nil){
            sharedMesher = [[self alloc] init];
            sharedMesher.mesherState = kMesherUnmeshed;
            sharedMesher.clusterState = kClusterStopped;
        }
    }
    return sharedMesher;
}

-(void) initComponents{
    
    if(_localMesher == nil){
        _localMesher = [[AMLocalMesher alloc] init];
    }
    
    if (_remoteMesher == nil) {
        _remoteMesher = [[AMRemoteMesher alloc] init];
    }
    
    if(_elector == nil){
        _elector = [[AMLeaderElecter alloc] init];
    }
}

-(void)startMesher
{
    if(self.clusterState != kClusterStopped){
        return;
    }
    
    [self initComponents];
    self.clusterState = kClusterAutoDiscovering;
}

-(void)stopMesher
{
    self.clusterState = kClusterStopping;
    self.mesherState = kMesherUnmeshing;
}


-(void)goOnline
{
    if (self.clusterState != kClusterStarted) {
        return;
    }
    
    self.mesherState = kMesherMeshing;
}

-(void)goOffline
{
    if (self.clusterState != kClusterStarted) {
        return;
    }
    
    if (self.mesherState != kMesherMeshed) {
        return;
    }
    
    self.mesherState = kMesherUnmeshing;
}


-(void)mergeGroup:(NSString*)superGroupId
{
    if (self.mesherState != kMesherMeshed) {
        return;
    }
    
    [_remoteMesher mergeGroup:superGroupId];
}


-(void)unmergeGroup
{
    if (self.mesherState != kMesherMeshed){
        return;
    }
    
    [_remoteMesher unmergeGroup];
}

-(void)updateGroup
{
    if(self.clusterState == kClusterStarted){
        [_localMesher updateGroupInfo];
    }
    
    if (self.mesherState == kMesherMeshed) {
        [_remoteMesher updateGroupInfo];
    }
}

-(void)updateMySelf
{
    if(self.clusterState == kClusterStarted){
        [_localMesher updateMyself];
    }
    
    if (self.mesherState == kMesherMeshed) {
        [_remoteMesher updateMyself];
    }
}

@end