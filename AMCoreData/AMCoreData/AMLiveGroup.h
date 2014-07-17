//
//  AMLiveGroup.h
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMLiveGroup : NSObject

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

@end
