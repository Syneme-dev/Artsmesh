//
//  AMUser.h
//  AMMesher
//
//  Created by Wei Wang on 5/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMUser : NSObject

@property NSString* userid;
@property NSString* nickName;
@property NSString* domain;
@property NSString* location;
@property NSString* groupId;
@property NSString* groupName;
@property NSString* description;
@property NSString* publicIp;
@property NSString* privateIp;
@property NSString* localLeader;
@property BOOL      isOnline;
@property NSString* chatPort;
@property NSString* chatPortMap;

-(NSDictionary*)toLocalHttpBodyDict;

@end


