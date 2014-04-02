//
//  AMUserGroupChangeObject.h
//  AMMesher
//
//  Created by Wei Wang on 4/2/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUserGroupChangeObject : NSObject

@property NSString* changeMethod; //add, delete, update
@property NSString* groupName;
@property NSString* userName;
@property NSDictionary* oldProperties;
@property NSDictionary* newProperties;

@end
