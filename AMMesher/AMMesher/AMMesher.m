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
        self.mesherState = kMesherInitialized;
        [self initComponents];
    }
    
    return self;
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
    if(self.mesherState != kMesherInitialized){
        return;
    }
    
    self.mesherState = kMesherStarting;
}

-(void)stopMesher
{
    self.mesherState = kMesherStopping;
}


-(void)goOnline
{
    if (self.mesherState != kMesherStarted) {
        return;
    }
    
    [AMCoreData shareInstance].mySelf.isOnline = YES;
    [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANDED];
    
    self.mesherState = kMesherMeshing;
}

-(void)goOffline
{
    if (self.mesherState < kMesherMeshed || self.mesherState >= kMesherStopping) {
        return;
    }
    
    [AMCoreData shareInstance].mySelf.isOnline = NO;
    [[AMCoreData shareInstance] broadcastChanges:AM_MYSELF_CHANDED];
    
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
    if (self.mesherState == kMesherStarted){
        [_localMesher updateGroupInfo];
        
    }else if(self.mesherState == kMesherMeshed ){
        [_localMesher updateGroupInfo];
        [_remoteMesher updateGroupInfo];
    }
}

-(void)updateMySelf
{
    if (self.mesherState == kMesherStarted)
    {
        [_localMesher updateMyself];
        
    }else if(self.mesherState == kMesherMeshed){
        
        [_localMesher updateMyself];
        [_remoteMesher updateMyself];
    }
    
}

@end