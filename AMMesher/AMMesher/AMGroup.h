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

@property NSString* fullname;
@property NSString* description;
@property NSString* ip; //mesher to mesher ip
@property NSString* port;

-(id)initWithName:(NSString*)name domain:(NSString*)domain  location:(NSString*)locaton;

-(void)updateGroup:(AMGroup*)group;


+(NSArray*)parseFullGroupName:(NSString*)fullName;


@end
