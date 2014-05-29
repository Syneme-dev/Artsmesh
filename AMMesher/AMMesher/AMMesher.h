//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMUser;
@protocol AMHeartBeatDelegate;


@interface AMSystemConfig : NSObject
//Client
@property NSString* globalServerAddr;
@property NSString* globalServerUdpPort;
@property NSString* globalServerHttpPort;
@property NSString* heartbeatInterval;
@property BOOL isIpv6;
//Client And Server
@property NSString* localServerAddr;
@property NSString* localServerUdpPort;
@property NSString* localServerHttpPort;
//Server
@property NSString* userTimeout;
@end


@protocol AMMesherDelegate <NSObject>
-(void)onUserGroupsChange:(NSArray*)groups;
-(void)onMesherError:(NSError*)err;
@end


@interface AMMesher: NSObject<AMHeartBeatDelegate>

@property (readonly) AMUser* mySelf;
@property (readonly) NSString* localLeaderName;
@property (readonly) BOOL isLeader;
@property (readonly) BOOL isOnline;
@property id<AMMesherDelegate> delegate;

+(id)sharedAMMesher;

-(void)startMesher;
-(void)goOnline;
-(void)goOffline;
-(void)stopMesher;

-(void)joinGroup:(NSString*)groupName;
-(void)backToArtsmesh;

-(void)setMySelfPropties:(NSDictionary*)props;

@end




