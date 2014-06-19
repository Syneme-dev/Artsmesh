//
//  AMMesherStateMachine.h
//  AMMesher
//
//  Created by Wei Wang on 6/18/14.
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

@interface AMMesherStateMachine : NSObject

@property AMMesherState mesherState;


@end
