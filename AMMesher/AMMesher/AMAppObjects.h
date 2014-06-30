//
//  AMAppObjects.h
//  AMMesher
//
//  Created by lattesir on 6/15/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const AMClusterNameKey;   // NSString *
extern NSString * const AMClusterIdKey;     // NSString *
extern NSString * const AMLocalUsersKey;    // NSDictionary *
extern NSString * const AMMyselfKey;        // AMUser *
extern NSString * const AMMergedGroupIdKey; // NSString *
extern NSString * const AMRemoteGroupsKey;  // NSDictionary *
extern NSString * const AMMesherStateMachineKey; //AMMesherStateMachine
extern NSString * const AMSystemConfigKey; //AMSystemConfig
extern NSString * const AMGroupMessageKey;
extern NSString * const AMMeshedGroupsKey;
extern NSString * const AMLocaGroupKey;

@interface AMAppObjects : NSObject

+ (id)appObjects;
+ (NSString*) creatUUID;

@end

@interface AMUser : NSObject

@property NSString* userid;
@property NSString* nickName;
@property NSString* domain;
@property NSString* location;
@property NSString* description;
@property NSString* privateIp;
@property NSString* publicIp;
@property NSString* localLeader;
@property BOOL      isOnline;
@property NSString* chatPort;
@property NSString* publicChatPort;

-(NSMutableDictionary*)toDict;

+(id)AMUserFromDict:(NSDictionary*)dict;

@end

@interface AMGroup : NSObject

@property (nonatomic) NSString *groupId;
@property (nonatomic) NSString *groupName;
@property (nonatomic) NSString* password;
@property (nonatomic) NSString* description;
@property (nonatomic) NSString* leaderId;
@property (nonatomic) NSString* leaderName;
@property (nonatomic) NSArray *users;

@end


