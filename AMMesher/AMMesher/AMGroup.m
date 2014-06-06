//
//  AMGroup.m
//
//  Created by lattesir on 5/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroup.h"

@implementation AMGroup
{
    NSString *_groupName;
    NSMutableArray *_users;
}

- (id)init
{
    return [self initWithGroupName:@""];
}

- (instancetype)initWithGroupName:(NSString *)groupName;
{
    self = [super init];
    if (self) {
        _groupName = [groupName copy];
    }
    return self;
}

- (NSArray *)users
{
    return _users;
}

- (void)addUser:(AMUser *)user
{
    NSAssert([self.groupName isEqual:user.groupName], @"groupName mismatch");
    if (_users == nil) {
        _users = [[NSMutableArray alloc] init];
    }
    [_users addObject:user];
}

- (NSUInteger)countOfUsers
{
    return [_users count];
}

- (id)objectInUsersAtIndex:(NSUInteger)index
{
    return [_users objectAtIndex:index];
}

- (void)insertObject:(AMUser *)user inUsersAtIndex:(NSUInteger)index
{
    NSAssert([self.groupName isEqual:user.groupName], @"groupName mismatch");
    [_users insertObject:user atIndex:index];
}

- (void)removeObjectFromUsersAtIndex:(NSUInteger)index
{
    [_users removeObjectAtIndex:index];
}

- (void)replaceObjectInUsersAtIndex:(NSUInteger)index withObject:(id)user
{
    NSAssert([self.groupName isEqual:[user groupName]], @"groupName mismatch");
    [_users replaceObjectAtIndex:index withObject:user];
}

@end
