//
//  AMETCDDataDestination.h
//  AMMesher
//
//  Created by 王 为 on 4/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDDestination.h"

@interface AMETCDDataDestination : AMETCDDestination

@property (atomic) NSMutableArray* userGroups;

-(void)clearUserGroup;

@end
