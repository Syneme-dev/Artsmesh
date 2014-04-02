//
//  AMUser.h
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUserGroupNode.h"

@interface AMUser : AMUserGroupNode

-(id)initWithName:(NSString*)name;

@property NSString* name;
@property NSString* groupName;
@property NSString* domain;
@property NSString* description;
@property NSString* status;
@property NSString* ip;
@property NSString* foafUrl;

@end
