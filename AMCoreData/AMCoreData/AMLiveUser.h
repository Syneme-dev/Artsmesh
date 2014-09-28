//
//  AMLiveUser.h
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMLiveUser : NSObject

//serialize properties
@property (nonatomic) NSString* userid;
@property (nonatomic) NSString* fullName;
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
@property (nonatomic) BOOL      busy;

-(NSMutableDictionary*)toDict;
+(id)AMUserFromDict:(NSDictionary*)dict;

@end
