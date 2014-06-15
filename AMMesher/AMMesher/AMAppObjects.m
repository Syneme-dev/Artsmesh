//
//  AMAppObjects.m
//  AMMesher
//
//  Created by lattesir on 6/15/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAppObjects.h"

NSString * const AMClusterNameKey = @"AMClusterNameKey";
NSString * const AMClusterIdKey = @"AMClusterIdKey";
NSString * const AMLocalUsersKey = @"AMLocalUsersKey";
NSString * const AMMyselfKey = @"AMMyselfKey";
NSString * const AMMergedGroupNameKey = @"AMMergedGroupNameKey";
NSString * const AMRemoteGroupsKey = @"AMRemoteGroupsKey";

static AMAppObjects *instance = nil;

@implementation AMAppObjects

+ (void)initialize
{
    instance = [[AMAppObjects alloc] init];
}

+ (id)appObjects
{
    return instance;
}

@end
