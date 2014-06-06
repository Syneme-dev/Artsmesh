//
//  AMGroupsBuilder.m
//
//  Created by lattesir on 5/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupsBuilder.h"

@implementation AMGroupsBuilder
{
    NSMutableDictionary *_groups;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _groups = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addUser:(AMUser *)user
{
    NSString *groupName = user.groupName;
    AMGroup *group = _groups[groupName];
    if (!group) {
        group = [[AMGroup alloc] initWithGroupName:groupName];
        _groups[groupName] = group;
    }
    [group addUser:user];
}

- (NSArray *)groups
{
    NSArray *keys = [_groups.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSUInteger count = keys.count;
    NSMutableArray *sortedGroups = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++)
        sortedGroups[i] = _groups[keys[i]];
    return sortedGroups;
}

@end
