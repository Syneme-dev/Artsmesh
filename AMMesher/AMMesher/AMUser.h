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

-(NSString*)jsonString;
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

-(NSString*)jsonString;
-(NSString*)md5String;

@end

