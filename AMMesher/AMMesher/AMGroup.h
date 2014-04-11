//
//  AMGroup.h
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUserGroupNode.h"

@class AMETCDResult;
@interface AMGroup : AMUserGroupNode

@property NSString* uniqueName;
@property NSString* description;

-(id)init;

+(NSArray*)parseFullGroupName:(NSString*)fullName;


@end
