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

@property NSString* fullname;
@property NSString* groupName;
@property NSString* domain;
@property NSString* description;
@property NSString* status;
@property NSString* ip;
@property NSString* foafUrl;


-(id)initWithName:(NSString*)name domain:(NSString *)domain;
-(id)initWithFullName:(NSString*)fullname;


//-(BOOL)isEqualToUser:(AMUser*)group differentFields:(NSMutableDictionary*)fieldsWithNewVal;
//-(NSDictionary*)fieldsAndValue;
//-(AMUser*)copyUser;

@end
