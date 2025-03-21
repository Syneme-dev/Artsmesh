//
//  AMLiveGroup.h
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AMLiveUser;

@interface AMLiveGroup : NSObject

//serialize properties
@property (nonatomic) NSString* groupId;
@property (nonatomic) NSString* groupName;
@property (nonatomic) NSString* fullName;
@property (nonatomic) NSString* description;
@property (nonatomic) NSString* leaderId;
@property (nonatomic) NSString* project;
@property (nonatomic) NSString* projectDescription;
@property (nonatomic) NSString* homePage;
@property (nonatomic) NSString* location;
@property (nonatomic) NSString* longitude;
@property (nonatomic) NSString* latitude;
@property (nonatomic) NSString* timezoneName;
@property (nonatomic) BOOL busy;
@property (nonatomic) BOOL broadcasting;
@property (nonatomic) NSString *broadcastingURL;

-(NSMutableDictionary*)dictWithoutUsers;
+(id)AMGroupFromDict:(NSDictionary*)dict;

//non serialize properties, and should no be change outside AMMesher
@property (nonatomic) NSString* password;
@property (nonatomic) NSArray* users;
@property (nonatomic) NSArray* messages;
@property (nonatomic) NSArray* subGroups;

-(BOOL)isMeshed;
-(AMLiveUser*)leader;
-(NSArray*)usersIncludeSubGroup;
-(BOOL)hasUserOnline;

@end
