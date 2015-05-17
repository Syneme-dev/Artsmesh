//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum {
    kClusterError = -1,
    kClusterStopped = 0,
    kClusterAutoDiscovering,
    kClusterServerStarting,
    kClusterClientRegistering,
    kClusterStarted,
    kClusterStopping,
}AMClusterState;


typedef enum {
    kMesherError = -1,
    kMesherUnmeshed = 0,
    kMesherMeshing,
    kMesherMeshed,
    kMesherUnmeshing,
}AMMesherState;


@interface AMMesher: NSObject

+(id)sharedAMMesher;
@property AMMesherState mesherState;
@property AMClusterState clusterState;

-(void)startMesher;
-(void)stopMesher;
-(void)goOnline;
-(void)goOffline;

-(void)mergeGroup:(NSString*)superGroupId;
-(void)unmergeGroup;
-(void)updateGroup;
-(void)updateMySelf;


@end




