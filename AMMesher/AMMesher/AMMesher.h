//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import <Foundation/Foundation.h>

#define AM_LOCAL_MESHER_MESHING_NOTIFICATION @"Mesher meshing notification"
#define AM_LOCAL_MESHER_MESHED_NOTIFICATION @"Mesher meshed notification"
#define AM_MESHER_STOPPED_NOTIFICATION @"Mesher stopped notification"

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




