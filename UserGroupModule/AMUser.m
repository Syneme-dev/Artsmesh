//
//  AMUser.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUser.h"

@implementation AMUser

- (NSInteger)numberOfChildren
{
    return  (_children == nil)? -1 : [_children count];
}

- (AMUser *)childAtIndex:(NSUInteger)n
{
    return (_children == nil)? nil :[_children objectAtIndex:n];
}

@end
