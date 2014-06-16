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

static NSMutableDictionary *global_dict = nil;

@implementation AMAppObjects

+ (void)initialize
{
    global_dict = [[NSMutableDictionary alloc] init];
}

+ (NSMutableDictionary*)appObjects
{
    return global_dict;
}

@end
