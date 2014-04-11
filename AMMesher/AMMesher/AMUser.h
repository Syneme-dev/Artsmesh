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

@property NSString* uniqueName;
@property NSString* domain;
@property NSString* location;
@property NSString* groupName;
@property NSString* description;

-(id)init;

-(NSString*)nodeName;

+(NSArray*)parseFullUserName:(NSString*)fullName;


@end
