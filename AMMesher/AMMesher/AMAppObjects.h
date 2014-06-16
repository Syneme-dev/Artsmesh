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
extern NSString * const AMLocalUsersKey;    // NSArray *
extern NSString * const AMMyselfKey;        // AMUser *
extern NSString * const AMMergedGroupIdKey; // NSString *
extern NSString * const AMRemoteGroupsKey;  // NSDictionary *

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
@property NSString* ip;
@property NSString* localLeader;
@property BOOL      isOnline;
@property NSString* chatPort;

-(NSMutableDictionary*)toLocalHttpBodyDict;

@end


