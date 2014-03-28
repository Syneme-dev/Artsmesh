//
//  AMUser.h
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMGroup;
@interface AMUser : NSObject

@property NSString* name;
@property NSString* groupName;
@property NSString* domain;
@property NSString* description;
@property NSString* status;
@property NSString* ip;
@property NSString* foafUrl;

@property AMGroup* group;

@end
