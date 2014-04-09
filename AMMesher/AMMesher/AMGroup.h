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
@property NSString* domain;
@property NSString* description;
@property NSString* m2mIp; //mesher to mesher ip
@property NSString* m2mPort;
@property NSString* foafUrl;

-(id)initWithName:(NSString*)name domain:(NSString*)domain;
-(id)initWithFullName:(NSString*)fullname;

//
//-(BOOL)isEqualToGroup:(AMGroup*)group differentFields:(NSMutableDictionary*)fieldsWithNewVal;
//-(AMGroup*)copyWithoutUsers;
//-(NSDictionary*)fieldsAndValue;

@end
