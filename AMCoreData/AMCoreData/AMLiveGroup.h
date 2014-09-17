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
@property (nonatomic) NSString* description;
@property (nonatomic) NSString* leaderId;

@property (nonatomic) NSString* fullName;
@property (nonatomic) NSString* project;
@property (nonatomic) NSString* location;

@property (nonatomic) NSString* longitude;
@property (nonatomic) NSString* latitude;

@property (nonatomic) BOOL busy;

-(NSMutableDictionary*)dictWithoutUsers;
+(id)AMGroupFromDict:(NSDictionary*)dict;

//non serialize properties
@property (nonatomic) NSString* password;
@property (nonatomic) NSArray* users;
@property (nonatomic) NSArray* messages;

-(BOOL)isMeshed;
-(AMLiveUser*)leader;

@end
