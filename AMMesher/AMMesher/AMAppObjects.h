//
//  AMAppObjects.h
//  AMMesher
//
//  Created by lattesir on 6/15/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const AMLocalGroupKey; //My local group, AMGroup*
extern NSString * const AMMyselfKey;//Myself, AMUser*
extern NSString * const AMMergedGroupIdKey;//My merged group id, NSString
extern NSString * const AMRemoteGroupsKey;//All groups on AM, NSDictionary

extern NSString * const AMMesherStateMachineKey;//mesher state, internal use, AMMesherStateMachine*
extern NSString * const AMSystemConfigKey;//AMSytemConfig*

@interface AMAppObjects : NSObject

+ (id)appObjects;
+ (NSString*) creatUUID;

@end

@interface AMUser : NSObject

//serialize properties
@property (nonatomic) NSString* userid;
@property (nonatomic) NSString* nickName;
@property (nonatomic) NSString* domain;
@property (nonatomic) NSString* location;
@property (nonatomic) NSString* description;
@property (nonatomic) NSString* privateIp;
@property (nonatomic) NSString* publicIp;
@property (nonatomic) BOOL      isLeader;
@property (nonatomic) BOOL      isOnline;
@property (nonatomic) NSString* chatPort;
@property (nonatomic) NSString* publicChatPort;

-(NSMutableDictionary*)toDict;
+(id)AMUserFromDict:(NSDictionary*)dict;

@end

@interface AMGroup : NSObject

//serialize properties
@property (nonatomic) NSString* groupId;
@property (nonatomic) NSString* groupName;
@property (nonatomic) NSString* description;
@property (nonatomic) NSString* leaderId;

-(NSMutableDictionary*)dictWithoutUsers;
+(id)AMGroupFromDict:(NSDictionary*)dict;

//non serialize properties
@property (nonatomic) NSString* password;
@property (nonatomic) NSArray* users;
@property (nonatomic) NSArray* messages;

-(BOOL)isMeshed;
-(AMUser*)leader;
-(BOOL)isMyMergedGroup;
-(BOOL)isMyGroup;

@end

@interface AMGroupMessage : NSObject

@property NSString* fromUserId;
@property NSString* fromGroupId;
@property NSString* fromGroupName;
@property NSString* fromUserNickName;
@property NSString* messages;
@property NSString* time;

@end



