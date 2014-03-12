//
//  AMUser.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUser.h"
static AMUser* _rootUser;

@implementation AMUser

- (NSInteger)numberOfChildren
{
    return  (_children == nil)? -1 : [_children count];
}

- (AMUser *)childAtIndex:(NSUInteger)n
{
    return (_children == nil)? nil :[_children objectAtIndex:n];
}

+(AMUser *)rootItem
{
    if(_rootUser == nil)
    {
        _rootUser = [[AMUser alloc] init];
        _rootUser.name = @"Groups";
        
        AMUser* group1 = [[AMUser alloc] init];
        group1.name = @"artsmesh";
        
        AMUser* group2 = [[AMUser alloc] init];
        group2.name = @"artsmesh2";
        
        AMUser* user1 = [[AMUser alloc] init];
        user1.name = @"use1";
        AMUser* user2 = [[AMUser alloc] init];
        user2.name = @"use2";
        AMUser* user3 = [[AMUser alloc] init];
        user3.name = @"use3";
        AMUser* user4 = [[AMUser alloc] init];
        user4.name = @"use4";
        
        group1.children = [[NSMutableArray alloc] init];
        group2.children = [[NSMutableArray alloc] init];
        
        [group1.children addObject:user1];
        [group1.children addObject:user2];
        [group2.children addObject:user3];
        [group2.children addObject:user4];
        
        _rootUser.children = [[NSMutableArray alloc] init];
        [_rootUser.children addObject:group1];
        [_rootUser.children addObject:group2];
    }
    
    return _rootUser;
}


@end
