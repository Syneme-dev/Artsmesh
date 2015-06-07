//
//  AMRemoteMesher.h
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const AMHeartbeatFailNotification;
extern NSString * const AMHeartbeatDisconnectNotification;
extern NSString * const AMHeartbeatNotification;

@interface AMRemoteMesher : NSObject

-(void)startRemoteClient;
-(void)stopRemoteClient;

-(void)mergeGroup:(NSString*)superGroupId;
-(void)unmergeGroup;

-(void)updateMyself;
-(void)updateGroupInfo;

@end
