//
//  AMUserGroupViewController.m
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupViewController.h"
#import "AMUserGroupOutlineNode.h"

@interface AMUserGroupViewController ()

@end

@implementation AMUserGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


#pragma mark -
#pragma mark KVO

-(NSUInteger)countOfGroups
{
    return [self.groups count];
}

-(AMUserGroupOutlineNode*)objectInGroupsAtIndex:(NSUInteger)index
{
    return [self.groups objectAtIndex:index];
}

-(void)addGroupsObject:(AMUserGroupOutlineNode *)object
{
    [self willChangeValueForKey:@"groups"];
    [self.groups addObject:object];
    [self didChangeValueForKey:@"groups"];
}

-(void)replaceObjectInGroupsAtIndex:(NSUInteger)index withObject:(id)object
{
    [self willChangeValueForKey:@"groups"];
    [self.groups replaceObjectAtIndex:index withObject:object ];
    [self didChangeValueForKey:@"groups"];
}

-(void)insertObject:(AMUserGroupOutlineNode *)object inGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"groups"];
    [self.groups insertObject:object atIndex:index];
    [self didChangeValueForKey:@"groups"];
}

-(void)removeObjectFromGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"groups"];
    [self.groups removeObjectAtIndex:index];
    [self didChangeValueForKey:@"groups"];
}

-(void)removeGroupsObject:(AMUserGroupOutlineNode *)object
{
    [self willChangeValueForKey:@"groups"];
    [self.groups removeObject:object];
    [self didChangeValueForKey:@"groups"];
}


@end
