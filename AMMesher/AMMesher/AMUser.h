//
//  AMUser.h
//  AMMesher
//
//  Created by Wei Wang on 5/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUserPortMap : NSObject

@property NSString* portName;
@property NSString* internalPort;
@property NSString* natMapPort;

@end


@interface AMUser : NSObject

@property NSString* userid;
@property NSString* nickName;
@property NSString* domain;
@property NSString* location;
@property NSString* groupName;
@property NSString* description;
@property NSString* publicIp;
@property NSString* privateIp;
@property NSString* localLeader;
@property NSMutableArray* portMaps;

-(id)init;
-(NSData*)jsonData;
-(NSString*)jsonString;
-(NSString*)md5String;
-(AMUser*)copy;

@end


@interface AMUserRequest : NSObject

@property NSString* action;
@property NSString* version;
@property AMUser* userContent;
@property NSString* contentMd5;

@end


@interface AMUserResponse: NSObject

@property NSString* version;
@property AMUser* userContent;
@property NSString* contentMd5;

@end


@interface AMUserListResult : NSObject

@property NSString* version;
@property NSMutableArray* userlist;

@end

