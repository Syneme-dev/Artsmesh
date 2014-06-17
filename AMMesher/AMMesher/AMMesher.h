//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import <Foundation/Foundation.h>
//extern NSString* const AM_USERGROUPS_CHANGED;
extern NSString* const AM_LOCALUSERS_CHANGED;
extern NSString* const AM_REMOTEGROUPS_CHANGED;
extern NSString* const AM_MESHER_ONLINE;

@class AMLocalUser;
@class AMGroup;
@class AMSystemConfig;


@protocol AMMesherDelegate <NSObject>
-(void)onMesherError:(NSError*)err;
@end


@interface AMMesher: NSObject
@property id<AMMesherDelegate> delegate;

+(id)sharedAMMesher;

-(void)startMesher;
-(void)stopMesher;
-(void)renameCluster:(NSString *)newClusterName;

-(void)goOnline;
-(void)goOffline;
-(void)mergeGroup:(NSString*)groupName;
-(void)unmergeGroup;

@end




