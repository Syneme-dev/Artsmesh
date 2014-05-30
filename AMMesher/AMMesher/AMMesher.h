//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import <Foundation/Foundation.h>
@protocol  AMHeartBeatDelegate;

@class AMUser;
@class AMGroup;
@class AMUserPortMap;
@class AMSystemConfig;


@protocol AMMesherDelegate <NSObject>
-(void)onUserGroupsChange:(NSArray*)groups;
-(void)onMesherError:(NSError*)err;
@end


@interface AMMesher: NSObject<AMHeartBeatDelegate>

@property (readonly) AMUser* mySelf;
@property (readonly) NSString* localLeaderName;
@property (readonly) BOOL isLocalLeader;
@property (readonly) BOOL isOnline;
@property (readonly) NSArray* userGroups;
@property id<AMMesherDelegate> delegate;

-(NSArray*)allGroupUsers;

+(id)sharedAMMesher;

-(void)startMesher;
-(void)goOnline;
-(void)goOffline;
-(void)stopMesher;

-(void)joinGroup:(NSString*)groupName;
-(void)backToArtsmesh;

-(void)setMySelfPropties:(NSDictionary*)props;
-(void)setPortMaps:(AMUserPortMap*)portMap;
-(AMUserPortMap*)portMapByName:(NSString*)portMapName;

@end




