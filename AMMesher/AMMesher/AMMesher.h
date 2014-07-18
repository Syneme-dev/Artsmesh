//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum{
    kMesherError = -1,
    kMesherInitialized = 0,
    kMesherStarting,
    kMesherLocalServerStarting,
    kMesherLocalClientStarting,
    kMesherStarted,
    kMesherMeshing,
    kMesherMeshed,
    kMesherUnmeshing,
    kMesherStopping,
    kMesherStopped,
}AMMesherState;


@interface AMMesher: NSObject

+(id)sharedAMMesher;
-(void)startMesher;
-(void)stopMesher;

@property AMMesherState mesherState;

@end




