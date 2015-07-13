//
//  AMLocalMesher.h
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMCommonTools/AMCommonTools.h>

extern NSString * const AMLocalHeartbeatFailNotification;
extern NSString * const AMLocalHeartbeatDisconnectNotification;
extern NSString * const AMLocalHeartbeatNotification;

@protocol AMHeartBeatDelegate;

@interface AMLocalMesher : NSObject

-(void)updateMyself;

-(void)updateGroupInfo;

@end
