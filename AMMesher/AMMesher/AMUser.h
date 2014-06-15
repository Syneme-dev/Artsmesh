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
@property BOOL      isOnline;
@property BOOL      isLocalLeader;
@property NSMutableArray* portMaps;

-(id)init;
-(NSString*)md5String;
-(AMUser*)copy;

+(AMUser*)userFromJsonData:(NSData*) data;

@end


@interface AMUserUDPRequest : NSObject

@property NSString* action;
@property NSString* version;
@property NSString* userid;
@property AMUser* userContent;
@property NSString* contentMd5;

-(NSData*)jsonData;
-(NSString*)jsonString;

@end


@interface AMUserUDPResponse : NSObject

@property NSString* action;
@property NSString* version;
@property NSString* contentMd5;
@property BOOL isSucceeded;

+(AMUserUDPResponse*)responseFromJsonData:(NSData*) data;

@end


@interface AMUserRESTResponse: NSObject

@property NSString* version;
@property NSMutableArray* userlist;

+(AMUserRESTResponse*)responseFromJsonData:(NSData*) data;

@end


